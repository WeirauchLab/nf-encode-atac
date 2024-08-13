include { BOWTIE2_ALIGN          } from '../../modules/local/bowtie2/align/main'
include { SAMTOOLS_INDEX         } from "../../modules/local/samtools/index/main"
include { SAMTOOLS_FLAGSTAT      } from "../../modules/local/samtools/flagstats/main"

workflow TASK_ALIGN {
	take:
	ch_fastq // [ val(meta), path(fastq1), path(fastq2) or [] ]
	ch_fasta // [ val(meta), path(fasta) ]
	aligner // "bowtie2"
	bowtie2_index // [ val(meta), path(index) ] OR []
	skip_align // boolean

	main:
	ch_bam = Channel.empty()
	ch_bai = Channel.empty()
	ch_bowtie2_log = Channel.empty()

	if(!skip_align && aligner == "bowtie2") {
		BOWTIE2_ALIGN(
			ch_fastq,
			ch_fasta,
			bowtie2_index
		)
		ch_bam         = BOWTIE2_ALIGN.out.bam
		ch_bowtie2_log = BOWTIE2_ALIGN.out.log
	}

	SAMTOOLS_INDEX(ch_bam)
	ch_bai = SAMTOOLS_INDEX.out.bai

	SAMTOOLS_FLAGSTAT(ch_bam)

	publish:
	ch_bam         >> "encode/alignments/raw"
	ch_bowtie2_log >> "encode/logs/bowtie2"
	SAMTOOLS_FLAGSTAT.out.flagstat >> "encode/alignments/flagstats/aligned"

	emit:
	bam         = ch_bam
	bai         = ch_bai
	bowtie2_log = ch_bowtie2_log
	flagstat    = SAMTOOLS_FLAGSTAT.out.flagstat

}