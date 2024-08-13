#!/usr/bin/env Rscript

library(argparse)

parser <- ArgumentParser()
parser$add_argument("--input",nargs = 1, type = "character")
parser$add_argument("--id", nargs = 1, type = "character")
parser$add_argument("--prefix",nargs = 1,default = "postproc")
opt <- parser$parse_args()

library(tidyverse)
library(cli)

OUTPUT_FILE <- paste0(opt$prefix,".tsv")

clean_homer_cols <- function(x){
	stringr::str_replace_all(
		tolower(x),
		pattern = c(
			"\\s?\\(.*?\\)" = "",
			"\\s|-" = "_",
			"#" = "n",
			"%" = "pct"
		)
	)
}

cli::cli_inform("Reading input file: {opt$input}")
results_df <- 
	readr::read_tsv(opt$input,col_names = T) |>
	dplyr::rename_with(clean_homer_cols) |>
	dplyr::mutate(
		id = opt$id,
		log10_p_value = log_p_value / log(10)
	) |>
	dplyr::relocate(id, .before = everything()) |>
	dplyr::relocate(log10_p_value, .after = "log_p_value") |>
	dplyr::arrange(log10_p_value) |>
	dplyr::mutate(
		rank = dplyr::row_number()
	)

cli::cli_inform("exporting results to: {OUTPUT_FILE}")
readr::write_tsv(results_df, OUTPUT_FILE, col_names = T)
