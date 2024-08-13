nextflow.preview.output = true
nextflow.preview.topic  = true

include { CHIPSEQ } from './workflows/chipseq'

workflow {
	CHIPSEQ()
}

output {
    directory "$params.outdir"
	mode params.publish_dir_mode

	'encode/tagAlign' {
		index {
			path 'tagAlign_index.csv'
		}
	}
	'encode/alignments/raw' {
		index {
			path 'alignments_raw_index.csv'
		}
	}
	'encode/alignments/filtered' {
		index {
			path 'alignments_filtered_index.csv'
		}
	}
	'encode/peaks/macs2/raw' {
		index {
			path 'macs2_raw_index.csv'
		}
	}
	'encode/peaks/macs2/filtered' {
		index {
			path 'macs2_filtered_index.csv'
		}
	}
	'encode/macs2/signal' {
		index {
			path 'macs2_signal_index.csv'
		}
	}
	'encode/macs2/idr' {
		index {
			path 'macs2_idr_index.csv'
		}
	}
}