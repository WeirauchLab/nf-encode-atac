process RM_DUPLICATES {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464"

	input:
	tuple val(meta), path(bam)

	output:
	tuple val(meta), path("*.bam"), optional: false, emit: bam
	tuple val(task.process), val("samtools")        , eval("samtools --version | head -n 1 | sed 's/^samtools //'")                      , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}.nodup"
	def args = task.ext.args ?: ""
	if(meta.single_end){
		"""
		samtools view \\
			-F 1804 \\
			-b ${bam} \\
			> ${prefix}.bam
		"""
	}
	else {
		"""
		samtools view \\
			-F 1804 \\
			-f 2 \\
			-b ${bam} \\
			> ${prefix}.bam
		"""
	}

}