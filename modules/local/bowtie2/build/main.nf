process BOWTIE2_BUILD {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/bowtie2_samtools:5ffb83f41ffa0c0e"

	input:
	tuple val(meta), path(fasta)

	output:
	tuple val(meta), path("*.bt2"), optional: false, emit: index
	tuple val(task.process), val("bowtie2") , eval("bowtie2 --version | head -n 1 | sed 's/^.*version //'") , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	bowtie2-build \\
		--threads ${task.cpus} \\
		${args} \\
		${fasta} \\
		${prefix}
	"""
}