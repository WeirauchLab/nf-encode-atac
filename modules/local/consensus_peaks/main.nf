process CONSENSUS_PEAKS {
	tag "$meta.id"

	cpus { 1 }
	memory { 8.GB * task.attempt }
	time { 2.h * task.attempt }

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/bioconductor-genomicranges_bioconductor-rtracklayer_r-argparse_r-box_pruned:47fa0392d5d3b482"

	input:
	tuple val(meta), path(master_peaks), path(rep_peaks)
	output:
	tuple val(meta), path("*.{bed,narrowPeak,broadPeak}"), emit: peaks
	tuple val(meta), path("*.csv"), optional: true, emit: matrix_csv
	tuple val(meta), path("*.json"), optional: true, emit: json
	tuple val(meta), path("*.txt"), optional: true, emit: sessinfo

	script:
	def prefix = task.ext.prefix ?: "${meta.id}_consensus"
	def args = task.ext.args ?: ""
	"""
	consensus_peaks.R \\
		--prefix "${prefix}" \\
		-a ${master_peaks} \\
		-b ${rep_peaks} \\
		${args}
	"""

	stub:
	def prefix = task.ext.prefix ?: "${meta.id}"
	"""
	"""

}