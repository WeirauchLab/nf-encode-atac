#!/usr/bin/env Rscript

box::use(
	rtracklayer[...],
	GenomicRanges[...],
	S4Vectors[...],
	IRanges[...],
	argparse[...],
	cli[...],
	tibble[...],
	rlang[set_names],
	dplyr[...],
	readr[write_csv],
	fs[path,path_ext, path_abs],
	jsonlite[write_json],
	purrr[...]
)


parser <- ArgumentParser(
	description = "Annotate a master peak set with overlap counts from multiple comparison peak files."
)
parser$add_argument(
	"-a",
	required = TRUE,
	metavar = "FILE",
	help = "Master peak set to annotate (BED, narrowPeak, or other format supported by rtracklayer)."
)
parser$add_argument(
	"-b",
	required = TRUE,
	nargs = "+",
	metavar = "FILE",
	help = "One or more peak files to check for overlaps against the master set."
)
parser$add_argument(
	"--prefix",
	default = "results",
	metavar = "PATH",
	help = "Output file prefix (directory and basename). Default: 'results'."
)
parser$add_argument(
	"--fracA",
	default = 0,
	type = "double",
	metavar = "FLOAT",
	help = "Minimum fraction of master peak (-a) that must overlap. Range: 0-1. Default: 0."
)
parser$add_argument(
	"--fracB",
	default = 0,
	type = "double",
	metavar = "FLOAT",
	help = "Minimum fraction of comparison peak (-b) that must overlap. Range: 0-1. Default: 0."
)
parser$add_argument(
	"--saveMatrix",
	action = "store_true",
	help = "Save a binary membership matrix (peaks x samples) as CSV."
)
parser$add_argument(
	"--saveSessionInfo",
	action = "store_true",
	help = "Save the session information to a txt."
)
parser$add_argument(
	"--summaryJson",
	action = "store_true",
	help = "Save overlap distribution summary statistics as JSON."
)


# ---------------------
# Functions
# ---------------------


#' Create directory if it doesn't exist
#'
#' @param filepath Path to a file; the parent directory will be created if needed
check_create_dir <- function(filepath){
	dir_name <- dirname(filepath)
	if(!dir.exists(dir_name)) dir.create(dir_name,showWarnings = FALSE,recursive = TRUE)
}

#' Import peak file as GRanges
#'
#' @param filepath Path to peak file (BED, narrowPeak, etc.)
#' @param format File format; if NULL, inferred from extension
#' @param sort_peaks Whether to sort peaks by genomic position (default: TRUE)
#' @return GRanges object containing the peaks
import_peaks <- function(filepath, format = NULL, sort_peaks = TRUE){
	if(!file.exists(filepath)) cli::cli_abort("Peak file doesn't exist: {.file {filepath}}")
	if(is.null(format)){
		format <- gsub(x = path_ext(filepath),pattern = ".gz",replacement = "")
	}
	gr <- import(filepath, format = format)
	if(sort_peaks){
		gr <- sort(gr)
	}
	gr
}

#' Find overlaps between two GRanges with fractional overlap filtering
#'
#' @param x Query GRanges (peak set A)
#' @param y Subject GRanges (peak set B)
#' @param fracA Minimum fraction of x that must be covered by intersection
#' @param fracB Minimum fraction of y that must be covered by intersection
#' @param ... Additional arguments passed to findOverlaps
#' @return Hits object filtered to overlaps meeting threshold criteria,
#'         with metadata columns: width, x_cov, y_cov
filter_pct_overlap <- function(x, y, fracA = 0, fracB = 0, ...){
	hits <- findOverlaps(x, y, ...)

	# Get overlapping ranges
	x_ranges <- x[queryHits(hits)]
	y_ranges <- y[subjectHits(hits)]

	# Calculate intersection widths
	intersection_width <- width(pintersect(x_ranges, y_ranges))
	x_cov <- intersection_width / width(x_ranges)
	y_cov <- intersection_width / width(y_ranges)

	keep_idx <- x_cov >= fracA & y_cov >= fracB

	# Add metadata to the Hits object
	mcols(hits)$width <- intersection_width
	mcols(hits)$x_cov <- x_cov
	mcols(hits)$y_cov <- y_cov

	# return hits that pass the threshold
	hits[keep_idx]
}

