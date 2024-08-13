
// based on nf-cores untar module
// https://github.com/nf-core/rnaseq/blob/master/modules/nf-core/untar/main.nf

process TAR_UNTAR {
	tag "${meta.id}"

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/tar:1.34--15635e63fb576888"

	input:
	tuple val(meta), path(tar)

	output:
	tuple val(meta), path("${prefix}"), optional: true, emit: contents

	script:
	def prefix = task.ext.prefix ?: (meta.id ? "${meta.id}" : tar.baseName.toString().replaceFirst(/(\.tar|\.tar\.gz)$, "") )
	def args = task.ext.args ?: ""
	"""
	tar \\
		-xav \\
		${args} \\
		-C ${prefix} \\
		-f \\
		${tar}
	"""
}