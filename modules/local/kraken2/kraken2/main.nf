process KRAKEN2_KRAKEN2 {
	tag "${meta.id}"
	cpus   = {6 * task.attempt}
	memory = {80.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/kraken2:2.1.3--517e0e9dce07cd35"

	input:
	tuple val(meta), path(fastq)
	tuple val(meta2), path(db)

	output:
	tuple val(meta), path("*.kraken2.report"), optional: true, emit: report
	tuple val(task.process), val("kraken2"), eval("kraken2 --version | head -n 1 | sed 's/Kraken version //'")             , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	kraken2 \\
		--db ${db} \\
		--threads ${task.cpus} \\
		--report ${prefix}.kraken2.report \\
		${!meta.single_end ? "--paired" : ""} \\
		${args} \\
		${fastq}
	"""
}
