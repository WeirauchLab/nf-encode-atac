process UCSC_BEDTOBIGBED {
	tag "${meta.id}"

	cpus   = {1 * task.attempt}
	memory = {8.GB * task.attempt}
	time   = {1.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/ucsc-bedtobigbed:447--8d104b03cb049be4"

	input:
	tuple val(meta) , path(bed)
	tuple val(meta2), path(fai)

	output:
	tuple val(meta), path("*.bb"), optional: true, emit: bigbed

	// version strings
	tuple val(task.process), val("bedToBigBed") , eval("bedToBigBed 2>&1 | head -n1 | sed 's/bedToBigBed v. //;s/ -.*//'"), topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	cut -f1-3 ${bed} | sort -k1,1 -k2,2n > tmp.sorted.bed
	awk '{print \$1, \$2}' OFS=' ' ${fai} > tmp.chrom.sizes
	bedToBigBed \\
		tmp.sorted.bed \\
		tmp.chrom.sizes \\
		${prefix}.bb \\
		${args}

	rm -rf tmp.sorted.bed tmp.chrom.sizes
	"""
}