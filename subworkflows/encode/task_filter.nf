include { RM_LOWQ_READS                   } from '../../modules/encode/rm_lowq_reads/main'
include { PICARD_MARKDUPLICATES           } from '../../modules/local/picard/markDuplicates/main'
include { PICARD_COLLECTINSERTSIZEMETRICS } from '../../modules/local/picard/CollectInsertSizeMetrics/main'
include { SAMBAMBA_MARKDUP                } from '../../modules/local/sambamba/markdup/main'
include { RM_DUPLICATES                   } from '../../modules/encode/rm_dup/main'
include { SAMTOOLS_INDEX                  } from "../../modules/local/samtools/index/main"
include { SAMTOOLS_FLAGSTAT               } from "../../modules/local/samtools/flagstats/main"
include { MTNUCRATIO_MTNUCRATIO           } from "../../modules/local/mtnucratio/mtnucratio/main"

workflow TASK_FILTER {
	take:
	ch_bam                        // channel: [ val(meta), path(bam) ]
	mapq_threshold                // integer or []
	markdup_method                // "picard" or "sambamba"
	skip_rm_lowq_reads            // boolean
	skip_rm_duplicates            // boolean
	skip_collectinsertsizemetrics // boolean
	ch_mito_chr_name              // string

	main:

	if (!skip_rm_lowq_reads && mapq_threshold) {
		RM_LOWQ_READS(
			ch_bam,
			mapq_threshold,
		)
		ch_lowq_filtered = RM_LOWQ_READS.out.bam
	}
	else {
		ch_lowq_filtered = ch_bam
	}

	ch_picard_metrics = Channel.empty()
	ch_sambamba_log = Channel.empty()
	ch_markdup = Channel.empty()
	if (markdup_method == "picard") {
		PICARD_MARKDUPLICATES(
			ch_lowq_filtered
		)
		ch_markdup = PICARD_MARKDUPLICATES.out.bam
		ch_picard_metrics = PICARD_MARKDUPLICATES.out.metrics
	}
	else if (markdup_method == "sambamba") {
		SAMBAMBA_MARKDUP(
			ch_lowq_filtered
		)
		ch_markdup = SAMBAMBA_MARKDUP.out.bam
		ch_sambamba_log = SAMBAMBA_MARKDUP.out.log
	}
	else {
		ch_markdup = ch_lowq_filtered
	}

	if (!skip_rm_duplicates) {
		RM_DUPLICATES(
			ch_markdup
		)
		ch_filtered = RM_DUPLICATES.out.bam
	}
	else {
		ch_filtered = ch_markdup
	}

	ch_insertsizes = Channel.empty()
	ch_insertsizes_histogram = Channel.empty()
	if (!skip_collectinsertsizemetrics) {
		ch_filtered
			| filter { meta, bam -> !meta.single_end }
			| PICARD_COLLECTINSERTSIZEMETRICS
		ch_insertsizes = PICARD_COLLECTINSERTSIZEMETRICS.out.insertsizes
		ch_insertsizes_histogram = PICARD_COLLECTINSERTSIZEMETRICS.out.histogram
	}

	ch_mtnuc_json = Channel.empty()
	ch_mtnuc_ratio = Channel.empty()
	if (ch_mito_chr_name) {
		MTNUCRATIO_MTNUCRATIO(ch_filtered, ch_mito_chr_name)
		ch_mtnuc_json = MTNUCRATIO_MTNUCRATIO.out.json
		ch_mtnuc_ratio = MTNUCRATIO_MTNUCRATIO.out.mtnucratio
	}

	SAMTOOLS_INDEX(ch_filtered)
	ch_filtered_bai = SAMTOOLS_INDEX.out.bai

	SAMTOOLS_FLAGSTAT(ch_filtered)

	emit:
	bam                   = ch_filtered
	bai                   = ch_filtered_bai
	picard_metrics        = ch_picard_metrics
	sambamba_log          = ch_sambamba_log
	flagstat              = SAMTOOLS_FLAGSTAT.out.flagstat
	markdup_bam           = ch_markdup
	insertsizes           = ch_insertsizes
	insertsizes_histogram = ch_insertsizes_histogram
	mtnuc_json            = ch_mtnuc_json
	mtnuc_ratio           = ch_mtnuc_ratio
}
