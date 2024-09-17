process GAWK_READLENGTHS {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/gawk:5.3.0--fee4ad759a5f7c5f"

	input:
	tuple val(meta), path(fastq)
	val n_reads

	output:
	tuple val(meta), path("*.readlengths.txt"), optional: false, emit: txt
	tuple val(task.process), val("zcat") , eval("zcat --version | head -n 1 | sed 's/zcat (gzip) //'") , topic: versions
	tuple val(task.process), val("awk")  , eval("awk -Wversion | sed '1!d; s/.*Awk //; s/,.*//'")      , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	def total_lines = n_reads ? "&& NR<=${n_reads * 4}" : ""
	"""
	zcat ${fastq} | awk 'NR%4==2 ${total_lines} {if (length(\$0) > max) max = length(\$0)} END {print max}' > ${prefix}.readlengths.txt
	"""
}