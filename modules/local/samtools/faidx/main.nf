process SAMTOOLS_FAIDX {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464"

	input:
	tuple val(meta), path(fasta)

	output:
	tuple val(meta), path("*.fai")       , optional: false, emit: fai

	// versions
	tuple val(task.process), val("samtools"), eval("samtools --version | head -n 1 | sed 's/^samtools //'"), topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	samtools faidx ${fasta}
	"""
}