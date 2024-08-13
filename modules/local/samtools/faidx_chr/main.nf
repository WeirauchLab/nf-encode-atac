process SAMTOOLS_FAIDX_CHR {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464"

	input:
	tuple val(meta), path(fasta)
	val chr

	output:
	tuple val(meta), path("*.fasta")     , optional: false, emit: fasta
	tuple val(task.process), val("samtools")        , eval("samtools --version | head -n 1 | sed 's/^samtools //'")                      , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	samtools faidx ${fasta} ${chr} > ${prefix}.fasta
	"""
}