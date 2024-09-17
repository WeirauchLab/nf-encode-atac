process PICARD_MARKDUPLICATES {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "quay.io/biocontainers/picard:3.1.1--hdfd78af_0"

	input:
	tuple val(meta), path(bam)
	//tuple val(meta2), path(fasta)
	//tuple val(meta3), path(fai)

	output:
	tuple val(meta), path("*.bam")        , optional: true, emit: bam
	tuple val(meta), path("*.metrics.txt"), optional: true, emit: metrics, topic: picard_markduplicates_log
	tuple val(task.process), val("picard"), eval("picard MarkDuplicates --version 2>&1 | grep 'Version:' | sed 's/Version://'")             , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}.dupmarked"
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
		MarkDuplicates \\
		--INPUT $bam \\
		--OUTPUT ${prefix}.bam \\
		--METRICS_FILE ${prefix}.MarkDuplicates.metrics.txt \\
		--VALIDATION_STRINGENCY LENIENT \\
		--REMOVE_DUPLICATES FALSE \\
		--ASSUME_SORTED TRUE \\
		$args
	"""
}