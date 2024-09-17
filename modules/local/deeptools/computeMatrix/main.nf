process DEEPTOOLS_COMPUTEMATRIX {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/deeptools:3.5.5--0929777992a8c4c6"

	input:
	tuple val(meta), path(bigwig), path(peaks)

	output:
	tuple val(meta), path("*.gz"), optional: true, emit: gz
	tuple val(task.process), val("deeptools")       , eval("deeptools --version | head -n 1 | sed 's/^deeptools //'")                    , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def dt_mode = task.ext.dt_mode ?: "reference-point"
	def args = task.ext.args ?: ""
	"""
	computeMatrix \\
		${dt_mode} \\
		--scoreFileName ${bigwig} \\
		--regionsFileName ${peaks} \\
		--outFileName ${prefix}.gz \\
		--numberOfProcessors ${task.cpus} \\
		${args}
	"""
}