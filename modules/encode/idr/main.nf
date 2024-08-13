process IDR_PEAKS {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/bedtools_bionumpy_idr:bbfce8dd45f2b8eb"

	input:
	tuple val(meta), path(peak1), path(peak2), path(peak3)
	val rank
	val idr_threshold

	output:
	tuple val(meta), path("*.idr-thresh.narrowPeak")  , optional: true, emit: narrowPeak
	tuple val(meta), path("*.unthresholded-peaks.png"), optional: true, emit: png
	tuple val(task.process), val("idr")     , eval("idr --version | head -n 1 | sed 's/IDR //'")                    , topic: versions
	tuple val(task.process), val("awk")     , eval("awk -Wversion | sed '1!d; s/.*Awk //; s/,.*//'")                , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def available_ranks = ["signal.value": 7, "p.value": 8, "q.value": 9]
	def rank_id = available_ranks[rank]
	def negative_log10_thresh = -Math.log10(idr_threshold)
	"""
	idr \\
		--peak-list ${peak1} \\
		--samples ${peak2} ${peak3} \\
		--input-file-type narrowPeak \\
		--output-file ${prefix}.unthresholded-peaks.txt \\
		--rank ${rank} \\
		--soft-idr-threshold ${idr_threshold} \\
		--plot
	
	mv ${prefix}.unthresholded-peaks.txt.png ${prefix}.unthresholded-peaks.png
	cat ${prefix}.unthresholded-peaks.txt \\
		| awk 'BEGIN{OFS="\\t"} \$12 >= ${negative_log10_thresh} {if (\$2<0) \$2=0; print \$1,\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9,\$10}' \\
		| sort | uniq | sort -k1,1 -k2,2n \\
		> ${prefix}.idr-thresh.narrowPeak

	"""
}