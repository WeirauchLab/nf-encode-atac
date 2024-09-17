
include { DEEPTOOLS_PLOTFINGERPRINT               } from "../../modules/local/deeptools/plotFingerprint/main"
include { FILTER_PEAKS                            } from "../../modules/encode/filter_peaks/main"
include { LIB_QC                                  } from "../../modules/encode/lib_qc/main"
include { CALC_PEAKSTATS as CALC_PEAKSTATS_REPRO  } from '../../modules/encode/calc_peakstats/main'
include { CALC_PEAKSTATS as CALC_PEAKSTATS_SAMPLE } from '../../modules/encode/calc_peakstats/main'

include { TASK_ALIGN               } from './task_align.nf'
include { TASK_FILTER              } from './task_filter.nf'
include { TASK_TAGALIGN            } from './task_tagalign.nf'
include { TASK_XCORR               } from './task_xcorr.nf'
include { TASK_MACS2               } from './task_macs2.nf'
include { TASK_REPRODUCIBILITY     } from './task_reproducibility.nf'



def subset_peak_meta(peak_channel, meta_keys){
	peak_channel.map{meta, peak -> [meta.subMap(meta_keys), peak]}
}

workflow ENCODE {
	take:
	ch_fastq
	ch_fasta
	ch_fai
	ch_gensz
	ch_bowtie2_index
	mapq_threshold
	ch_chr_filter
	pseudorep_seed
	ch_exclusion_peaks
	ch_idr_threshold_col
	ch_idr_threshold
	ch_mito_chr_name
	skip_align
	skip_peak_filtering
	skip_idr
	skip_overlap
	aligner
	skip_low_mapq_filter
	skip_rm_duplicates
	save_filtered_bam
	skip_pseudoreplication
	save_sample_tagalign
	save_pr_tagalign
	save_pooled_tagalign
	max_peaks
	markdup_method
	skip_collectinsertsizemetrics

	main:

	TASK_ALIGN(
		ch_fastq,
		ch_fasta,
		aligner,
		ch_bowtie2_index,
		skip_align
	)
	ch_bam_aligned       = TASK_ALIGN.out.bam
	ch_bam_aligned_index = TASK_ALIGN.out.bai
	ch_bowtie2_log       = TASK_ALIGN.out.bowtie2_log

	TASK_FILTER(
		ch_bam_aligned,
		mapq_threshold,
		markdup_method,
		skip_low_mapq_filter,
		skip_rm_duplicates,
		save_filtered_bam,
		skip_collectinsertsizemetrics,
		ch_mito_chr_name
	)
	ch_filtered_bam = TASK_FILTER.out.bam
	ch_filtered_bam_bai = TASK_FILTER.out.bam.join(TASK_FILTER.out.bai, by: 0)

	LIB_QC(
		TASK_FILTER.out.markdup_bam
	)

	TASK_TAGALIGN(
		TASK_FILTER.out.bam,
		pseudorep_seed,
		skip_pseudoreplication,
		save_sample_tagalign,
		save_pr_tagalign,
		save_pooled_tagalign
	)
	ch_tagalign = TASK_TAGALIGN.out.tagAlign

	TASK_XCORR(
		ch_tagalign,
		ch_mito_chr_name
	)
	ch_tagalign = TASK_XCORR.out.tagAlign


	TASK_MACS2(
		ch_tagalign,
		ch_fai,
		ch_gensz,
		max_peaks
	)

	// TASK postproc_peaks
	if(skip_peak_filtering){
		ch_peaks_filtered = TASK_MACS2.out.narrowPeak
	} else {
		FILTER_PEAKS(
			TASK_MACS2.out.narrowPeak,
			ch_exclusion_peaks,
			ch_chr_filter
		)
		ch_peaks_filtered = FILTER_PEAKS.out.narrowPeak
	}

	// TASK reproducibility
	TASK_REPRODUCIBILITY(
		ch_peaks_filtered,
		ch_idr_threshold_col,
		ch_idr_threshold,
		skip_idr,
		skip_overlap
	)

	// Peak stats
	// This takes peak files, matches them back against their tag align file
	// and calculates the FRiP score / number of peaks

	ch_peakstats_repro = Channel.empty()
	ch_peakstats_sample = Channel.empty()

	TASK_REPRODUCIBILITY.out.idr_conservative
		| mix(TASK_REPRODUCIBILITY.out.idr_optimal)
		| mix(TASK_REPRODUCIBILITY.out.overlap_conservative)
		| mix(TASK_REPRODUCIBILITY.out.overlap_optimal)
		| map{meta, peaks ->
			[meta.group, meta, peaks]
		}
		| combine(
			ch_tagalign
				| filter{ meta, ta -> meta.sample_type == "pooled" && !meta.pr_rep }
				| map{ meta, ta ->[meta.group, ta] },
			by: 0
		)
		| map{it -> it[1..-1]}
		| set{ch_rep_peaks_prepared}

	TASK_REPRODUCIBILITY.out.idr_peaks
		| mix(TASK_REPRODUCIBILITY.out.overlap_peaks)
		| filter{meta, peaks -> meta.sample_type == "sample"}
		| map{meta, peaks ->
			meta.id = "${meta.id}"
			[meta.sample_id, meta, peaks]
		}
		| combine(
			ch_tagalign
				| filter{meta, ta -> meta.sample_type == "sample"}
				| map{meta, ta -> [meta.sample_id, ta]},
			by: 0
		)
		| map{it -> it[1..-1]}
		| set{ch_sample_consistency_peaks_w_tagalign}
	
	CALC_PEAKSTATS_SAMPLE(ch_sample_consistency_peaks_w_tagalign)
	ch_peakstats_sample
		| mix(CALC_PEAKSTATS_SAMPLE.out.peakstats)
		| set{ch_peakstats_sample}

	Channel.empty()
		| mix(
			ch_peaks_filtered
				| map{meta, peak ->[meta.id, meta, peak]}
				| join(ch_tagalign.map{meta, ta ->[meta.id, ta]}, by: 0)
				| map{it -> it[1..-1]}
		)
		| mix(ch_rep_peaks_prepared)
		| set{ch_peakstats_input}
	
	CALC_PEAKSTATS_REPRO(ch_peakstats_input)
	ch_peakstats_repro
		| mix(CALC_PEAKSTATS_REPRO.out.peakstats)
		| set{ch_peakstats_repro}


	


	publish:
	ch_peaks_filtered		  >> "encode/macs2/filtered"
	LIB_QC.out.tsv            >> "encode/lib_qc"

	emit:
	bam_aligned                 = TASK_ALIGN.out.bam
	bam_aligned_index           = TASK_ALIGN.out.bai
	bowtie2_log                 = TASK_ALIGN.out.bowtie2_log
	raw_flagstat                = TASK_ALIGN.out.flagstat
	bam_filtered                = TASK_FILTER.out.bam
	bam_filtered_index          = TASK_FILTER.out.bai
	picard_metrics              = TASK_FILTER.out.picard_metrics
	insertsizes                 = TASK_FILTER.out.insertsizes
	sambamba_log                = TASK_FILTER.out.sambamba_log
	filtered_flagstat           = TASK_FILTER.out.flagstat
	mtnuc_json                  = TASK_FILTER.out.mtnuc_json
	mtnuc_ratio                 = TASK_FILTER.out.mtnuc_ratio
	spp                         = TASK_XCORR.out.spp
	xcorr_csv                   = TASK_XCORR.out.xcorr_csv
	processed_tagalign          = TASK_TAGALIGN.out.tagAlign
	fc_bigwig                   = TASK_MACS2.out.fc_bigwig
	pval_bigwig                 = TASK_MACS2.out.pval_bigwig
	narrowPeak                  = TASK_MACS2.out.narrowPeak
	peaks_filtered              = ch_peaks_filtered
	idr_optimal                 = TASK_REPRODUCIBILITY.out.idr_optimal
	idr_conservative            = TASK_REPRODUCIBILITY.out.idr_conservative
	overlap_optimal             = TASK_REPRODUCIBILITY.out.overlap_optimal
	overlap_conservative        = TASK_REPRODUCIBILITY.out.overlap_conservative
	reproducibility_peak_counts = TASK_REPRODUCIBILITY.out.peak_counts
	reproducibility_stats_csv   = TASK_REPRODUCIBILITY.out.stats_csv
	reproducibility_stats_json  = TASK_REPRODUCIBILITY.out.stats_json
	lib_qc                      = LIB_QC.out.tsv
	peakstats                   = ch_peakstats_repro
	peakstats_sample            = ch_peakstats_sample
}