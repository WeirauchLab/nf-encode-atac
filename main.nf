nextflow.preview.output = true
nextflow.preview.topic = true

/*
----------------------------------
Modules        
----------------------------------
*/

include { QFILTER_PEAKS      } from "./modules/local/qfilter_peaks/main"
include { MULTIQC            } from "./modules/local/multiqc/main"
include { SUMMARY            } from "./modules/local/summary/main"
include { RENDER_MULTIQC_RMD } from "./modules/local/render_multiqc_rmd/main"
include { CONSENSUS_PEAKS    } from "./modules/local/consensus_peaks/main"

/*
----------------------------------
Subworkflows        
----------------------------------
*/
include { PREPARE_FASTQ      } from "./subworkflows/local/prepare_fastq"
include { PREPARE_GENOME     } from "./subworkflows/local/prepare_genome"
include { ENCODE             } from "./subworkflows/encode/encode"
include { METAGENOMICS       } from "./subworkflows/local/metagenomics"
include { DEEPTOOLS          } from "./subworkflows/local/deeptools"
include { HOMER              } from "./subworkflows/local/homer"
include { TRACKHUBS          } from "./subworkflows/local/trackhubs"

/*
----------------------------------
Plugins
----------------------------------
*/
include { validateParameters ; paramsHelp ; paramsSummaryLog ; samplesheetToList } from 'plugin/nf-schema'

/*
----------------------------------
Functions
----------------------------------
*/

// function to take a channel, check that either 0 or 1 distinct adapters are present for each read, and return the channel
def check_adapter_valid(input_channel) {
	input_channel
		.map { meta, _fq ->
			[meta.id, meta.adapter_1, meta.adapter_2]
		}
		.groupTuple(by: 0)
		.map { id, adapter_1, adapter_2 ->
			def adapter_1_distinct_size = adapter_1.unique().size()
			def adapter_2_distinct_size = adapter_2.unique().size()
			if (adapter_1_distinct_size > 1) {
				log.error("ERROR: Multiple distinct adapter sequences found for sample ${id}. Adapters are: ${adapter_1.unique()}. Please ensure that all adapter sequences are the same for a given sample.")
			}
			if (adapter_2_distinct_size > 1) {
				log.error("ERROR: Multiple distinct adapter sequences found for sample ${id}. Adapters are: ${adapter_2.unique()}. Please ensure that all adapter sequences are the same for a given sample.")
			}
		}
	return input_channel
}

/*
----------------------------------
Workflow
----------------------------------
*/

