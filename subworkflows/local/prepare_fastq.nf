
include { CAT_FASTQ                       } from "../../modules/nf-core/cat/fastq/main"
include { GAWK_READLENGTHS                } from '../../modules/local/gawk/readlengths/main'
include { FASTQC as FASTQC_RAW            } from '../../modules/nf-core/fastqc/main'
include { FASTQC as FASTQC_TRIMMED        } from '../../modules/nf-core/fastqc/main'
include { FASTP_FASTP                     } from '../../modules/local/fastp/fastp/main'
include { SEQKIT_SAMPLE                   } from '../../modules/local/seqkit/sample/main'

workflow PREPARE_FASTQ {
	take:
	ch_fastq              // [ [meta], [fastq1, fastq2] ]
	skip_adapter_trimming // boolean
	save_trimmed_fastq	  // boolean
	save_subsampled_fastq // boolean

	main:

	ch_fastq
		.groupTuple(by: 0)
		.branch{meta, fq ->
			multiple: fq.size() > 1
                return [meta, fq.flatten()]
			single: fq.size() == 1
                return [meta, fq.flatten()]
		}
		.set {ch_fastq_branched}
	
	
	CAT_FASTQ(ch_fastq_branched.multiple)

	CAT_FASTQ.out.reads
		.mix(ch_fastq_branched.single)
		.set {ch_fastq_concat}
	
	ch_fastq_concat
		| branch {meta, fq ->
			subsample: meta.subsample_prop < 1
			no_subsample: meta.subsample_prop == 1
		}
		| set {ch_fastq_subsample_branches}

	ch_seqkit_tsv = Channel.empty()
	ch_subsampled_fastq = Channel.empty()
	SEQKIT_SAMPLE(ch_fastq_subsample_branches.subsample)
	ch_subsampled_fastq = SEQKIT_SAMPLE.out.fastq

	ch_subsampled_fastq
		.mix(ch_fastq_subsample_branches.no_subsample)
		.set {ch_fastq_concat_subsampled}
	ch_seqkit_tsv = SEQKIT_SAMPLE.out.tsv

	FASTQC_RAW(ch_fastq_concat_subsampled)
	
	if(skip_adapter_trimming) {
		ch_fastp_json         = Channel.empty()
		ch_fastp_html         = Channel.empty()
		ch_fastqc_trimmed     = Channel.empty()
		ch_fastqc_trimmed_zip = Channel.empty()
		ch_fastq_output	      = ch_fastq_concat_subsampled
	} else {
		FASTP_FASTP(
			ch_fastq_concat_subsampled
		)
        ch_fastq_output = FASTP_FASTP.out.fastq
		ch_fastp_json = FASTP_FASTP.out.json
		ch_fastp_html = FASTP_FASTP.out.html

		FASTQC_TRIMMED(ch_fastq_output)
		ch_fastqc_trimmed     = FASTQC_TRIMMED.out
		ch_fastqc_trimmed_zip = FASTQC_TRIMMED.out.zip
	}

	publish:
	FASTQC_RAW.out       >> "fastqc/raw"
	ch_fastqc_trimmed    >> "fastqc/trimmed"
	ch_fastp_json        >> "fastp"
	ch_fastp_html        >> "fastp"
	ch_fastq_output      >> (save_trimmed_fastq ? "fastq/trimmed" : null)
	ch_seqkit_tsv        >> "seqkit"
	ch_subsampled_fastq  >> (save_subsampled_fastq ? "fastq/subsampled" : null)

	emit:
	fastq              = ch_fastq_output
	fastqc_raw_zip     = FASTQC_RAW.out.zip
	fastqc_trimmed_zip = ch_fastqc_trimmed_zip
	fastp_json         = ch_fastp_json
	fastp_html         = ch_fastp_html
	seqkit_tsv         = ch_seqkit_tsv
}