#' Generate summary statistics for annotated peaks
#'
#' @param peaks GRanges with score column indicating overlap counts
#' @param params List of parameters used in the analysis (for provenance)
#' @param id Identifier for this analysis run
#' @return List containing:
#'   - id: Analysis identifier
#'   - params: Input parameters
#'   - metadata: total_peaks, max_score, mean/median overlaps
#'   - distributions: exact and cumulative counts at each score
#'   - proportions: exact and cumulative proportions at each score
generate_summary_list <- function(peaks, params = list(), id = NULL) {
	max_score <- max(peaks$score)
	n_peaks <- length(peaks)
	scores_seq <- set_names(0:max_score, 0:max_score)

	exact_counts <- map(scores_seq, ~sum(peaks$score == .x))
	cumulative_counts <- map(scores_seq, ~sum(peaks$score >= .x))

	list(
		id = id,
		params = params,
		metadata = list(
			total_peaks = n_peaks,
			max_score = max_score,
			mean_overlaps = mean(peaks$score),
			median_overlaps = median(peaks$score)
		),
		distributions = list(
			exact = exact_counts,
			cumulative = cumulative_counts
		),
		proportions = list(
			exact = map(exact_counts, ~ .x / n_peaks),
			cumulative = map(cumulative_counts, ~ .x / n_peaks)
		)
	)
}

#' Validate --fracA/B arguments
#' @param x numeric value
#' @param label label to use for reporting
validate_frac <- function(x, label){
	if(!is.numeric(x)){cli_abort("ERROR: {label} must be a float between 0 and 1")}
	if(x > 1){cli_abort("ERROR: {label} cannot be greater than 1")}
	if(x < 0){cli_abort("ERROR: {label} cannot be less than 0")}
}

#' validate that the output does not overwrite the input
#'
#' @param files path to files
#' @param label label to use
validate_distinct_files <- function(files, label){
	files <- path_abs(files)
	if(any(duplicated(files))) cli_abort("ERROR: potential file name collision for: {label}")
}


# ---------------------
# Main
# ---------------------

# parse args
args <- parser$parse_args()
validate_frac(args$fracA,"--fracA")
validate_frac(args$fracB,"--fracB")


# setup outputs
master_format <- path_ext(path = gsub(pattern = ".gz$",replacement = "",x = basename(args$a)))
prefix_consensus <- paste0(args$prefix,"_consensus")
out_peaks <- path(prefix_consensus,ext = master_format)
out_matrix <- path(prefix_consensus,ext = "csv")
out_summary_json <- path(prefix_consensus, ext = "json")
out_session_txt <- path(paste0(prefix_consensus,"_sessionInfo.txt"))

validate_distinct_files(c(args$a, args$b, out_peaks))

# Load master peak set and initialize score column
peak1_gr <- import_peaks(args$a)
peak_files <- set_names(args$b, args$b)
peak1_gr$score <- 0

# Iterate through comparison peak files and annotate overlaps
for(peak_file in peak_files){
	file_id <- basename(peak_file)
	peak2_gr <- import_peaks(peak_file)

	# Find overlaps meeting fractional coverage thresholds
	hits <-
		filter_pct_overlap(
			x = peak1_gr,
			y = peak2_gr,
			fracA = args$fracA,
			fracB = args$fracB
		)

	# Update score (cumulative overlap count) and per-file membership
	idx <- unique(queryHits(hits))
	peak1_gr$score[idx] <- peak1_gr$score[idx] + 1
	mcols(peak1_gr)[[file_id]] <- 0
	mcols(peak1_gr)[[file_id]][idx] <- 1
}

# Export annotated peaks in the same format as input
check_create_dir(out_peaks)
export(object = peak1_gr, con = out_peaks,format = master_format)
cli_alert_success("Saved information to bed file: {.file {out_peaks}}")

# Optional: export membership matrix as CSV
if(args$saveMatrix){
	check_create_dir(out_matrix)
	write_csv(
		as_tibble(peak1_gr),
		out_matrix,
		col_names = TRUE
	)
	cli_alert_success("Saved information to csv file: {.file {out_matrix}}")
}

# Optional: export summary statistics as JSON
if(args$summaryJson){
	check_create_dir(out_summary_json)
	summary_list <- generate_summary_list(peak1_gr,params = args,id = args$prefix)
	write_json(summary_list,path = out_summary_json, auto_unbox = TRUE, pretty = TRUE)
	cli_alert_success("Saved summary json to: {.file {out_summary_json}}")
}

# Optional: export session information
if(args$saveSessionInfo){
	capture.output(sessionInfo(),file = out_session_txt)
	cli_alert_success("Session information saved to {.file {out_session_txt}}")
}




