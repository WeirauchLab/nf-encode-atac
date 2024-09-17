process QFILTER_PEAKS {
	tag "${meta.id}"

	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/pandas:2.2.2--bd3db773995db54e"

	input:
	tuple val(meta), path(peak)

	output:
	tuple val(meta), path("*{.narrowPeak,.broadPeak,.bed}*"), optional: true, emit: peak

	// version strings
	//TODO: add version outputs
	//tuple val(task.process), val("tool") , eval("tool --version"), topic: versions

	script:
	def prefix = task.ext.prefix ?: "qfilt_${meta.id}"
	def args = task.ext.args ?: ""
	"""
	qfilter_peaks.py \\
		--input ${peak} \\
		--prefix ${prefix} \\
		${args}
	"""
}