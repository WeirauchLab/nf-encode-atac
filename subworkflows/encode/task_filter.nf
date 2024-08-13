include { RM_LOWQ_READS          } from '../../modules/encode/rm_lowq_reads/main'
include { PICARD_MARKDUPLICATES  } from '../../modules/local/picard/markDuplicates/main'
include { SAMBAMBA_MARKDUP       } from '../../modules/local/sambamba/markdup/main'
include { RM_DUPLICATES          } from '../../modules/encode/rm_dup/main'
include { SAMTOOLS_INDEX         } from "../../modules/local/samtools/index/main"
include { SAMTOOLS_FLAGSTAT      } from "../../modules/local/samtools/flagstats/main"

workflow TASK_FILTER {
	take:
	ch_bam              // channel: [ val(meta), path(bam) ]
	mapq_threshold      // integer or []
	markdup_method      // "picard" or "sambamba"
	skip_rm_lowq_reads  // boolean
	skip_rm_duplicates  // boolean
	save_filtered_bam   // boolean

	main:
	
	if(!skip_rm_lowq_reads && mapq_threshold) {
		RM_LOWQ_READS(
			ch_bam,
			mapq_threshold
		)
		ch_lowq_filtered = RM_LOWQ_READS.out.bam
	} else {
		ch_lowq_filtered = ch_bam
	}

	ch_picard_metrics = Channel.empty()
	ch_sambamba_log   = Channel.empty()
	ch_markdup        = Channel.empty()
	if(markdup_method == "picard"){
		PICARD_MARKDUPLICATES(
			ch_lowq_filtered
		)
		ch_markdup        = PICARD_MARKDUPLICATES.out.bam
		ch_picard_metrics = PICARD_MARKDUPLICATES.out.metrics
	} else if (markdup_method == "sambamba") {
		SAMBAMBA_MARKDUP(
			ch_lowq_filtered
		)
		ch_markdup      = SAMBAMBA_MARKDUP.out.bam
		ch_sambamba_log = SAMBAMBA_MARKDUP.out.log
	} else {
		ch_markdup = ch_lowq_filtered
	}

	if(!skip_rm_duplicates) {
		RM_DUPLICATES(
			ch_markdup
		)
		ch_filtered = RM_DUPLICATES.out.bam
	} else {
		ch_filtered = ch_markdup
	}

	SAMTOOLS_INDEX(ch_filtered)
	ch_filtered_bai = SAMTOOLS_INDEX.out.bai

	SAMTOOLS_FLAGSTAT(ch_filtered)

	publish:
	ch_filtered                    >> (save_filtered_bam ? "encode/alignments/filtered" : null)
	ch_filtered_bai                >> (save_filtered_bam ? "encode/alignments/filtered" : null)
	ch_picard_metrics              >> "encode/logs/picard_metrics"
	ch_sambamba_log                >> "encode/logs/sambamba_markdup"
	SAMTOOLS_FLAGSTAT.out.flagstat >> "encode/alignments/flagstats/filtered"

	emit:
	bam            = ch_filtered
	bai            = ch_filtered_bai
	picard_metrics = ch_picard_metrics
	sambamba_log   = ch_sambamba_log
	flagstat       = SAMTOOLS_FLAGSTAT.out.flagstat
	markdup_bam	   = ch_markdup

}