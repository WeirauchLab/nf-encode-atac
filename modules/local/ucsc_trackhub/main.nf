process UCSC_TRACKHUB {
	tag "UCSC Trackhub"

	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/pydantic_python:ef418a61c42ac2fb"

	input:
	path "data/dt_bigwig/*"
	path "data/encode_bigwig/*"
	path "data/idr_peaks/*"
	path "data/overlap_peaks/*"

	output:
	path("data")   , includeInputs: true, optional: true, emit: data
	path("hub.txt"), optional: true, emit: hub

	// version strings
	tuple val(task.process), val("python")     , eval("python --version | sed 's/Python //'"), topic: versions
	tuple val(task.process), val("trackdb.py") , eval("trackdb.py -v")                       , topic: versions

	script:
	def args = task.ext.args ?: ""
	"""
	trackdb.py \\
		--dt_bigwig 'data/dt_bigwig/*' \\
		--encode_bigwig 'data/encode_bigwig/*' \\
		--idr_peaks 'data/idr_peaks/*' \\
		--overlap_peaks 'data/overlap_peaks/*' \\
		${args}
	"""
}