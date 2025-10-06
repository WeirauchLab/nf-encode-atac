process TXDBMAKER_MAKETXDBFROMGFF {
	tag "$meta.id"

	cpus {1 * task.attempt}
	memory {16.GB * task.attempt}
	time {1.h * task.attempt}

	container "community.wave.seqera.io/library/bioconductor-annotationdbi_bioconductor-txdbmaker_r-argparse_r-tidyverse:2206aadab047620a"

	input:
	tuple val(meta), path(gff)
	path chrsizes

	output:
	tuple val(meta), path("*.sqlite"), emit: txdb
	tuple val(task.process), path("versions.yaml"), emit: versions

	script:
	def prefix = task.ext.prefix ?: meta.id
	def args = task.ext.args ?: ""
	def chrsizes_arg = chrsizes ? "--chrsizes ${chrsizes}" : ""
	"""
	maketxdbfromgff.R \\
		--input ${gff} \\
		--prefix ${prefix} \\
		--versions-yaml versions.yaml \\
		${chrsizes_arg} \\
		${args}
	"""

	stub:
	def prefix = task.ext.prefix ?: meta.id
	"""
	touch ${prefix}.sqlite
	touch versions.yaml
	"""
}