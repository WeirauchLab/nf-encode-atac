#!/usr/bin/env python

__version__ = "0.1.0"

import argparse
import pybedtools
import json
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
log = logging.getLogger(__name__)


def parse_args():
    parser = argparse.ArgumentParser(description="Calculate peak statistics")
    parser.add_argument("-b", "--bed", help="BED file of peaks", required=True)
    parser.add_argument("-t", "--tagalign", help="tagalign file", required=True)
    parser.add_argument("-p", "--prefix", help="Output file", required=True)
    parser.add_argument("-g", "--group", help="Sample group metadata")
    parser.add_argument("-i", "--id", help="Peak set ID")
    parser.add_argument(
        "-v", "--version", action="version", version=__version__
    )
    return parser.parse_args()


def main():
    args = parse_args()

    # Set up bedtools objects
    log.info("creating bedtools objects")
    bed = pybedtools.BedTool(args.bed)
    tagalign = pybedtools.BedTool(args.tagalign)

    # Calculate peak stats
    log.info("calculating peak stats")
    output = {
        "id": args.id,
        "group": args.group,
        "peak_file": args.bed,
        "tagalign_file": args.tagalign,
        "total_peaks": bed.count(),
        "total_reads": tagalign.count(),
        "reads_in_peaks": tagalign.intersect(bed, u=True).count(),
    }
    output["frip"] = output["reads_in_peaks"] / output["total_reads"]

    # Write output
    output_file = args.prefix + ".json"
    log.info("writing output to %s", output_file)
    with open(output_file, "w") as f:
        json.dump(output, f, indent=4)


if __name__ == "__main__":
    main()
