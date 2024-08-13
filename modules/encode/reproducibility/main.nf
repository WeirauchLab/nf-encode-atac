process ENCODE_REPRODUCIBILITY {
	tag "${meta.group}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/python:3.12.3--827621ec7ad46bfc"

	input:
	tuple val(meta), path(nt_peaks), path(np_peaks), path(rep_peaks)
	output:
	tuple val(meta), path("*_peak_counts.csv")         , optional: true, emit: peak_counts_csv
	tuple val(meta), path("*_stats.csv")               , optional: true, emit: stats_csv
	tuple val(meta), path("*_stats.json")              , optional: true, emit: stats_json, topic: encode_reproducibility_json
	tuple val(meta), path("*.narrowPeak")              , optional: true, emit: peaks
	tuple val(meta), path("*_optimal.narrowPeak")      , optional: true, emit: optimal
	tuple val(meta), path("*_conservative.narrowPeak") , optional: true, emit: conservative
	tuple val(task.process), val("python")          , eval("python --version | sed 's/Python //'")                                       , topic: versions


	script:
	def nt_arg = nt_peaks ? "--Nt $nt_peaks" : ""
	def np_arg = np_peaks ? "--Np $np_peaks" : ""
	def rep_arg = rep_peaks ? "--peaks $rep_peaks" : ""
	"""
	reproducibility_stats.py \\
		--mode ${meta.mode} \\
		--sample ${meta.group} \\
		${nt_arg} \\
		${np_arg} \\
		${rep_arg}
	"""
}