
include { DEEPTOOLS_PLOTFINGERPRINT } from "../../modules/local/deeptools/plotFingerprint/main"
include { FILTER_PEAKS              } from "../../modules/encode/filter_peaks/main"
include { LIB_QC                    } from "../../modules/encode/lib_qc/main"
include { CALC_PEAKSTATS            } from '../../modules/encode/calc_peakstats/main'

include { TASK_ALIGN               } from './task_align.nf'
include { TASK_FILTER              } from './task_filter.nf'
include { TASK_TAGALIGN            } from './task_tagalign.nf'
include { TASK_XCORR               } from './task_xcorr.nf'
include { TASK_MACS2               } from './task_macs2.nf'
include { TASK_REPRODUCIBILITY     } from './task_reproducibility.nf'



def subset_peak_meta(peak_channel, meta_keys){
	peak_channel.map{meta, peak -> [meta.subMap(meta_keys), peak]}
}

workflow ENCODE_CHIP {
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
	save_tagalign
	max_peaks
	markdup_method

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
		save_filtered_bam
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
		save_tagalign
	)
	TASK_XCORR(
		TASK_TAGALIGN.out.tagAlign,
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
	Channel.empty()
		.mix(
			ch_peaks_filtered
				.map{meta, peak ->[meta.tagalign_id, meta, peak]}
				.join(ch_tagalign.map{meta, ta ->[meta.id, ta]}, by: 0)
				.map{it -> it[1..-1]}
		)
		.mix(
			TASK_REPRODUCIBILITY.out.conservative
				.mix(TASK_REPRODUCIBILITY.out.optimal)
				.map{meta, peaks ->
					[meta.group, meta, peaks]
				}
				.combine(
					ch_tagalign
						.filter{meta, ta -> meta.sample_type == "pooled"}
						.map{meta, ta ->[meta.group, ta]},
					by: 0
				)
				.map{it -> it[1..-1]}
		)
		.set{ch_peakstats_input}

	CALC_PEAKSTATS(ch_peakstats_input)


	publish:
	ch_peaks_filtered		  >> "encode/macs2/filtered"
	LIB_QC.out.tsv            >> "encode/lib_qc"

	emit:
	bam_aligned                = TASK_ALIGN.out.bam
	bam_aligned_index          = TASK_ALIGN.out.bai
	bowtie2_log                = TASK_ALIGN.out.bowtie2_log
	raw_flagstat               = TASK_ALIGN.out.flagstat
	bam_filtered               = TASK_FILTER.out.bam
	bam_filtered_index         = TASK_FILTER.out.bai
	picard_metrics             = TASK_FILTER.out.picard_metrics
	sambamba_log               = TASK_FILTER.out.sambamba_log
	filtered_flagstat          = TASK_FILTER.out.flagstat
	spp                        = TASK_XCORR.out.spp
	xcorr_csv                  = TASK_XCORR.out.xcorr_csv
	processed_tagalign         = TASK_TAGALIGN.out.tagAlign
	fc_bigwig                  = TASK_MACS2.out.fc_bigwig
	pval_bigwig                = TASK_MACS2.out.pval_bigwig
	narrowPeak                 = TASK_MACS2.out.narrowPeak
	peaks_filtered             = ch_peaks_filtered
	conservative_peaks         = TASK_REPRODUCIBILITY.out.conservative
	optimal_peaks              = TASK_REPRODUCIBILITY.out.optimal
	idr_peaks                  = TASK_REPRODUCIBILITY.out.idr_peaks
	overlap_peaks              = TASK_REPRODUCIBILITY.out.overlap_peaks
	idr_reproducible_peaks     = TASK_REPRODUCIBILITY.out.idr_reproducible_peaks
	overlap_reproducible_peaks = TASK_REPRODUCIBILITY.out.overlap_reproducible_peaks
	lib_qc                     = LIB_QC.out.tsv
	peakstats                  = CALC_PEAKSTATS.out.peakstats
}