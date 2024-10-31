#!/usr/bin/env Rscript
library(cli)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("-i", "--gtf")
parser$add_argument("-f", "--feature", default = "gene", choices = c("gene", "transcript"))
parser$add_argument("-o", "--output", default = "tss.bed")
parser$add_argument("-F", "--output-format", default = "bed")
parser$add_argument("-u", "--upstream", default = 1)
parser$add_argument("-d", "--downstream", default = 0)

opt <- parser$parse_args()

library(GenomicFeatures)
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

cli_alert_info("Reading GTF file into TxDb")
txdb <- makeTxDbFromGFF(opt$gtf)

feature_select <-
    switch(opt$feature,
        "gene" = GenomicFeatures::genes,
        "transcripts" = GenomicFeatures::transcripts
    )




if (!file.exists(opt$gtf)) cli_abort("GTF file not found: {.file {opt$gtf}}")
cli_alert_success("GTF file exists: {.file {opt$gtf}}")

cli_alert_info(text = "Subsetting {opt$feature} and setting promoter region to:")
tss <-
    feature_select(txdb) |>
    promoters(upstream = opt$upstream, downstream = opt$downstream) |>
    sort()

cli_alert_success("Isolated TSS regions. Total: {length(tss)}")

cli_alert_info("Writing results to: {opt$output}")
rtracklayer::export(object = tss, con = opt$output, format = opt$output_format)
cli_alert_success("Done! Total regions written: {length(tss)}")
