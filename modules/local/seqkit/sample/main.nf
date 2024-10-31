process SEQKIT_SAMPLE {
	tag "${meta.id}"

	cpus   = {4 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {4.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/seqkit:2.8.2--7c9bea727f240b8e"

	input:
	tuple val(meta), path(fastq)

	output:
	tuple val(meta), path("*.fastq.gz"), optional: false, emit: fastq
	tuple val(meta), path("*.tsv"), optional: false, emit: tsv

	// version strings
	tuple val(task.process), val("seqkit") , eval("seqkit version | sed 's/seqkit v//'"), topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	if (meta.single_end) {
		"""
		seqkit sample \\
			-o ${prefix}.sub.fastq.gz \\
			--threads ${task.cpus} \\
			${args} \\
			${fastq}
		
		# collect metrics
		seqkit stats \\
			-T \\
			--threads ${task.cpus} \\
			${fastq} \\
			${prefix}.sub.fastq.gz \\
		> ${prefix}_stats.tsv
		"""
	} else {
		"""
		seqkit sample \\
			-o ${prefix}_1.sub.fastq.gz \\
			--threads ${task.cpus} \\
			${args} \\
			${fastq[0]}

		seqkit sample \\
			-o ${prefix}_2.sub.fastq.gz \\
			--threads ${task.cpus} \\
			${args} \\
			${fastq[1]}
		
		# collect metrics
		seqkit stats \\
			-T \\
			--threads ${task.cpus} \\
			${fastq} \\
			${prefix}_1.sub.fastq.gz \\
			${prefix}_2.sub.fastq.gz \\
			> ${prefix}_stats.tsv

		"""
	}
	
}