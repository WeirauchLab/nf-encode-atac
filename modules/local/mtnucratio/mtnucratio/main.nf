process MTNUCRATIO_MTNUCRATIO {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/mtnucratio:0.7--b8f559675ad2fcfc"

	input:
	tuple val(meta), path(bam)
	val chrM

	output:
	tuple val(meta), path("*.json")      , optional: false, emit: json, topic: mtnucratio_json
	tuple val(meta), path("*.mtnucratio"), optional: false, emit: mtnucratio

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	mtnucratio ${bam} ${chrM}
	"""
}