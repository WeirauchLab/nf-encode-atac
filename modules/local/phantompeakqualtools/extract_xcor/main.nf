process EXTRACT_XCOR {
	tag "${meta.id}"
	cpus   = {1 * task.attempt}
	memory = {16.GB * task.attempt}
	time   = {2.h * task.attempt}

	conda "${moduleDir}/environment.yml"
	container "community.wave.seqera.io/library/r-argparse_r-tidyverse:9c26b9d2451d2c78"

	input:
	tuple val(meta), path(rdata)

	output:
	tuple val(meta), path("*.crosscorr.csv"), optional: false, emit: csv, topic: spp_xcorr
	//tuple val(task.process), val("R"), eval("R --version | head -n 1 | sed 's/R version //'")             , topic: versions

	script:
	def prefix = task.ext.prefix ?: "${meta.id}"
	def args = task.ext.args ?: ""
	"""
	#!/usr/bin/env Rscript

	library(tidyverse)
	load("${rdata}")

	tibble::as_tibble(crosscorr[["cross.correlation"]]) |>
		dplyr::mutate(
			sample_id = "${meta.id}"
		) |>
		dplyr::relocate(sample_id, .before = everything()) |>
		dplyr::rename("shift" = "x","correlation" = "y") |>
		dplyr::mutate(
			normalized = correlation - min(correlation),
			normalized = normalized / max(normalized)
		) |>
		readr::write_csv("${prefix}.crosscorr.csv", col_names = TRUE)


	"""
}