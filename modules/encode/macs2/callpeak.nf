process MACS2_CALLPEAK {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/bedtools_macs2_ucsc-bedgraphtobigwig:831ad901e42b7721"

	input:
	tuple val(meta), path(ta), path(ctl_ta)
	tuple val(meta2), path(fai)
	val gensz
	val max_peaks


	output:
	tuple val(meta), path("*.narrowPeak")       , optional: true, emit: narrowPeak
	tuple val(meta), path("*treat_pileup.bdg")  , optional: true, emit: treat_pileup
	tuple val(meta), path("*control_lambda.bdg"), optional: true, emit: control_lambda
	tuple val(task.process), val("macs2")           , eval("macs2 --version | head -n 1 | sed 's/macs2 //'")                             , topic: versions
	

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	macs2 callpeak \\
		-t ${ta} \\
		${ctl_ta ? "-c ${ctl_ta}" : ""} \\
		-n ${prefix} \\
		-g ${gensz} \\
		${args}
	
	sort -k 8gr,8gr ${prefix}_peaks.narrowPeak \\
		| awk 'BEGIN{OFS="\\t"} {\$4="PEAK_"NR; if (\$2<0) \$2=0; if (\$3<0) \$3=0; if (\$10==-1) \$10=\$2+int((\$3-\$2+1)/2.0); print \$0}' \\
		> tmp.narrowPeak \\
		&& mv tmp.narrowPeak ${prefix}_peaks.narrowPeak
	
	if [$max_peaks -gt 0]; then
		head -n ${max_peaks} ${prefix}_peaks.narrowPeak > tmp.narrowPeak \\
		&& mv tmp.narrowPeak ${prefix}_peaks.narrowPeak
	fi

	cut -f1,2 ${fai} > genome.sizes
	bedtools slop -i ${prefix}_peaks.narrowPeak -g genome.sizes -b 0 > tmp.narrowPeak \\
		&& mv tmp.narrowPeak ${prefix}_peaks.narrowPeak
	
	mv ${prefix}_peaks.narrowPeak ${prefix}.narrowPeak
	"""
}