#!/usr/bin/env Rscript

library(argparse)
library(txdbmaker)
library(purrr)
library(readr)
library(AnnotationDbi)
library(cli)

parser <- ArgumentParser(description="Make TxDb from GFF / GTF file")
parser$add_argument("-p","--prefix", help="Output TxDb prefix", default="txdb")
parser$add_argument("-i","--input", help="GFF / GTF file", required = TRUE)
parser$add_argument("-f","--format", help="File format: gff3, gtf, or auto", default="auto", choices=c("gff3","gtf","auto"))
parser$add_argument("-o","--organism", help="Organism name")
parser$add_argument("-t","--taxonomyid", help="NCBI Taxonomy ID", type="integer")
parser$add_argument("--chrsizes", help="Chromosome sizes file (optional)", default=NULL)
parser$add_argument("--versions-yaml", help="path to yaml file to write versions to")
args <- parser$parse_args()


outdir <- dirname(args$prefix)
if(!dir.exists(outdir)) {
    cli_alert_info("Creating output directory {outdir}")
    dir.create(outdir, recursive=TRUE)
}


txdb_args <-
    list(
        file = args$input,
        format = args$format,
        organism = args$organism,
        taxonomyId = args$taxonomyid,
        dataSource = basename(args$input)
    )

if(!is.null(args$chrsizes)) {
    if(!file.exists(args$chrsizes)) {
        stop("Chromosome sizes file ", args$chrsizes, " does not exist!")
    }
    cli_alert_info("Reading chromosome sizes from {.file {args$chrsizes}}")
    chrsizes <- 
        read_tsv(
            args$chrsizes,
            col_names=c("chrom","length"),
            col_types=cols(
            chrom = col_character(),
            length = col_integer()
        ))
    txdb_args$chrominfo <- chrsizes
}

cli_alert_info("Creating TxDb from GFF / GTF: {.file {args$input}}")
txdb <- rlang::exec(txdbmaker::makeTxDbFromGFF, !!!purrr::compact(txdb_args))

outdbfile <- paste0(args$prefix, ".sqlite")
AnnotationDbi::saveDb(txdb, outdbfile)

cli_alert_success("Saved TxDb to {.file {outdbfile}}")

if(!is.null(args$versions_yaml)){
    glue::glue(
        "
        R: {R.version.string}
        txdbmaker: {as.character(packageVersion('txdbmaker'))}
        argparse: {as.character(packageVersion('argparse'))}
        purrr: {as.character(packageVersion('purrr'))}
        readr: {as.character(packageVersion('readr'))}
        AnnotationDbi: {as.character(packageVersion('AnnotationDbi'))}
        cli: {as.character(packageVersion('cli'))}
        "
    ) |>
    readr::write_lines(args$versions_yaml)
    cli_alert_success("Wrote versions to {.file {args$versions_yaml}}")

}