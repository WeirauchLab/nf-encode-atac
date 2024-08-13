process FASTQC_FASTQC {
	tag "${meta.id}"
	cpus   = {5 * task.attempt}
	memory = {32.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/fastqc:0.12.1--5cfd0f3cb6760c42"

	input:
	tuple val(meta), path(fastq1), path(fastq2)

	output:
	tuple val(meta), path("*.html"), optional: true, emit: html
	tuple val(meta), path("*.zip") , optional: true, emit: zip
	tuple val(task.process), val("FastQC") , eval("fastqc --version | head -n 1 | sed 's/FastQC v//'") , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	if (meta.single_end) {
		"""
		mv ${fastq1} ${prefix}_1.fastq.gz
		fastqc \\
			--threads ${task.cpus} \\
			${prefix}_1.fastq.gz
		"""
	} else {
		"""
		mv ${fastq1} ${prefix}_1.fastq.gz
		mv ${fastq2} ${prefix}_2.fastq.gz
		fastqc \\
			--threads ${task.cpus} \\
			${prefix}_1.fastq.gz ${prefix}_2.fastq.gz
		"""
	}
	
}
