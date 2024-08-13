
include { PREPARE_FASTQ       } from "../subworkflows/local/prepare_fastq"
include { PREPARE_GENOME      } from "../subworkflows/local/prepare_genome"
include { ENCODE_CHIP         } from "../subworkflows/encode/encode_chip"
include { METAGENOMICS        } from "../subworkflows/local/metagenomics"
include { DEEPTOOLS           } from "../subworkflows/local/deeptools"
include { HOMER               } from "../subworkflows/local/homer"
include { TRACKHUBS           } from "../subworkflows/local/trackhubs"

include { MULTIQC } from "../modules/local/multiqc/main"

include { validateParameters; paramsHelp; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'

if (!workflow.containerEngine && params.homer_log2_mode) {
	error("ERROR: homer log2 mode specified, but no container engine is used. This option can only be set when using Docker / Singularity / Apptainer.")
}

// Validate input parameters
validateParameters()
// Update any params if necessary


// Print summary of supplied parameters
log.info paramsSummaryLog(workflow)

workflow CHIPSEQ {
	// ------------------------
	// INPUTS
	// ------------------------

	PREPARE_GENOME(
		params.fasta,
		params.gtf,
		params.gensz,
		params.bowtie2_index,
		params.exclusion_peaks,
		params.save_reference
	)

	Channel
		.fromList(samplesheetToList(params.input, "assets/schema_input.json"))
		.map{ meta, fq1, fq2 -> 
			if(fq2){
				[ meta + [sample_type: "sample", single_end: false], [fq1, fq2] ]
			} else {
				[ meta + [sample_type: "sample", single_end: true], [fq1] ]
			}
		}
		.set{ch_input}
	
	PREPARE_FASTQ(
		ch_input,
		params.skip_adapter_trimming,
		params.save_trimmed_fastq
	)

	ENCODE_CHIP(
		PREPARE_FASTQ.out.fastq,
		PREPARE_GENOME.out.genome_fasta,
		PREPARE_GENOME.out.genome_fai,
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
		params.save_filtered_bam,
		params.skip_pseudoreplication,
		params.save_tagalign,
		params.encode_max_macs2_peaks,
		params.markdup_method
	)

	DEEPTOOLS(
		ENCODE_CHIP.out.bam_filtered,
		ENCODE_CHIP.out.bam_filtered_index,
		params.skip_bamcoverage
	)

	METAGENOMICS(
		PREPARE_FASTQ.out.fastq,
		params.sourmash_db ? file(params.sourmash_db) : [],
		params.skip_sourmash,
		params.kraken2_db ? file(params.kraken2_db) : [],
		params.skip_kraken2
	)

	ch_homer_peak_inputs = Channel.empty()
	ch_homer_peak_inputs = ch_homer_peak_inputs
		.mix(ENCODE_CHIP.out.idr_reproducible_peaks)
		.mix(ENCODE_CHIP.out.overlap_reproducible_peaks)

	HOMER(
		ch_homer_peak_inputs,
		PREPARE_GENOME.out.genome_fasta,
		PREPARE_GENOME.out.gtf,
		params.homer_motif_lib ? file(params.homer_motif_lib) : [],
		params.skip_homer_findmotifsgenome,
		params.skip_homer_annotatepeaks
	)

	TRACKHUBS(
		PREPARE_GENOME.out.genome_fai,
		DEEPTOOLS.out.bigwig,
		ENCODE_CHIP.out.fc_bigwig.mix(ENCODE_CHIP.out.pval_bigwig),
		ENCODE_CHIP.out.idr_reproducible_peaks,
		ENCODE_CHIP.out.overlap_reproducible_peaks
	)

	Channel.topic('encode_reproducibility_json')
		.branch{meta, peak ->
			idr: meta.mode == "idr"
			overlap: meta.mode == "overlap"
		}
		.set{ch_reproducibility_peaks_branched}

	Channel.topic('versions')
		.unique()
		.map{ process, name, version -> [process, "  ${name}: \"${version}\""] }
		.groupTuple(by: 0)
		.map{ process, name_versions ->
			def name_versions_collapsed = name_versions.join("\n")
			"${process}:\n${name_versions_collapsed}"
		}
		.set{ch_versions}

	MULTIQC(
		params.multiqc_config ? file(params.multiqc_config) : [],
		PREPARE_FASTQ.out.fastqc_raw_zip.collect{it[1]}.ifEmpty{[]},
		PREPARE_FASTQ.out.fastp_json.collect{it[1]}.ifEmpty{[]},
		PREPARE_FASTQ.out.fastqc_trimmed_zip.collect{it[1]}.ifEmpty{[]},
		ENCODE_CHIP.out.bowtie2_log.collect{it[1]}.ifEmpty{[]},
		ENCODE_CHIP.out.filtered_flagstat.collect{it[1]}.ifEmpty{[]},
		ENCODE_CHIP.out.picard_metrics.collect{it[1]}.ifEmpty{[]},
		ENCODE_CHIP.out.sambamba_log.collect{it[1]}.ifEmpty{[]},
		ENCODE_CHIP.out.lib_qc.collect{it[1]}.ifEmpty{[]},
		ENCODE_CHIP.out.spp.collect{it[1]}.ifEmpty{[]},
		ENCODE_CHIP.out.xcorr_csv.filter{meta,csv -> meta.sample_type in ["sample"]}.collect{it[1]}.ifEmpty{[]},
		ENCODE_CHIP.out.peakstats.collect{it[1]}.ifEmpty{[]},
		METAGENOMICS.out.sourmash_gather_csv.collect{it[1]}.ifEmpty{[]},
		METAGENOMICS.out.kraken2_report.collect{it[1]}.ifEmpty{[]},
		ch_reproducibility_peaks_branched.idr.collect{it[1]}.ifEmpty{[]},
		ch_reproducibility_peaks_branched.overlap.collect{it[1]}.ifEmpty{[]},
		DEEPTOOLS.out.fingerprint_metrics.collect{it[1]}.ifEmpty{[]},
		DEEPTOOLS.out.fingerprint_counts.collect{it[1]}.ifEmpty{[]},
		HOMER.out.findMotifsGenome_tsv.collect{it[1]}.ifEmpty{[]},
		HOMER.out.annotatePeaks_annStats.collect{it[1]}.ifEmpty{[]},
		ch_versions.collectFile(name: "software_mqc_versions.yml", newLine: true)
	)

	publish:
	MULTIQC.out >> "multiqc"


}