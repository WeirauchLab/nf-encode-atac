process HOMER_FINDMOTIFSGENOME {
	tag "${meta.id}"

	cpus   = {16 * task.attempt}
	memory = {32.GB * task.attempt}
	time   = {24.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "quay.io/biocontainers/homer:4.9.1--pl5.22.0_5"

	input:
	tuple val(meta),  path(bed)
	tuple val(meta2), path(genome_fasta)
	path motif_lib

	output:
	tuple val(meta), path("*_knownResults.txt") , optional: true, emit: knownResults
	tuple val(meta), path("*_knownResults.html"), optional: true, emit: knownResults_html
	tuple val(meta), path("*_homerResults.html"), optional: true, emit: homerResults_html
	tuple val(meta), path("*.tar.gz")           , optional: true, emit: tar
	tuple val(task.process), val("HOMER")       , val("4.9.1")  , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""

	"""
	findMotifsGenome.pl \\
		${bed} \\
		${genome_fasta} \\
		${prefix} \\
		-p ${task.cpus} \\
		-preparsedDir preparsed \\
		-preparse \\
		${motif_lib ? "-mknown ${motif_lib}" : ""} \\
		${args}
	
	tar -zcvf ${prefix}.tar.gz ${prefix}

	if [ -f "${prefix}/homerResults.html" ]; then 
		cp "${prefix}/homerResults.html" ${prefix}_homerResults.html
	fi
	if [ -f "${prefix}/knownResults.txt" ]; then 
		cp "${prefix}/knownResults.txt" ${prefix}_knownResults.txt
	fi
	if [ -f "${prefix}/knownResults.html" ]; then 
		cp "${prefix}/knownResults.html" ${prefix}_knownResults.html
	fi

	rm -rf preparsed ${prefix}

	"""
}