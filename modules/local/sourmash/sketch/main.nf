process SOURMASH_SKETCH {
	tag "${meta.id}"
	cpus   = {6 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {10.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/sourmash:4.8.8--c9498e42d55d50e1"

	input:
	tuple val(meta), path(fastq)

	output:
	tuple val(meta), path("*.sig.gz"), optional: true, emit: sketch
	tuple val(task.process), val("sourmash"), eval("sourmash --version | sed 's/sourmash //'")             , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	
	"""
	sourmash sketch dna \\
		--name ${prefix} \\
		-o ${prefix}.sig.gz \\
		${args} \\
		${fastq}
	"""
}