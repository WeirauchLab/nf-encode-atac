process CAT_FASTQ {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/coreutils:9.5--25d2233f596a9d96"

	input:
	tuple val(meta), path(fastq1), path(fastq2)

	output:
	tuple val(meta), path("*_r1.fastq.gz"), optional: false, emit: fastq1
	tuple val(meta), path("*_r2.fastq.gz"), optional: true , emit: fastq2
	tuple val(task.process), val("cat"), eval("cat --version | head -n 1 | sed 's/cat (GNU coreutils) //'"), topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	cat ${fastq1} > ${prefix}_r1.fastq.gz
	${fastq2 ? "cat ${fastq2} > ${prefix}_r2.fastq.gz" : ""}
	"""
}