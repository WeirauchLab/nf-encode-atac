include { IDR_PEAKS              } from '../../modules/encode/idr/main'
include { OVERLAP_PEAKS          } from '../../modules/encode/overlap/main'
include { ENCODE_REPRODUCIBILITY } from '../../modules/encode/reproducibility/main'

workflow TASK_REPRODUCIBILITY {
	take:
	ch_peaks          // [ val(meta), path(peaks) ]
	idr_threshold_col // string
	idr_threshold     // float
	skip_idr          // boolean
	skip_overlap

	main:
	
	ch_peaks
		.branch { meta, _peak ->
			sample: meta.sample_type == "sample" && !meta.pr_rep
			sample_pr1: meta.sample_type == "pr" && meta.pr_rep == "pr1"
			sample_pr2: meta.sample_type == "pr" && meta.pr_rep == "pr2"
			pooled: meta.sample_type == "pooled" && !meta.pr_rep
			pooled_pr1: meta.sample_type == "pooled" && meta.pr_rep == "pr1"
			pooled_pr2: meta.sample_type == "pooled" && meta.pr_rep == "pr2"
		}
		.set { ch_peaks_branched }

	// Sample-level PR1 vs PR2
	ch_peaks_branched.sample
		.map { meta, peak -> [meta.sample_id, meta, peak] }
		.join(
			ch_peaks_branched.sample_pr1.map { meta, peak -> [meta.sample_id, peak] },
			by: 0
		)
		.join(
			ch_peaks_branched.sample_pr2.map { meta, peak -> [meta.sample_id, peak] },
			by: 0
		)
		.map { _key, meta, peak1, peak2, peak3 ->
			def new_meta = meta.clone()
			new_meta.id = "${meta.id}_pr1-vs-pr2"
			new_meta.peak_comparison_group = "sample"
			[new_meta, peak1, peak2, peak3]
		}
		.set { ch_peak_sample_pr1_v_pr2 }

	// Pooled-level PR1 vs PR2

	ch_peaks_branched.pooled
		.map { meta, peak -> [meta.group, meta, peak] }
		.join(
			ch_peaks_branched.pooled_pr1.map { meta, peak -> [meta.group, peak] },
			by: 0
		)
		.join(
			ch_peaks_branched.pooled_pr2.map { meta, peak -> [meta.group, peak] },
			by: 0
		)
		.map { _key, meta, peak1, peak2, peak3 ->
			def new_meta = meta.clone()
			new_meta.id = "${meta.group}_pr1-vs-pr2"
			new_meta.peak_comparison_group = "np"
			[new_meta, peak1, peak2, peak3]
		}
		.set { ch_peak_pooled_pr1_v_pr2 }

	// Pooled vs Sample comparisons combinations
	// For each group, generate all pairwise combinations of sample peaks
	def group_sample_peak_sets = ch_peaks_branched.sample
		.map{meta, peak -> [meta.subMap("group"), [meta.id, peak] ]}
		.groupTuple(by: 0)
		.flatMap{meta, peak_list ->
			def peak_list_sorted = peak_list.sort{it[0]}
			def combinations = []
			peak_list_sorted.each{ id_1, peak_1 ->
				peak_list_sorted.each{ id_2, peak_2 ->
					if (id_1 < id_2) {
						def combo_meta = meta + [peak1: id_1, peak2: id_2]
						combinations << [combo_meta, peak_1, peak_2]
					}
				}
			}
			combinations
		}
	
	// Combine pooled peaks with the sample peak combinations
	ch_peaks_branched.pooled
		.map{meta, peak -> [meta.group, meta, peak] }
		.combine(
			group_sample_peak_sets.map{meta, peak1, peak2 -> [meta.group, meta, peak1, peak2]},
			by: 0
		)
		.map{ _key, pooled_meta, pooled_peak, sample_meta, sample_peak1, sample_peak2 ->
			def new_id = "${pooled_meta.group}_${sample_meta.peak1}-vs-${sample_meta.peak2}"
			def new_meta = pooled_meta + sample_meta
			new_meta.peak_comparison_group = "nt"
			new_meta.id = new_id
			[new_meta, pooled_peak, sample_peak1, sample_peak2]
		}
		.set { ch_peak_pooled_v_sample }

	Channel.empty()
		.mix(ch_peak_sample_pr1_v_pr2)
		.mix(ch_peak_pooled_pr1_v_pr2)
		.mix(ch_peak_pooled_v_sample)
		.set { ch_peak_combos }

	ch_idr_peaks = Channel.empty()
	ch_overlap_peaks = Channel.empty()
	ch_idr_plots = Channel.empty()
	if (!skip_idr) {
		ch_peak_combos
			.map { meta, peak1, peak2, peak3 ->
				[meta + [reproducibility_mode: "idr"], peak1, peak2, peak3]
			}
			.set { ch_idr_input }

		IDR_PEAKS(
			ch_idr_input,
			idr_threshold_col,
			idr_threshold,
		)
		ch_idr_peaks = IDR_PEAKS.out.narrowPeak
		ch_idr_plots = IDR_PEAKS.out.png
	}

	if (!skip_overlap) {
		ch_peak_combos
			.map { meta, peak1, peak2, peak3 ->
				[meta + [reproducibility_mode: "overlap"], peak1, peak2, peak3]
			}
			.set { ch_overlap_input }

		OVERLAP_PEAKS(
			ch_overlap_input
		)
		ch_overlap_peaks = OVERLAP_PEAKS.out.narrowPeak
	}

	Channel.empty()
		.mix(ch_idr_peaks)
		.mix(ch_overlap_peaks)
		.map { meta, peaks ->
			def new_meta = meta.subMap("group", "single-end", "reproducibility_mode")
			[new_meta, [meta.peak_comparison_group, peaks]]
		}
		.groupTuple(by: 0)
		.map { meta, peaks ->
			def nt_peaks = peaks.findAll { it[0] == "nt" }.collect { it[1] }
			def np_peaks = peaks.findAll { it[0] == "np" }.collect { it[1] }
			def sample_peaks = peaks.findAll { it[0] == "sample" }.collect { it[1] }
			[meta, nt_peaks, np_peaks, sample_peaks]
		}
		.set { ch_reproducibility_input }

	ENCODE_REPRODUCIBILITY(ch_reproducibility_input)
	ch_peak_counts = ENCODE_REPRODUCIBILITY.out.peak_counts_csv
	ch_stats_csv = ENCODE_REPRODUCIBILITY.out.stats_csv
	ch_stats_json = ENCODE_REPRODUCIBILITY.out.stats_json

	ENCODE_REPRODUCIBILITY.out.optimal
		.map { meta, peak ->
			def new_meta = meta.clone()
			new_meta.reproducibility_class = "optimal"
			new_meta.id = [new_meta.group, new_meta.reproducibility_mode, new_meta.reproducibility_class].join("_")
			[new_meta, peak]
		}
		.set { ch_optimal }
	ENCODE_REPRODUCIBILITY.out.conservative
		.map { meta, peak ->
			def new_meta = meta.clone()
			new_meta.reproducibility_class = "conservative"
			new_meta.id = [new_meta.group, new_meta.reproducibility_mode, new_meta.reproducibility_class].join("_")
			[new_meta, peak]
		}
		.set { ch_conservative }

	ch_optimal
		.mix(ch_conservative)
		.branch { meta, _peak ->
			idr_optimal: meta.reproducibility_mode == "idr" && meta.reproducibility_class == "optimal"
			idr_conservative: meta.reproducibility_mode == "idr" && meta.reproducibility_class == "conservative"
			overlap_optimal: meta.reproducibility_mode == "overlap" && meta.reproducibility_class == "optimal"
			overlap_conservative: meta.reproducibility_mode == "overlap" && meta.reproducibility_class == "conservative"
		}
		.set { ch_reproducible_peaks_branched }

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
	idr_plots            = ch_idr_plots
}
