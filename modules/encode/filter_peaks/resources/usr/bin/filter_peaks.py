#!/usr/bin/env python

import argparse
from pybedtools import BedTool
import re
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
logger = logging.getLogger(__name__)


parser = argparse.ArgumentParser(description="Filter peaks")
parser.add_argument("-i", "--input", help="Input file", required=True)
parser.add_argument("-o", "--output", help="output file to use", required=True)
parser.add_argument(
    "-e", "--exclusion-peaks", help="exclusion peaks", required=False
)
parser.add_argument(
    "-r", "--regex", help="regex pattern for chrs to remove", required=False
)


def intersect_peaks(peaks, exclusion_peaks, **kwargs):
    """
    Intersects peaks with exclusion peaks, returning peaks that do not overlap with exclusion peaks.

    Args:
        peaks (BedTool): The input peaks.
        exclusion_peaks (BedTool): The exclusion peaks.
        **kwargs: Additional arguments to pass to the intersect method.

    Returns:
        BedTool: The resulting peaks after intersection.
    """
    if exclusion_peaks:
        logger.info("Removing exclusion peaks...")
        filtered_peaks = peaks.intersect(exclusion_peaks, v=True)
        logger.info(f"Peaks remaining: {filtered_peaks.count()}")
        return filtered_peaks
    else:
        return peaks


def read_peaks(file):
    """
    Reads peaks from a file.

    Args:
        file (str): The file to read.

    Returns:
        BedTool: The peaks.
    """
    bedtool = BedTool(file)
    logger.info(f"Imported {bedtool.count()} peaks from: {file}")
    return bedtool


def filter_peaks_by_chrom(peaks, pattern):
    """
    Filters peaks by chromosome using a regex pattern.

    Args:
        peaks (BedTool): The input peaks.
        pattern (str): The regex pattern to filter by.

    Returns:
        BedTool: The filtered peaks.
    """
    logger.info(f"Filtering peaks using regex: {pattern}")
    pattern = re.compile(pattern)
    filtered_peaks = peaks.filter(lambda x: pattern.match(x.chrom)).saveas()
    logger.info(f"Peaks remaining: {filtered_peaks.count()}")
    return filtered_peaks


def main():
    args = parser.parse_args()
    # Create bedtool objects
    peaks = read_peaks(args.input)

    if args.exclusion_peaks:
        exclusion_peaks = read_peaks(args.exclusion_peaks)
        peaks = intersect_peaks(peaks, exclusion_peaks)

    if args.regex:
        peaks = filter_peaks_by_chrom(peaks, args.regex)

    logger.info(f"Saving filtered peaks to: {args.output}")
    peaks.saveas(args.output)
    logger.info("Done")


if __name__ == "__main__":
    main()
