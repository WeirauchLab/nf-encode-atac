#!/usr/bin/env Rscript
library(cli)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("-i", "--gtf")
parser$add_argument("-f", "--filters", default = NULL)
parser$add_argument("-o", "--output", default = "tss.bed")
parser$add_argument("-F", "--output-format", default = "bed")
parser$add_argument("--id-col", default = NULL)

opt <- parser$parse_args()

library(tidyverse)
library(rtracklayer)


report_inputs <- function(opt) {
    cli_h1("script inputs")
    ul <- cli_ul()
    for (i in names(opt)) {
        cli_li("{i}: {opt[[i]]}")
    }
    cli_end(ul)
    cli_rule()
}

report_inputs(opt)

cli_h1("Processing")
if (!file.exists(opt$gtf)) cli_abort("GTF file not found! File: {opt$gtf}")
cli_alert_success("GTF file exists: {.file {opt$gtf}}")

cli_alert_info("Reading GTF file")
gtf <- import.gff2(opt$gtf)
gtf$score[is.na(gtf$score)] <- 0


gtf_filters <-
    str_split(opt$filters, ",") |>
    unlist() |>
    map(
        ~ unlist(str_split(.x, ":"))
    )
if (length(gtf_filters) > 0) {
    gtf_filters <-
        set_names(
            map(gtf_filters, ~ .x[-1]),
            map_chr(gtf_filters, ~ .x[1])
        )
}


cli_inform("Filtering GTF...")
gtf_filtered <- gtf

purrr::iwalk(
    gtf_filters,
    function(filter_vec, column_id) {
        gtf_cols <- names(mcols(gtf_filtered))
        if (!column_id %in% gtf_cols) {
            cli_warn("GTF filter was supplied, but the column was not found in the gtf. Skipping. Supplied column: {column_id}. Avaliable columns: {gtf_cols}")
            return(NULL)
        }
        keep_idx <- which(mcols(gtf_filtered)[[column_id]] %in% filter_vec)
        gtf_filtered <<- gtf_filtered[keep_idx]
        cli_inform("Retained {length(gtf_filtered)} records after applying filter: {column_id} in [{filter_vec}]")
    }
)

cli_inform("Final region number: {length(gtf_filtered)}")
if (length(gtf_filtered) == 0) {
    cli_abort("No eligible regions found using the filter criteria! Cannot continue.")
}

cli_inform("Restricting regions to their start position.")
gtf_filtered <- resize(gtf_filtered, width = 1, fix = "start")

if (!is.null(opt$id_col)) {
    cli_inform("Setting names to {opt$id_col}")
    if (!opt$id_col %in% names(mcols(gtf_filtered))) {
        cli_warn("Column {opt$id_col} not found in the GTF file!")
    } else {
        gtf_filtered <- setNames(gtf_filtered, mcols(gtf_filtered)[[opt$id_col]])
    }
}

cli_alert_info("Writing results to: {opt$output}")
rtracklayer::export(object = gtf_filtered, con = opt$output, format = opt$output_format)
cli_alert_success("Done! Total regions written: {length(gtf_filtered)}")
