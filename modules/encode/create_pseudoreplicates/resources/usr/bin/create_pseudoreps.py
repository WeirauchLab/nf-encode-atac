#!/usr/bin/env python

import argparse
import random
import gzip
from itertools import islice, chain
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
log = logging.getLogger(__name__)


def main(args):
    log.info(f"Setting random seed to: {args.seed}")
    random.seed(args.seed)
    pr1 = f"{args.prefix}_pr1.tagAlign.gz"
    pr2 = f"{args.prefix}_pr2.tagAlign.gz"
    total_lines = 0

    if args.paired_end:
        log.info("mode: paired-end")
    else:
        log.info("mode: single-end")
    log.info(f"Splitting {args.tagAlign} into {pr1} and {pr2}")
    log.info(f"Chunk size: {args.chunk_size}")

    with gzip.open(args.tagAlign, "rt") as f, gzip.open(
        pr1, "wt"
    ) as f_pr1, gzip.open(pr2, "wt") as f_pr2:
        while True:
            line_chunk = list(islice(f, args.chunk_size))
            if not line_chunk:
                break
            if args.paired_end:
                line_pairs = [
                    line_chunk[i : i + 2] for i in range(0, len(line_chunk), 2)
                ]
                random.shuffle(line_pairs)
                line_chunk = list(chain.from_iterable(line_pairs))
            else:
                random.shuffle(line_chunk)
            midpoint = len(line_chunk) // 2
            f_pr1.writelines(line_chunk[:midpoint])
            f_pr2.writelines(line_chunk[midpoint:])
            total_lines += len(line_chunk)
            log.info(f"Processed {total_lines} lines")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--tagAlign", required=True, help="Path to tagAlign file to split"
    )
    parser.add_argument(
        "--chunk_size",
        type=int,
        default=500000,
        help="Number of lines to read at a time",
    )
    parser.add_argument(
        "--prefix",
        required=True,
        help="Prefix to use for pseudoreplicate files",
    )
    parser.add_argument(
        "--paired_end",
        action="store_true",
        help="Flag to indicate paired-end mode",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=42,
        help="Random seed to use for reproducibility",
    )
    args = parser.parse_args()
    main(args)
