include { SOURMASH_SKETCH } from '../../modules/local/sourmash/sketch/main'
include { SOURMASH_GATHER } from '../../modules/local/sourmash/gather/main'

workflow SOURMASH_CLASSIFIER {
	take:
	ch_fastq
	ch_db

	main:

	SOURMASH_SKETCH(ch_fastq)
	SOURMASH_GATHER(SOURMASH_SKETCH.out.sketch, ch_db)

	emit:
	sketch = SOURMASH_SKETCH.out.sketch
	csv    = SOURMASH_GATHER.out.csv

	publish:
	SOURMASH_SKETCH.out.sketch >> 'metagenomics/sourmash'
	SOURMASH_GATHER.out.csv    >> 'metagenomics/sourmash'

}