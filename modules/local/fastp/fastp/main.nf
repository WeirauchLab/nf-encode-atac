process FASTP_FASTP {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/fastp:0.23.4--4d9e23447c67e79e"

	input:
	tuple val(meta), path(fastq)

	output:
	tuple val(meta), path("*.fastp.fastq.gz"), optional: true, emit: fastq
	tuple val(meta), path("*.json")          , optional: true, emit: json, topic: fastp_json
	tuple val(meta), path("*.html")          , optional: true, emit: html, topic: fastp_html
	tuple val(task.process), val("fastp") , eval("fastp --version 2>&1 | head -n 1 | sed 's/fastp //'") , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	if (meta.single_end){
		"""
		# snippet from nf-core's fastp module
		[ ! -f  ${prefix}.fastq.gz ] && ln -sf $fastq ${prefix}.fastq.gz

		fastp \\
			--in1 ${prefix}.fastq.gz \\
			--out1 ${prefix}.fastp.fastq.gz \\
			--json ${prefix}.fastp.json \\
			--html ${prefix}.fastp.html \\
			--thread ${task.cpus} \\
			${args}
		"""
	} else {
		"""
		# snippet from nf-core's fastp module
		[ ! -f  ${prefix}_1.fastq.gz ] && ln -sf ${fastq[0]} ${prefix}_1.fastq.gz
		[ ! -f  ${prefix}_2.fastq.gz ] && ln -sf ${fastq[1]} ${prefix}_2.fastq.gz

		fastp \\
			--in1 ${prefix}_1.fastq.gz \\
			--out1 ${prefix}_1.fastp.fastq.gz \\
			--in2 ${prefix}_2.fastq.gz \\
			--out2 ${prefix}_2.fastp.fastq.gz \\
			--json ${prefix}.fastp.json \\
			--html ${prefix}.fastp.html \\
			--thread ${task.cpus} \\
			${args}
		"""
	}
	
}