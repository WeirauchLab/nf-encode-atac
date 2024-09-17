process GZIP_GUNZIP {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/coreutils:9.5--25d2233f596a9d96"

	input:
	tuple val(meta), path(archive)

	output:
	tuple val(meta), path("$gunzipped"), optional: false, emit: gunzip
	tuple val(task.process), val("gzip")            , eval("gunzip --version | head -n 1 | sed 's/gunzip (gzip) //'")                               , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	gunzipped = archive.toString() - ~/.gz$/
	"""
	gunzip -c ${archive} > ${gunzipped}
	"""
}