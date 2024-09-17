process DEEPTOOLS_BAMCOVERAGE {
	tag "${meta.id}"

	cpus   = {4 * task.attempt}
	memory = {12.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/deeptools:3.5.5--0929777992a8c4c6"

	input:
	tuple val(meta), path(bam), path(bai)

	output:
	tuple val(meta), path("*.bw"), optional: true, emit: bigwig
	tuple val(task.process), val("deeptools"), eval("deeptools --version | head -n 1 | sed 's/^deeptools //'"), topic: versions

	script:
	def args = task.ext.args ?: ""
	def prefix = task.ext.prefix ?: "${meta.id}_normalized"
	"""
	bamCoverage \\
		--bam ${bam} \\
		--outFileName ${prefix}.bw \\
		--outFileFormat bigwig \\
		--numberOfProcessors ${task.cpus} \\
		${args}
	"""
}