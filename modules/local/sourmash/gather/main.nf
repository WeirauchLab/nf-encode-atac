process SOURMASH_GATHER {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/sourmash:4.8.8--c9498e42d55d50e1"

	input:
	tuple val(meta), path(sketch)
	path db

	output:
	tuple val(meta), path("*.csv"), optional: true, emit: csv, topic: sourmash_gather_csv
	tuple val(task.process), val("sourmash"), eval("sourmash --version | sed 's/sourmash //'")             , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	sourmash gather ${sketch} ${db} \\
		--output ${prefix}_matches.csv \\
		${args}
		#--save-matches ${prefix}_matches.zip
	"""
}