#!/usr/bin/env python

import argparse
from pathlib import Path
import pandas as pd
from math import log10
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(description="")
parser.add_argument(
    "-i", "--input", dest="input", help="Input peak file", required=True
)
parser.add_argument(
    "-P",
    "--prefix",
    dest="prefix",
    help="Prefix for output files. This could be something like path/to/folder/filtered_abc. that would create: path/to/folder/filtered_abc.narrowPeak",
    required=True,
)
parser.add_argument(
    "-q", "--q-threshold", dest="q_threshold", help="Q-value threshold"
)
parser.add_argument(
    "-f", "--format", dest="format", help="Output format", default="narrowPeak"
)


def main():
    opt = parser.parse_args()
    opt.input = Path(opt.input)
    output_file = Path(f"{opt.prefix}.{opt.format}")

    if not output_file.parent.exists():
        logger.info(f"Creating output directory: {output_file.parent}")
        output_file.parent.mkdir(parents=True)

    match opt.format:
        case "narrowPeak":
            headers = [
                "chrom",
                "start",
                "end",
                "name",
                "score",
                "strand",
                "signalValue",
                "pValue",
                "qValue",
                "peak",
            ]

    if opt.input.suffix == ".gz":
        logger.info(f"Reading file: {opt.input}")
        logger.info(f"header types: {opt.format}")
        df = pd.read_csv(
            opt.input, delimiter="\t", compression="gzip", names=headers
        )
        output_file = output_file.with_suffix(".gz")

    else:
        df = pd.read_csv(opt.input, delimiter="\t", names=headers)

    logger.info(f"Number of peaks: {len(df)}")
    logger.info("Sorting peaks")
    df = df.sort_values(by=[df.columns[0], df.columns[1]])
    if opt.q_threshold:
        nlog10_qthreshold = (-1) * log10(float(opt.q_threshold))
        logger.info(
            f"Filtering peaks with qValue < {opt.q_threshold} || -log10(qValue) > {nlog10_qthreshold}"
        )
        df = df[df["qValue"] > nlog10_qthreshold]
        logger.info(f"Number of peaks after q-filtering: {len(df)}")

    logger.info(f"Writing output file: {output_file}")
    if output_file.suffix == ".gz":
        df.to_csv(
            output_file, sep="\t", index=False, compression="gzip", header=False
        )
    else:
        df.to_csv(output_file, sep="\t", index=False, header=False)

    if output_file.exists():
        logger.info("Filtering peaks completed successfully!")


if __name__ == "__main__":
    main()
