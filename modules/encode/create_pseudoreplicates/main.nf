process CREATE_PSEUDOREPS {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {3.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/python:3.12.3--827621ec7ad46bfc"

	input:
	tuple val(meta), path(tagAlign)
	val pseudorep_seed

	output:
	tuple val(meta), path("*.tagAlign.gz"), optional: false, emit: tagAlign
	tuple val(meta), path("*pr1.tagAlign.gz"), optional: false, emit: pr1
	tuple val(meta), path("*pr2.tagAlign.gz"), optional: false, emit: pr2
	tuple val(task.process), val("python")    , eval("python --version | sed 's/Python //'")                  , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	def chunk_size = task.ext.chunk_size ?: 500000
	def paired_end_arg = meta.single_end ? "" : "--paired_end"
	"""
	create_pseudoreps.py \\
		--tagAlign ${tagAlign} \\
		--prefix ${prefix} \\
		--chunk_size ${chunk_size} \\
		${paired_end_arg} \\
		${args}
	"""
}