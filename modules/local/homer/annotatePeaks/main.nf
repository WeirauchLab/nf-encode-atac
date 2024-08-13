process HOMER_ANNOTATEPEAKS {
	tag "${meta.id}"

	cpus   = {16 * task.attempt}
	memory = {32.GB * task.attempt}
	time   = {24.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "quay.io/biocontainers/homer:4.9.1--pl5.22.0_5"

	input:
	tuple val(meta),  path(bed)
	tuple val(meta2), path(genome_fasta)
	tuple val(meta3), path(gtf)

	output:
	tuple val(meta), path("*_annotatePeaks.tsv"), optional: true, emit: tsv
	tuple val(meta), path("*_annStats.tsv")     , optional: true, emit: annStats
	tuple val(task.process), val("HOMER")       , val("4.9.1")  , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""

	"""
	annotatePeaks.pl \\
		${bed} \\
		${genome_fasta} \\
		-p ${task.cpus} \\
		${gtf ? "-gtf ${gtf}" : ""} \\
		${args} \\
		-annStats ${prefix}_annStats.tsv \\
		> ${prefix}_annotatePeaks.tsv
	sed -i '1s/^[^\t]*/PeakID/' ${prefix}_annotatePeaks.tsv
	"""
}