process RM_LOWQ_READS {
	tag "${meta.id}"
	cpus { 6 * task.attempt }
	memory { 16.GB * task.attempt }
	time { 4.h * task.attempt }

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464"

	input:
	tuple val(meta), path(bam)
	val mapq_threshold

	output:
	tuple val(meta), path("*.bam"), optional: false, emit: bam
	tuple val(task.process), val("samtools"), eval("samtools --version | head -n 1 | sed 's/^samtools //'"), topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}.lowq_filt"
	def args = task.ext.args ?: ""
	if (meta.single_end) {
		"""
		samtools view \\
			--threads ${task.cpus} \\
			-F 1804 \\
			${mapq_threshold ? "-q ${mapq_threshold}" : ""} \\
			-u ${bam} \\
		| samtools sort \\
			--threads ${task.cpus} \\
			-o ${prefix}.bam \\
			-T tmp_${prefix} \\
			/dev/stdin \\
		"""
	}
	else {
		"""
		samtools view \\
			--threads ${task.cpus} \\
			-F 1804 \\
			-f 2 \\
			${mapq_threshold ? "-q ${mapq_threshold}" : ""} \\
			-u ${bam} \\
		| samtools sort \\
			--threads ${task.cpus} \\
			-n \\
		| samtools fixmate \\
			--threads ${task.cpus} \\
			-r - - \\
		| samtools view \\
			--threads ${task.cpus} \\
			-F 1804 \\
			-f 2 \\
			-u \\
		| samtools sort \\
			--threads ${task.cpus} \\
			-o ${prefix}.bam \\
			-T tmp_${prefix}
		"""
	}

	stub:
	def prefix = task.ext.prefix ?: "${meta.id}.lowq_filt"
	def args = task.ext.args ?: ""
	"""
	touch ${prefix}.bam
	"""
}
