process RUN_SPP {
	tag "${meta.id}"
	cpus { 1 * task.attempt }
	memory { 24.GB * task.attempt }
	time { 10.h * task.attempt }

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/phantompeakqualtools:1.2.2--f8026fe2526a5e18"

	input:
	tuple val(meta), path(ta)
	val mito_chr_name

	output:
	tuple val(meta), path("*.spp.out"), optional: false, emit: spp, topic: spp_log
	tuple val(meta), path("*.spp.pdf"), optional: false, emit: pdf
	tuple val(meta), path("*.spp.Rdata"), optional: false, emit: rdata
	tuple val(task.process), val("phantompeakqualtools"), val("1.2.2"), topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	def subsample_n_reads = task.ext.subsample_n_reads ?: 0
	def paired_flag = meta.single_end ? "" : "--paired"
	"""
	if [ ${subsample_n_reads} -gt 0 ]; then
		subsample_ta.py -i ${ta} -n ${subsample_n_reads} -o tmp.gz ${paired_flag}
		if [ -f tmp.gz ]; then
			mv tmp.gz ${ta}
		fi
	fi

	Rscript \\
		--max-ppsize=500000 \\
		\$(which run_spp.R) \\
		-rf \\
		-c=${ta} \\
		-p=${task.cpus} \\
		-filtchr="${mito_chr_name}" \\
		-savp=${prefix}.spp.pdf \\
		-out=${prefix}.spp.out \\
		-savd="${prefix}.spp.Rdata" \\
		${args}

	"""
}
