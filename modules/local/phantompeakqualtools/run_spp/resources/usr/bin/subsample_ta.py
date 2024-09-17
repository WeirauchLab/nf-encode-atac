#!/usr/bin/env python

import argparse
import gzip
import random
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
log = logging.getLogger(__name__)

parser = argparse.ArgumentParser(description='Subsample tagAlign file')
parser.add_argument('-i','--input', type = str, required = True, help='gzipped tagAlign file')
parser.add_argument('-o','--output', type = str, required = True, help='output file (gzipped)')
parser.add_argument('-n','--number', type = int, default = 10000000, help='number of fragments to subsample')
parser.add_argument('-s','--seed', type = int, default = 12345, help='seed for random number generator')
parser.add_argument('--paired', action = 'store_true', help='paired-end reads')
args = parser.parse_args()

def subsample_se(ta, n, output_gz):
	indices = set()
	log.info(f"operation mode: single-end")
	with gzip.open(ta, 'rt') as f:
		log.info(f"Counting total number of reads in {ta}")
		total_fragments = sum(1 for _ in f)
	log.info(f"Total number of fragments: {total_fragments}")
	sample_n = min(n, total_fragments)
	if sample_n == total_fragments:
		log.warning("Desired number of fragments is equal to total number of fragments. Using original instead.")
		return
	log.info(f"Desired number of fragments: {sample_n} || Total number of fragments: {total_fragments}")
	indices.update(random.sample(range(0, total_fragments+1), k=sample_n))
	with gzip.open(ta, 'rt') as fin, gzip.open(output_gz, 'wt') as fout:
		log.info(f"Subsampling {sample_n} fragments to {output_gz}")
		total_lines_written = 0
		for i, line in enumerate(fin):
			if i in indices:
				fout.write(line)
				total_lines_written += 1
				if total_lines_written % 1000000 == 0:
					log.info(f"Written {total_lines_written} lines")

def subsample_pe(ta, n, output_gz):
	indices = set()
	log.info(f"operation mode: paired-end")
	with gzip.open(ta, 'rt') as f:
		log.info(f"Counting total number of reads in {ta}")
		total_reads = sum(1 for _ in f)
	total_fragments = total_reads // 2
	log.info(f"Total number of reads: {total_reads}")
	sample_n = min(n, total_fragments)
	if sample_n >= total_fragments:
		log.warning("Desired number of fragments is equal to total number of fragments. Using original instead.")
		return
	log.info(f"Desired number of fragments: {sample_n} || Total number of fragments: {total_fragments}")
	indices.update(random.sample(range(0, total_reads, 2), k=sample_n))
	with gzip.open(ta, 'rt') as fin, gzip.open(output_gz, 'wt') as fout:
		log.info(f"Subsampling {sample_n} fragments to {output_gz}")
		total_lines_written = 0
		for i, line in enumerate(fin):
			if i in indices:
				fout.write(line)
				total_lines_written += 1
				try:
					next_line = next(fin)
					fout.write(next_line)
					total_lines_written += 1
				except StopIteration:
					log.warning("Reached end of file")
				if total_lines_written % 1000000 == 0:
					log.info(f"Written {total_lines_written} reads")


def main():
	random.seed(args.seed)
	if args.paired:
		subsample_pe(args.input, args.number, args.output)
	else:
		subsample_se(args.input, args.number, args.output)

if __name__ == '__main__':
	main()