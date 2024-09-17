process HOMER_POSTPROC_FINDMOTIFSGENOME {
	tag "${meta.id}"

	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {1.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "quay.io/andvon/argparse_tidyverse:ef922d0"

	input:
	tuple val(meta), path(knownResults)

	output:
	tuple val(meta), path("*.tsv"), optional: true, emit: tsv
	tuple val(task.process), val("R"), eval("R --version | head -n 1 | sed 's/R version //;s/ .*//'")             , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}_knownResults"
	def args = task.ext.args ?: ""

	"""
	postproc_findmotifsgenome.R \\
		--input ${knownResults} \\
		--id "${meta.id}" \\
		--prefix ${prefix}
	"""

}