process SAMBAMBA_MARKDUP {
	tag "${meta.id}"

	cpus   = {6 * task.attempt}
	memory = {24.GB * task.attempt}
	time   = {3.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/sambamba:1.0.1--18aa51da0053469f"

	input:
	tuple val(meta), path(bam)

	output:
	tuple val(meta), path("*_markdup.bam"), optional: false, emit: bam
	tuple val(meta), path("*.markdup.log"), optional: false, emit: log

	// version strings
	tuple val(task.process), val("sambamba") , eval("sambamba --version 2>&1 | awk '/sambamba/{print \$2;exit}'"), topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	sambamba markdup \\
		--nthreads ${task.cpus} \\
		--show-progress \\
		${args} \\
		${bam} \\
		${prefix}_markdup.bam \\
		> ${prefix}.markdup.log 2>&1
	"""
}