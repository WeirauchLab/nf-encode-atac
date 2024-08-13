process BOWTIE2_ALIGN {
	tag "${meta.id}"
	cpus   = {16 * task.attempt}
	memory = {64.GB * task.attempt}
	time   = {12.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/bowtie2_samtools:5ffb83f41ffa0c0e"

	input:
	tuple val(meta) , path(fastq)
	tuple val(meta2), path(fasta)
	tuple val(meta3), path(index)

	output:
	tuple val(meta), path("*.bam")        , optional: false, emit: bam
	tuple val(meta), path("*.bai")        , optional: false, emit: bai
	tuple val(meta), path("*.bowtie2.log"), optional: false, emit: log, topic: bowtie2_align_log
	tuple val(task.process), val("bowtie2") , eval("bowtie2 --version | head -n 1 | sed 's/^.*version //'") , topic: versions
	tuple val(task.process), val("samtools"), eval("samtools --version | head -n 1 | sed 's/^samtools //'") , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	def index_prefix = index[0].toString() - ~/(\.rev)?\.[0-9]+\.bt2$/
	def fastq_args = meta.single_end ? "-U ${fastq}" : "-1 ${fastq[0]} -2 ${fastq[1]}"
	"""
	bowtie2 \\
		--threads ${task.cpus} \\
		-x ${index_prefix} \\
		${fastq_args} \\
		${args} \\
		2> >(tee ${prefix}.bowtie2.log >&2) \\
	| samtools view -1 -S /dev/stdin \\
	| samtools sort -@ ${task.cpus} -o ${prefix}.bam
	samtools index ${prefix}.bam
	"""
}