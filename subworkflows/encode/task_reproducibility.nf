
include { IDR_PEAKS              } from '../../modules/encode/idr/main'
include { OVERLAP_PEAKS          } from '../../modules/encode/overlap/main'
include { ENCODE_REPRODUCIBILITY } from '../../modules/encode/reproducibility/main'

def subset_peak_meta(peak_channel, meta_keys){
	peak_channel.map{meta, peak -> [meta.subMap(meta_keys), peak]}
}

def generateCombinationPairs(list) {
	def combos = []
	for (i in 0..<list.size()) {
		for (j in i+1..<list.size()) {
			combos.add([list[i], list[j]])
		}
	}
	return combos
}

workflow TASK_REPRODUCIBILITY {
	take:
	ch_peaks // [ val(meta), path(peaks) ]
	idr_threshold_col // string
	idr_threshold // float
	skip_idr // boolean
	skip_overlap

	main:

	ch_peaks
		| branch {meta, peak ->
			sample: meta.sample_type == "sample" && !meta.pr_rep
			sample_pr1:    meta.sample_type == "pr" && meta.pr_rep == "pr1"
			sample_pr2:    meta.sample_type == "pr" && meta.pr_rep == "pr2"
			pooled:        meta.sample_type == "pooled" && !meta.pr_rep
			pooled_pr1:    meta.sample_type == "pooled" && meta.pr_rep == "pr1"
			pooled_pr2:    meta.sample_type == "pooled" && meta.pr_rep == "pr2"
		}
		| set{ch_peaks_branched}

	ch_peaks_branched.sample
		| map{ meta, peak -> [meta.sample_id, meta, peak] }
		| join(
			ch_peaks_branched.sample_pr1.map{ meta, peak -> [meta.sample_id, peak] },
			by: 0
		)
		| join(
			ch_peaks_branched.sample_pr2.map{ meta, peak -> [meta.sample_id, peak] },
			by: 0
		)
		| map{ key, meta, peak1, peak2, peak3 ->
			def new_meta = meta.clone()
			new_meta.id = "${meta.id}_pr1-vs-pr2"
			new_meta.peak_comparison_group = "sample"
			[new_meta, peak1, peak2, peak3]
		}
		| set{ch_peak_sample_pr1_v_pr2}
	
	ch_peaks_branched.pooled
		| map{ meta, peak -> [meta.group, meta, peak] }
		| join(
			ch_peaks_branched.pooled_pr1.map{ meta, peak -> [meta.group, peak] },
			by: 0
		)
		| join(
			ch_peaks_branched.pooled_pr2.map{ meta, peak -> [meta.group, peak] },
			by: 0
		)
		| map{ key, meta, peak1, peak2, peak3 ->
			def new_meta = meta.clone()
			new_meta.id = "${meta.group}_pr1-vs-pr2"
			new_meta.peak_comparison_group = "np"
			[new_meta, peak1, peak2, peak3]
		}
		| set{ch_peak_pooled_pr1_v_pr2}
	
	ch_peaks_branched.pooled
		| map{ meta, peak ->
			[ generateCombinationPairs(meta.sample_id.sort()), meta, peak ]
		}
		| transpose(by: 0)
		| map{ peak_pair, meta, peak ->
			def new_meta = meta.clone()
			new_meta.peak_comparison_group = "nt"
			new_meta.peak1 = peak_pair[0]
			new_meta.peak2 = peak_pair[1]
			new_meta.id = "${new_meta.group}_${new_meta.peak1}-vs-${new_meta.peak2}"
			[peak_pair[0],peak_pair[1], new_meta, peak]
		}
		| join(
			ch_peaks_branched.sample.map{ meta, peak -> [meta.sample_id, peak] },
			by: 0
		)
		| map{rep1, rep2, meta, peak, peak1 -> [rep2, meta, peak, peak1]}
		| join(
			ch_peaks_branched.sample.map{ meta, peak -> [meta.sample_id, peak] },
			by: 0
		)
		| map{rep2, meta, peak, peak1, peak2 -> [meta, peak, peak1, peak2]}
		| set{ch_peak_pooled_v_sample}

	Channel.empty()
		.mix(ch_peak_sample_pr1_v_pr2)
		.mix(ch_peak_pooled_pr1_v_pr2)
		.mix(ch_peak_pooled_v_sample)
		.set{ch_peak_combos}

	ch_idr_peaks             = Channel.empty()
	ch_overlap_peaks         = Channel.empty()
	ch_idr_plots			 = Channel.empty()
	if(!skip_idr){
		ch_peak_combos
			.map{meta, peak1, peak2, peak3 ->
				[meta + [reproducibility_mode: "idr"], peak1, peak2, peak3]
			}
			.set{ch_idr_input}

		IDR_PEAKS(
			ch_idr_input,
			idr_threshold_col,
			idr_threshold
		)
		ch_idr_peaks = IDR_PEAKS.out.narrowPeak
		ch_idr_plots = IDR_PEAKS.out.png
	}
	
	if(!skip_overlap){
		ch_peak_combos
			.map{meta, peak1, peak2, peak3 ->
				[meta + [reproducibility_mode: "overlap"], peak1, peak2, peak3]
			}
			.set{ch_overlap_input}

		OVERLAP_PEAKS(
			ch_overlap_input
		)
		ch_overlap_peaks = OVERLAP_PEAKS.out.narrowPeak
	}

	Channel.empty()
		| mix(ch_idr_peaks)
		| mix(ch_overlap_peaks)
		| map{meta,peaks ->
			def new_meta = meta.subMap("group", "single-end", "reproducibility_mode")
			[ new_meta, [meta.peak_comparison_group, peaks] ]
		}
		| groupTuple(by: 0)
		| map{meta, peaks ->
			def nt_peaks = peaks.findAll{it[0] == "nt"}.collect{it[1]}
			def np_peaks = peaks.findAll{it[0] == "np"}.collect{it[1]}
			def sample_peaks = peaks.findAll{it[0] == "sample"}.collect{it[1]}
			[meta, nt_peaks, np_peaks, sample_peaks]
		}
		| set{ch_reproducibility_input}

	ENCODE_REPRODUCIBILITY(ch_reproducibility_input)
	ch_peak_counts = ENCODE_REPRODUCIBILITY.out.peak_counts_csv
	ch_stats_csv   = ENCODE_REPRODUCIBILITY.out.stats_csv
	ch_stats_json  = ENCODE_REPRODUCIBILITY.out.stats_json

	ENCODE_REPRODUCIBILITY.out.optimal
		| map{meta, peak -> 
			def new_meta = meta.clone()
			new_meta.reproducibility_class = "optimal"
			new_meta.id = [new_meta.group, new_meta.reproducibility_mode, new_meta.reproducibility_class].join("_")
			[new_meta, peak]
		}
		| set{ch_optimal}
	ENCODE_REPRODUCIBILITY.out.conservative
				| map{meta, peak ->
					def new_meta = meta.clone()
					new_meta.reproducibility_class = "conservative"
					new_meta.id = [new_meta.group, new_meta.reproducibility_mode, new_meta.reproducibility_class].join("_")
					[new_meta, peak]
				}
		| set{ch_conservative}
	
	ch_optimal
		| mix(ch_conservative)
		| branch{meta, peak ->
			idr_optimal:          meta.reproducibility_mode == "idr"     && meta.reproducibility_class == "optimal"
			idr_conservative:     meta.reproducibility_mode == "idr"     && meta.reproducibility_class == "conservative"
			overlap_optimal:      meta.reproducibility_mode == "overlap" && meta.reproducibility_class == "optimal"
			overlap_conservative: meta.reproducibility_mode == "overlap" && meta.reproducibility_class == "conservative"
		}
		| set{ch_reproducible_peaks_branched}

	publish:
	ch_reproducible_peaks_branched.idr_optimal          >> "encode/macs2/idr"
	ch_reproducible_peaks_branched.idr_conservative     >> "encode/macs2/idr"
	ch_reproducible_peaks_branched.overlap_optimal      >> "encode/macs2/overlap"
	ch_reproducible_peaks_branched.overlap_conservative >> "encode/macs2/overlap"
	ch_idr_plots										>> "encode/macs2/idr"

	emit:
	idr_peaks            = ch_idr_peaks
	overlap_peaks        = ch_overlap_peaks
	idr_optimal          = ch_reproducible_peaks_branched.idr_optimal
	idr_conservative     = ch_reproducible_peaks_branched.idr_conservative
	overlap_optimal      = ch_reproducible_peaks_branched.overlap_optimal
	overlap_conservative = ch_reproducible_peaks_branched.overlap_conservative
	peak_counts          = ch_peak_counts
	stats_csv            = ch_stats_csv
	stats_json           = ch_stats_json

}