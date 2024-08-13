process CALC_PEAKSTATS {
	tag "${meta.id}"

	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {3.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/pybedtools:0.10.0--d0fa50534b6e9b75"

	input:
	tuple val(meta), path(bed), path(tagalign)

	output:
	tuple val(meta), path("*.json"), optional: false, emit: peakstats

	// version strings
	tuple val(task.process), val("bedtools")    , eval("bedtools --version | sed 's/bedtools v//'"), topic: versions
	tuple val(task.process), val("peakstats.py"), eval("peakstats.py --version")                   , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}.peakstats"
	def args = task.ext.args ?: ""
	"""
	peakstats.py \\
		--id ${meta.id} \\
		--group ${meta.group} \\
		--bed ${bed} \\
		--tagalign ${tagalign} \\
		--prefix ${prefix}
	"""
}