workflow {
	main:
	// ------------------------
	// PREAMBLE
	// ------------------------

	if (!workflow.containerEngine && params.homer_log2_mode) {
		error("ERROR: homer log2 mode specified, but no container engine is used. This option can only be set when using Docker / Singularity / Apptainer.")
	}
	if (params.summary_motifs && params.skip_homer_findmotifsgenome) {
		error("ERROR: Specific motifs are highlighted in the summary with --summary-motifs, but HOMER findMotifsGenome is skipped.  You can't have both.")
	}

	// Validate input parameters
	validateParameters()
	// Update any params if necessary
	// Print summary of supplied parameters
	log.info(paramsSummaryLog(workflow))

	// ------------------------
	// INPUTS
	// ------------------------

	PREPARE_GENOME(
		params.fasta,
		params.gtf,
		params.gensz,
		params.bowtie2_index,
		params.exclusion_peaks,
		params.tss_bed,
	)

	Channel.fromList(samplesheetToList(params.input, "assets/schema_input.json"))
		.map { meta, fq1, fq2 ->
			def meta_clone = meta.clone()
			meta_clone.adapter_1 = meta_clone.adapter_1 ?: params.adapter_1 ?: []
			meta_clone.adapter_2 = meta_clone.adapter_2 ?: params.adapter_2 ?: []
			if (fq2) {
				[meta_clone + [sample_type: "sample", single_end: false, pr_rep: []], [fq1, fq2]]
			}
			else {
				meta_clone.adapter_2 = []
				[meta_clone + [sample_type: "sample", single_end: true, pr_rep: []], [fq1]]
			}
		}
		.set { ch_input_base }

	check_adapter_valid(ch_input_base)


	ch_input_base
		.branch { meta, fq ->
			control_sample_id: meta.control_sample_id
			[meta.control_sample_id, meta, fq]
			no_control_sample_id: !meta.control_sample_id
			[meta, fq]
		}
		.set { ch_input_branches }

	ch_input_branches.control_sample_id
		.join(
			ch_input_base.map { meta, _fq -> [meta.sample_id, meta.group] }
		)
		.map { _control_id, meta, fq, control_group ->
			def new_meta = meta.clone()
			new_meta.control_group_id = control_group
			[new_meta, fq]
		}
		.mix(ch_input_branches.no_control_sample_id)
		.set { ch_input }

	PREPARE_FASTQ(
		ch_input,
		params.skip_adapter_trimming,
	)

	ENCODE(
		PREPARE_FASTQ.out.fastq,
		PREPARE_GENOME.out.genome_fasta,
		PREPARE_GENOME.out.genome_fai,
		PREPARE_GENOME.out.gtf,
		PREPARE_GENOME.out.tss,
		PREPARE_GENOME.out.gensz,
		PREPARE_GENOME.out.bowtie2_index,
		params.mapq_threshold ? params.mapq_threshold : [],
		params.chr_filter ? params.chr_filter : [],
		params.pseudorep_seed ? params.pseudorep_seed : 0,
		PREPARE_GENOME.out.exclusion_peaks,
		params.idr_threshold_col ? params.idr_threshold_col : "p.value",
		params.idr_threshold ? params.idr_threshold : 0.05,
		params.mito_chr_name ?: [],
		params.skip_align,
		params.skip_peak_filtering,
		params.skip_idr,
		params.skip_overlap,
		params.aligner,
		params.skip_low_mapq_filter,
		params.skip_rm_duplicates,
		params.skip_pseudoreplication,
		params.encode_max_macs2_peaks,
		params.markdup_method,
		params.skip_collectinsertsizemetrics,
	)

	// -------------------------
	// consensus peaks
	// -------------------------

	(ch_peaks_filtered_sample, ch_peaks_filtered_pooled) = ENCODE.out.peaks_filtered
		.branch { meta, peak ->
			sample: meta.sample_type == "sample"
				[meta.subMap("group"), peak]
			pooled: meta.sample_type == "pooled" && !meta.pr_rep
				[meta.subMap("group"), peak]
		}
	ch_consensus_input = ch_peaks_filtered_pooled
		.combine(ch_peaks_filtered_sample, by: 0)
		.groupTuple(by: [0, 1])
		.map { meta, pooled_peaks, sample_peaks ->
			def new_meta = [id: meta.group] + meta
			[new_meta, pooled_peaks, sample_peaks]
		}
		.filter{_meta, _pooled_peaks, sample_peaks -> sample_peaks.size() > 1 }

	ch_consensus_peaks = Channel.empty()
	ch_consensus_sessinfo = Channel.empty()
	ch_consensus_json = Channel.empty()
	ch_consensus_csv = Channel.empty()
	if (!params.skip_consensus_peaks) {
		CONSENSUS_PEAKS(ch_consensus_input)
		ch_consensus_peaks = CONSENSUS_PEAKS.out.peaks
		ch_consensus_json = CONSENSUS_PEAKS.out.json
		ch_consensus_csv = CONSENSUS_PEAKS.out.matrix_csv
		ch_consensus_sessinfo = CONSENSUS_PEAKS.out.sessinfo
	}

	// -------------------------
	// DEEPTOOLS
	// -------------------------

	DEEPTOOLS(
		ENCODE.out.bam_filtered,
		ENCODE.out.bam_filtered_index,
		params.skip_bamcoverage,
	)

	METAGENOMICS(
		PREPARE_FASTQ.out.fastq,
		params.sourmash_db ? file(params.sourmash_db) : [],
		params.skip_sourmash,
		params.kraken2_db ? file(params.kraken2_db) : [],
		params.skip_kraken2,
	)

	ch_qfilter_peaks_inputs = Channel.empty()
	ch_qfilter_peaks_outputs = Channel.empty()
	ch_qfilter_peaks_inputs
		.mix(ENCODE.out.peaks_filtered)
		.mix(ENCODE.out.idr_optimal)
		.mix(ENCODE.out.overlap_optimal)
		.mix(ENCODE.out.idr_conservative)
		.mix(ENCODE.out.overlap_conservative)
		.set { ch_qfilter_peaks_inputs }

	QFILTER_PEAKS(ch_qfilter_peaks_inputs)
	ch_qfilter_peaks_outputs = QFILTER_PEAKS.out.peak

	// -------------------------
	// HOMER
	// -------------------------

	// Select the peak files to use for HOMER based on the input parameters
	Channel.empty()
		.mix(
			(params.homer_peak_inputs.contains("idr_conservative") ? ENCODE.out.idr_conservative : Channel.empty()),
			(params.homer_peak_inputs.contains("idr_optimal") ? ENCODE.out.idr_optimal : Channel.empty()),
			(params.homer_peak_inputs.contains("overlap_conservative") ? ENCODE.out.overlap_conservative : Channel.empty()),
			(params.homer_peak_inputs.contains("overlap_optimal") ? ENCODE.out.overlap_optimal : Channel.empty()),
		)
		.set { ch_homer_peak_inputs }

	HOMER(
		ch_homer_peak_inputs,
		PREPARE_GENOME.out.genome_fasta,
		PREPARE_GENOME.out.gtf,
		params.homer_motif_lib ? file(params.homer_motif_lib) : [],
		params.skip_homer_findmotifsgenome,
		params.skip_homer_annotatepeaks,
	)

	TRACKHUBS(
		PREPARE_GENOME.out.genome_fai,
		DEEPTOOLS.out.bigwig,
		ENCODE.out.fc_bigwig.mix(ENCODE.out.pval_bigwig),
		ENCODE.out.idr_conservative.mix(ENCODE.out.idr_optimal),
		ENCODE.out.overlap_conservative.mix(ENCODE.out.overlap_optimal),
	)

	ENCODE.out.reproducibility_stats_json
		.branch { meta, _peak ->
			idr: meta.reproducibility_mode == "idr"
			overlap: meta.reproducibility_mode == "overlap"
		}
		.set { ch_reproducibility_peaks_branched }



	channel.of(
		["${workflow.manifest.name} (WORKFLOW)","version", "${workflow.manifest.version}"],
		["${workflow.manifest.name} (WORKFLOW)","revision", "${workflow.revision ?: 'no revision'}"],
		["${workflow.manifest.name} (WORKFLOW)","commit", "${workflow.commitId ?: 'no commit ID'}"],
		["NEXTFLOW", "nextflow", nextflow.version]
	)
		.mix(Channel.topic('versions'))
		.unique()
		.map { process, name, version -> [process, "  ${name}: \"${version}\""] }
		.groupTuple(by: 0)
		.map { process, name_versions ->
			def name_versions_collapsed = name_versions.join("\n")
			"${process}:\n${name_versions_collapsed}"
		}
		.set { ch_versions }

	MULTIQC(
		params.multiqc_config ? file(params.multiqc_config) : [],
		PREPARE_FASTQ.out.fastqc_raw_zip.collect { it[1] }.ifEmpty { [] },
		PREPARE_FASTQ.out.fastp_json.collect { it[1] }.ifEmpty { [] },
		PREPARE_FASTQ.out.fastqc_trimmed_zip.collect { it[1] }.ifEmpty { [] },
		PREPARE_FASTQ.out.seqkit_tsv.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.bowtie2_log.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.filtered_flagstat.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.picard_metrics.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.insertsizes.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.mtnuc_json.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.sambamba_log.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.lib_qc.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.spp.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.xcorr_csv.filter { meta, _csv -> meta.sample_type in ["sample"] }.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.peakstats.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.peakstats_sample.filter { it[0].reproducibility_mode == "idr" }.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.peakstats_sample.filter { it[0].reproducibility_mode == "overlap" }.collect { it[1] }.ifEmpty { [] },
		ENCODE.out.tss_enrichment_json.collect { it[1] }.ifEmpty { [] },
		METAGENOMICS.out.sourmash_gather_csv.collect { it[1] }.ifEmpty { [] },
		METAGENOMICS.out.kraken2_report.collect { it[1] }.ifEmpty { [] },
		ch_reproducibility_peaks_branched.idr.collect { it[1] }.ifEmpty { [] },
		ch_reproducibility_peaks_branched.overlap.collect { it[1] }.ifEmpty { [] },
		DEEPTOOLS.out.fingerprint_metrics.collect { it[1] }.ifEmpty { [] },
		DEEPTOOLS.out.fingerprint_counts.collect { it[1] }.ifEmpty { [] },
		HOMER.out.findMotifsGenome_tsv.collect { it[1] }.ifEmpty { [] },
		HOMER.out.annotatePeaks_annStats.collect { it[1] }.ifEmpty { [] },
		ch_consensus_json.collect { it[1] }.ifEmpty { [] },
		ch_versions.collectFile(name: "software_mqc_versions.yml", newLine: true),
	)

	summary_md = Channel.empty()
	if (!params.skip_summary_rmd) {
		RENDER_MULTIQC_RMD(
			file(params.multiqc_summary_rmd),
			MULTIQC.out.data_json,
		)
		summary_md = summary_md.mix(RENDER_MULTIQC_RMD.out.report)
	}

	SUMMARY(
		file(params.summary_config),
		params.summary_motifs ? file(params.summary_motifs) : [],
		MULTIQC.out.data,
		HOMER.out.findMotifsGenome_tsv.collect { it[1] }.ifEmpty { [] },
	)

	publish:
	// PREPARE_GENOME
	PREPARE_GENOME.out.tss >> "genome"
	PREPARE_GENOME.out.bowtie2_index >> "genome/bowtie2"

	// PREPARE_FASTQ
	PREPARE_FASTQ.out.subsampled_fastq >> "fastq/subsampled"
	PREPARE_FASTQ.out.fastqc_raw_zip >> "fastqc/raw"
	PREPARE_FASTQ.out.fastqc_trimmed_zip >> "fastqc/trimmed"
	PREPARE_FASTQ.out.fastp_json >> "fastp"
	PREPARE_FASTQ.out.fastp_html >> "fastp"
	PREPARE_FASTQ.out.seqkit_tsv >> "seqkit"
	PREPARE_FASTQ.out.fastq >> "fastq/trimmed"

	// ENCODE
	ENCODE.out.bam_aligned >> "encode/alignments/raw"
	ENCODE.out.bam_aligned_index >> "encode/alignments/raw"
	ENCODE.out.bowtie2_log >> "encode/logs/bowtie2"
	ENCODE.out.raw_flagstat >> "encode/alignments/flagstats/aligned"
	ENCODE.out.bam_filtered >> "encode/alignments/filtered"
	ENCODE.out.bam_filtered_index >> "encode/alignments/filtered"
	ENCODE.out.picard_metrics >> "encode/logs/picard_metrics"
	ENCODE.out.insertsizes >> "encode/picard"
	ENCODE.out.insertsizes_histogram >> "encode/picard"
	ENCODE.out.sambamba_log >> "encode/logs/sambamba_markdup"
	ENCODE.out.filtered_flagstat >> "encode/alignments/flagstats/filtered"
	ENCODE.out.mtnuc_json >> "encode/mtnucratio"
	ENCODE.out.mtnuc_ratio >> "encode/mtnucratio"
	ENCODE.out.spp >> "encode/spp"
	ENCODE.out.xcorr_csv >> "encode/spp"
	ENCODE.out.processed_tagalign >> "encode/tagAlign"
	ENCODE.out.fc_bigwig >> "encode/macs2/signal"
	ENCODE.out.pval_bigwig >> "encode/macs2/signal"
	ENCODE.out.narrowPeak >> "encode/macs2/raw"
	ENCODE.out.peaks_filtered >> "encode/macs2/filtered"
	ENCODE.out.idr_optimal >> "encode/macs2/idr"
	ENCODE.out.idr_conservative >> "encode/macs2/idr"
	ENCODE.out.idr_plots >> "encode/macs2/idr"
	ENCODE.out.idr_peaks >> "encode/macs2/idr"
	ENCODE.out.overlap_optimal >> "encode/macs2/overlap"
	ENCODE.out.overlap_conservative >> "encode/macs2/overlap"
	ENCODE.out.overlap_peaks >> "encode/macs2/overlap"
	//ENCODE.out.reproducibility_peak_counts >> "encode/macs2/reproducibility"
	//ENCODE.out.reproducibility_stats_csv >> "encode/macs2/reproducibility"
	//ENCODE.out.reproducibility_stats_json >> "encode/macs2/reproducibility"
	ENCODE.out.lib_qc >> "encode/lib_qc"
	ENCODE.out.peakstats >> "encode/peakstats"
	ENCODE.out.peakstats_sample >> "encode/peakstats/sample"
	ENCODE.out.tss_enrichment_json >> "encode/tss_enrichment"
	ENCODE.out.tss_enrichment_csv >> "encode/tss_enrichment"
	ENCODE.out.tagAlign_sample >> (params.save_sample_tagalign ? "encode/tagAlign" : null)
	ENCODE.out.tagAlign_pr >> (params.save_pr_tagalign ? "encode/tagAlign" : null)
	ENCODE.out.tagAlign_pooled >> (params.save_pooled_tagalign ? "encode/tagAlign" : null)
	ENCODE.out.tagAlign_pr_pooled >> (params.save_pooled_tagalign && params.save_pr_tagalign ? "encode/tagAlign" : null)

	// Q-filtered peaks
	QFILTER_PEAKS.out.peak >> "encode/macs2/qfiltered"

	// METAGENOMICS
	METAGENOMICS.out.sourmash_sketch >> "metagenomics/sourmash"
	METAGENOMICS.out.sourmash_gather_csv >> "metagenomics/sourmash"
	METAGENOMICS.out.kraken2_report >> "metagenomics/kraken2"

	// CONSENSUS PEAKS
	ch_consensus_peaks >> "encode/macs2/consensus_peaks"
	ch_consensus_json >> "encode/macs2/consensus_peaks"
	ch_consensus_csv >> "encode/macs2/consensus_peaks"
	ch_consensus_sessinfo >> "encode/macs2/consensus_peaks"

	// DEEPTOOLS
	DEEPTOOLS.out.bigwig >> "deeptools/bamcoverage"
	DEEPTOOLS.out.fingerprint_metrics >> "deeptools/plotFingerprint"
	DEEPTOOLS.out.fingerprint_counts >> "deeptools/plotFingerprint"

	// HOMER
	HOMER.out.findMotifsGenome_tsv >> "homer/findMotifsGenome"
	HOMER.out.findMotifsGenome_html >> "homer/findMotifsGenome"
	HOMER.out.findMotifsGenome_denovo >> "homer/findMotifsGenome"
	HOMER.out.findMotifsGenome_tar >> "homer/findMotifsGenome"
	HOMER.out.annotatePeaks_tsv >> "homer/annotatePeaks"
	HOMER.out.annotatePeaks_annStats >> "homer/annotatePeaks"

	// TRACKHUBS
	TRACKHUBS.out.ucsc_trackhub_data >> "trackhubs/ucsc"
	TRACKHUBS.out.ucsc_trackhub_hub >> "trackhubs/ucsc"

	// MultiQC
	MULTIQC.out >> "multiqc"
	SUMMARY.out >> "multiqc"
	summary_md >> "multiqc"
	ch_qfilter_peaks_outputs >> "encode/macs2/qfiltered"
}

output {
	"genome/bowtie2" {
		enabled params.save_reference
	}

	"fastq/subsampled" {
		index {
			path 'fastq_index.json'
		}
		enabled params.save_subsampled_fastq
	}
	"fastq/trimmed" {
		index {
			path 'fastq_index.json'
		}
		enabled params.save_trimmed_fastq
	}

	'encode/tagAlign' {
		index {
			path 'tagAlign_index.json'
		}
	}
	'encode/alignments/raw' {
		index {
			path 'alignments_raw_index.json'
		}
	}
	'encode/alignments/filtered' {
		index {
			path 'alignments_filtered_index.json'
		}
		enabled params.save_filtered_bam
	}
	'encode/macs2/raw' {
		index {
			path 'macs2_raw_index.json'
		}
	}
	'encode/macs2/filtered' {
		index {
			path 'macs2_filtered_index.json'
		}
	}
	'encode/macs2/signal' {
		index {
			path 'macs2_signal_index.json'
		}
	}
	'encode/macs2/idr' {
		index {
			path 'macs2_idr_index.json'
		}
	}
}
