process OVERLAP_PEAKS {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/bedtools:2.31.1--8fd0e3802b0dc02e"

	input:
	tuple val(meta), path(peak1), path(peak2), path(peak3)

	output:
	tuple val(meta), path("*.overlap.narrowPeak"), optional: true, emit: narrowPeak
	tuple val(task.process), val("bedtools"), eval("bedtools --version | sed 's/bedtools v//'"), topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def overlap_mode = task.ext.use_encode_overlap ?: false
	if(overlap_mode){
		"""	
		bedtools intersect \\
			-a <(bedtools sort -i $peak1) \\
			-b <(bedtools sort -i $peak2) \\
			-wo \\
		| awk 'BEGIN{FS="\\t";OFS="\\t"} {s1=\$3-\$2; s2=\$13-\$12; if ((\$21/s1 >= 0.5) || (\$21/s2 >= 0.5)) {print \$0}}' \\
		| cut -f 1-10 \\
		| sort \\
		| uniq \\
		| bedtools intersect \\
			-a stdin \\
			-b <(bedtools sort -i $peak3) \\
			-wo \\
		| awk 'BEGIN{FS="\\t";OFS="\\t"} {s1=\$3-\$2; s2=\$13-\$12; if ((\$21/s1 >= 0.5) || (\$21/s2 >= 0.5)) {print \$0}}' \\
		| cut -f 1-10 \\
		| sort \\
		| uniq \\
		> ${prefix}.overlap.narrowPeak
		"""
	} else {
		"""
		bedtools intersect \\
			-a <(bedtools sort -i $peak1) \\
			-b <(bedtools sort -i $peak2) \\
			-wa -u -f 0.5 -r \\
		| bedtools intersect \\
			-a stdin \\
			-b <(bedtools sort -i $peak3) \\
			-wa -u -f 0.5 -r \\
		> ${prefix}.overlap.narrowPeak
		"""
	}
}