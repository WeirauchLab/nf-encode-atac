#!/usr/bin/env Rscript

library(argparse)

parser <- ArgumentParser()
parser$add_argument("--bam")
parser$add_argument("--bed")
parser$add_argument("--upstream", default = 2000, type = "numeric")
parser$add_argument("--downstream", default = 2000, type = "numeric")
parser$add_argument("--width", default = 100, type = "numeric")
parser$add_argument("--endSize", default = 100, type = "numeric")
parser$add_argument("--step", default = 100, type = "numeric")
parser$add_argument("--pseudocount", default = 0, type = "numeric")
parser$add_argument("--paired", action = "store_true")
parser$add_argument("--prefix", default = "tsse")

opt <- parser$parse_args()

library(tidyverse)
library(rtracklayer)
library(ATACseqQC)
library(jsonlite)

regions <- import.bed(opt$bed)
bam <- readBamFile(bamFile = opt$bam, tag = character(0), asMates = opt$paired, bigFile = T)

tss_score <-
    TSSEscore(
        bam,
        regions,
        upstream = opt$upstream,
        downstream = opt$downstream,
        endSize = opt$endSize,
        width = opt$width,
        step = opt$step,
        pseudocount = opt$pseudocount
    )

tss_signal <-
    tibble(
        position =
            seq.int(
                from = -opt$upstream,
                to = opt$downstream,
                length.out = length(tss_score$values)
            ) |>
                as.integer(),
        score = tss_score$values
    )

tss_output <-
    list(
        signal = deframe(tss_signal) |> as.list(),
        score = tss_score$TSSEscore,
        params = opt
    )

write_csv(
    tss_signal,
    paste0(opt$prefix, "_tss_signal.csv"),
    col_names = TRUE
)

write_json(
    x = tss_output,
    path = paste0(opt$prefix, "_tss_enrichment.json"),
    auto_unbox = TRUE,
    pretty = TRUE
)
