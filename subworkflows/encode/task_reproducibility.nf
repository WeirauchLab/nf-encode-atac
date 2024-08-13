
include { IDR_PEAKS              } from '../../modules/encode/idr/main'
include { OVERLAP_PEAKS          } from '../../modules/encode/overlap/main'
include { ENCODE_REPRODUCIBILITY } from '../../modules/encode/reproducibility/main'

def subset_peak_meta(peak_channel, meta_keys){
	peak_channel.map{meta, peak -> [meta.subMap(meta_keys), peak]}
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
		.branch { meta, peak ->
			sample:     meta.sample_type == "sample"
			pooled:     meta.sample_type == "pooled"
			pr1:        meta.sample_type == "pr" && meta.pr_rep == 1
			pr2:        meta.sample_type == "pr" && meta.pr_rep == 2
			pooled_pr1: meta.sample_type == "pooled_pr" && meta.pr_rep == 1
			pooled_pr2: meta.sample_type == "pooled_pr" && meta.pr_rep == 2
		}
		.set{ch_peaks_branched}
	
	subset_peak_meta(ch_peaks_branched.sample, ["sample_id","group","single_end"])
		.join(subset_peak_meta(ch_peaks_branched.pr1, ["sample_id","group","single_end"]), by:0)
		.join(subset_peak_meta(ch_peaks_branched.pr2, ["sample_id","group","single_end"]), by:0)
		.map{meta, peak1, peak2, peak3 ->
			def new_meta = [id: "${meta.sample_id}_pr1-vs-pr2", peak_comparison_group: "sample"] + meta 
			[ new_meta, peak1, peak2, peak3 ]
		}
		.set{ch_peak_sample_pr1_v_pr2}
	subset_peak_meta(ch_peaks_branched.pooled, ["sample_id","group","single_end"])
		.join(subset_peak_meta(ch_peaks_branched.pooled_pr1, ["sample_id","group","single_end"]), by:0)
		.join(subset_peak_meta(ch_peaks_branched.pooled_pr2, ["sample_id","group","single_end"]), by:0)
		.map{meta, peak1, peak2, peak3 ->
			def new_meta = [id: "${meta.group}_pooled_pr1-vs-pr2", peak_comparison_group: "np"] + meta 
			[ new_meta, peak1, peak2, peak3 ]
		}
		.set{ch_peak_pooled_pr1_v_pr2}
	subset_peak_meta(ch_peaks_branched.pooled,["group","single_end"])
		.combine(
			ch_peaks_branched.sample
				.map{meta, peak ->
					def new_meta = meta.subMap("group","single_end")
					[ new_meta, [meta.sample_id, peak ] ]
				}
			, by: 0
		)
		.combine(
			ch_peaks_branched.sample
				.map{meta, peak ->
					def new_meta = meta.subMap("group","single_end")
					[ new_meta, [meta.sample_id, peak ] ]
				}
			, by: 0
		)
		.filter{meta,peak,peak2,peak3 -> peak2[0] != peak3[0]}
		.map{meta,peak,peak2,peak3 ->
			[meta,peak,[peak2,peak3].sort{a,b -> a[0] <=> b[0]}]
		}
		.unique()
		.map{meta,peak,peak_pair ->
			def peak1 = peak_pair[0][0]
			def peak2 = peak_pair[1][0]
			def new_meta = [id: "${meta.group}_${peak1}-vs-${peak2}", peak1: peak1, peak2: peak2, peak_comparison_group: "nt"] + meta
			[new_meta, peak, peak_pair[0][1], peak_pair[1][1]]
		}
		.set{ch_peak_pooled_v_sample}
		
	Channel.empty()
		.mix(ch_peak_sample_pr1_v_pr2)
		.mix(ch_peak_pooled_pr1_v_pr2)
		.mix(ch_peak_pooled_v_sample)
		.set{ch_peak_combos}

	ch_idr_peaks             = Channel.empty()
	ch_overlap_peaks         = Channel.empty()
	
	if(!skip_idr){
		ch_peak_combos
			.map{meta, peak1, peak2, peak3 ->
				[meta + [mode: "idr"], peak1, peak2, peak3]
			}
			.set{ch_idr_input}

		IDR_PEAKS(
			ch_idr_input,
			idr_threshold_col,
			idr_threshold
		)
		ch_idr_peaks = IDR_PEAKS.out.narrowPeak
	}
	
	if(!skip_overlap){
		ch_peak_combos
			.map{meta, peak1, peak2, peak3 ->
				[meta + [mode: "overlap"], peak1, peak2, peak3]
			}
			.set{ch_overlap_input}

		OVERLAP_PEAKS(
			ch_overlap_input
		)
		ch_overlap_peaks = OVERLAP_PEAKS.out.narrowPeak
	}

	Channel.empty()
		.mix(ch_idr_peaks)
		.mix(ch_overlap_peaks)
		.map{meta,peaks ->
			def new_meta = meta.subMap("group","mode")
			[new_meta, [meta.peak_comparison_group, peaks]]
		}
		.groupTuple(by: 0)
		.map{meta, peaks ->
			def nt_peaks = peaks.findAll{it[0] == "nt"}.collect{it[1]}
			def np_peaks = peaks.findAll{it[0] == "np"}.collect{it[1]}
			def sample_peaks = peaks.findAll{it[0] == "sample"}.collect{it[1]}
			[meta, nt_peaks, np_peaks, sample_peaks]
		}
		.set{ch_reproducibility_input}

	ENCODE_REPRODUCIBILITY(ch_reproducibility_input)
	ENCODE_REPRODUCIBILITY.out.peaks
		.transpose()
		.map{meta, peaks ->
			[ [id: peaks.simpleName] + meta, peaks ]
		}
		.branch{meta, peak ->
			idr: meta.mode == "idr"
			overlap: meta.mode == "overlap"
		}
		.set{ch_reproducible_peaks_branched}

	ENCODE_REPRODUCIBILITY.out.optimal
		.map{meta, peaks ->
			def new_meta = meta.clone()
			new_meta.peak_class = "optimal"
			new_meta.id = [new_meta.group, new_meta.mode, new_meta.peak_class].join("_")
			new_meta = new_meta.subMap("id","group","mode","peak_class")
			[new_meta, peaks]
		}
		.set{ch_optimal}
	ENCODE_REPRODUCIBILITY.out.conservative
		.map{meta, peaks ->
			def new_meta = meta.clone()
			new_meta.peak_class = "conservative"
			new_meta.id = [new_meta.group, new_meta.mode, new_meta.peak_class].join("_")
			new_meta = new_meta.subMap("id","group","mode","peak_class")
			[new_meta, peaks]
		}
		.set{ch_conservative}
	

	publish:
	ch_idr_peaks                           >> "encode/macs2/idr"
	ch_reproducible_peaks_branched.idr     >> "encode/macs2/idr"
	ch_overlap_peaks                       >> "encode/macs2/overlap"
	ch_reproducible_peaks_branched.overlap >> "encode/macs2/overlap"

	emit:
	idr_peaks                  = ch_idr_peaks
	overlap_peaks              = ch_overlap_peaks
	idr_reproducible_peaks     = ch_reproducible_peaks_branched.idr
	overlap_reproducible_peaks = ch_reproducible_peaks_branched.overlap
	optimal                    = ch_optimal
	conservative               = ch_conservative
}