process DEEPTOOLS_PLOTFINGERPRINT {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/deeptools:3.5.5--0929777992a8c4c6"

	input:
	tuple val(meta), path(bam), path(bai)

	output:
	tuple val(meta), path("*_fingerprint.txt"), optional: true, emit: quality_metrics
	tuple val(meta), path("*_fingerprint.png"), optional: true, emit: png
	tuple val(meta), path("*_fingerprint.tab"), optional: true, emit: raw_counts
	tuple val(task.process), val("deeptools")       , eval("deeptools --version | head -n 1 | sed 's/^deeptools //'")                    , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	plotFingerprint \\
		-b ${bam} \\
		-o ${prefix}_fingerprint.png \\
		--outRawCounts ${prefix}_fingerprint.tab \\
		--outQualityMetrics ${prefix}_fingerprint.txt \\
		--numberOfProcessors ${task.cpus} \\
		${args}
	"""
}