process FILTER_PEAKS {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/pybedtools:0.10.0--d0fa50534b6e9b75"

	input:
	tuple val(meta), path(narrowPeak)
	tuple val(meta2), path(exclusion_peaks)
	val filter_pattern

	output:
	tuple val(meta), path("*.narrowPeak"), optional: false, emit: narrowPeak
	tuple val(task.process), val("bedtools"), eval("bedtools --version | sed 's/bedtools v//'")                     , topic: versions
	tuple val(task.process), val("grep")    , eval("grep --version | head -n 1 | sed 's/grep (GNU grep) //'")       , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}.excl_filt"
	def args = task.ext.args ?: ""
	def exclusion_peaks_arg = exclusion_peaks ? "--exclusion-peaks ${exclusion_peaks}" : ""
	def regex_arg = filter_pattern ? "--regex '${filter_pattern}'" : ""
	"""
	filter_peaks.py \\
		--input ${narrowPeak} \\
		--output ${prefix}.narrowPeak \\
		${exclusion_peaks_arg} \\
		${regex_arg}
	"""
}
