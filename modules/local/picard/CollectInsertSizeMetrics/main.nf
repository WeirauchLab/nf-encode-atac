process PICARD_COLLECTINSERTSIZEMETRICS {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/picard_r-base:6522cf91675edfb1"

	input:
	tuple val(meta), path(bam)

	output:
	tuple val(meta), path("*.insertsizes.txt"), optional: true, emit: insertsizes
	tuple val(meta), path("*.insertsizes.pdf"), optional: true, emit: histogram
	tuple val(task.process), val("picard"), eval("picard CollectInsertSizeMetrics --version 2>&1 | sed -n 's/Version://p'"), topic: versions
	tuple val(task.process), val("R")     , eval("R --version | sed -n '1s/R version //;s/\"//g;1p'")                      , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	// mem snippet adapted from nf-core module picard/markduplicates
	// https://github.com/nf-core/modules/blob/master/modules/nf-core/picard/markduplicates/main.nf
	def avail_mem = 3072
	if (task.memory){
		avail_mem = (task.memory.mega*0.8).intValue()
	}
	"""
	picard \\
		-Xmx${avail_mem}M \\
		CollectInsertSizeMetrics \\
		--INPUT $bam \\
		--OUTPUT ${prefix}.insertsizes.txt \\
		-H ${prefix}.insertsizes.pdf \\
		$args
	"""
}