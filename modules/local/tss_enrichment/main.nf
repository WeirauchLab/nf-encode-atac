process TSS_ENRICHMENT {
	tag "${meta.id}"

	cpus   = {1 * task.attempt}
	memory = {24.GB * task.attempt}
	time   = {4.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/bioconductor-atacseqqc_bioconductor-plyranges_bioconductor-rtracklayer_r-argparse_r-tidyverse:564087ec8e3130e1"

	input:
	tuple val(meta), path(bam)
	tuple val(meta2), path(gtf)

	output:
	tuple val(meta), path("*_tss_enrichment.json"), optional: false, emit: json
	tuple val(meta), path("*_tss_signal.csv")     , optional: false, emit: csv

	// version strings
	//TODO: add version outputs
	//tuple val(task.process), val("tool") , eval("tool --version"), topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	tsse.R \\
		--bam ${bam} \\
		--gtf ${gtf} \\
		--prefix ${prefix} \\
		${args}
	"""
}