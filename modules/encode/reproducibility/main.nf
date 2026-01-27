process ENCODE_REPRODUCIBILITY {
	tag "${meta.group}"
	cpus { 1 * task.attempt }
	memory { 16.GB * task.attempt }
	time { 2.h * task.attempt }

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/python:3.12.3--827621ec7ad46bfc"

	input:
	tuple val(meta), path("Nt/*"), path("Np/*"), path("Peaks/*")

	output:
	tuple val(meta), path("*_peak_counts.csv"), optional: true, emit: peak_counts_csv
	tuple val(meta), path("*_stats.csv"), optional: true, emit: stats_csv
	tuple val(meta), path("*_stats.json"), optional: true, emit: stats_json, topic: encode_reproducibility_json
	tuple val(meta), path("*_optimal.narrowPeak"), optional: true, emit: optimal
	tuple val(meta), path("*_conservative.narrowPeak"), optional: true, emit: conservative
	tuple val(task.process), val("python"), eval("python --version | sed 's/Python //'"), topic: versions

	script:
	def mode_arg = meta.reproducibility_mode ? "--mode ${meta.reproducibility_mode}" : ""
	def sample_arg = meta.group ? "--sample ${meta.group}" : ""
	"""
	reproducibility_stats.py \\
		${mode_arg} \\
		${sample_arg} \\
		--Nt Nt \\
		--Np Np \\
		--peaks Peaks
	"""
}
