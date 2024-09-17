include { MACS2_CALLPEAK         } from '../../modules/encode/macs2/callpeak'
include { MACS2_BDGCMP           } from '../../modules/encode/macs2/bdgcmp'

workflow TASK_MACS2 {
	take:
	ch_tagalign // [ val(meta), path(tagAlign) ]
	ch_faidx    // [ val(meta), path(faidx) ]
	ch_gensz	// integer or string
	max_peaks   // integer

	main:

	ch_narrowPeak  = Channel.empty()
	ch_fc_bigwig   = Channel.empty()
	ch_pval_bigwig = Channel.empty()


	ch_macs2_input = Channel.empty()
	ch_tagalign
		| filter{meta, ta -> meta.sample_type == "pooled"}
		| set{ch_pooled_ta}

	ch_tagalign
		| map{meta, ta -> [meta.sample_id, meta.sample_type, meta.pr_rep, ta]}

	ch_tagalign
		| branch {meta, ta ->
			no_ctrl: !meta.control_sample_id && !meta.control_group_id
				[meta, ta, []]
			sample_w_sample_ctrl: meta.control_sample_id
				[ [meta.control_sample_id, meta.sample_type, meta.pr_rep], meta, ta ]
			sample_w_group_ctrl: !meta.control_sample_id && meta.control_group_id
				[ [meta.control_group_id, meta.pr_rep], meta, ta ]
		}
		| set{ch_tagalign_branches}
	
	ch_tagalign_branches.sample_w_group_ctrl
		| combine(
			ch_pooled_ta.map{meta, ta -> [ [meta.group, meta.pr_rep], ta ]},
			by: 0
		)
		| map {group_keys, meta, target_ta, control_ta -> [meta, target_ta, control_ta]}
		| set{ch_sample_w_group_ctrl_inputs}

	ch_tagalign_branches.sample_w_sample_ctrl
		| combine(
			ch_tagalign.map{meta, ta -> [ [meta.sample_id, meta.sample_type, meta.pr_rep], ta ]},
			by: 0
		)
		| map {group_keys, meta, target_ta, control_ta -> [meta, target_ta, control_ta]}
		| set{ch_sample_w_sample_ctrl_inputs}
	
	ch_tagalign_branches.no_ctrl
		| mix(ch_sample_w_sample_ctrl_inputs)
		| mix(ch_sample_w_group_ctrl_inputs)
		| set{ch_macs2_input}

	MACS2_CALLPEAK(
		ch_macs2_input,
		ch_faidx,
		ch_gensz,
		max_peaks
	)
	ch_narrowPeak = MACS2_CALLPEAK.out.narrowPeak

	MACS2_CALLPEAK.out.treat_pileup
		.join(MACS2_CALLPEAK.out.control_lambda, by: 0)
		.join(ch_tagalign, by: 0)
		.map {meta, treat, control, ta ->
			def new_meta = meta.clone()
			new_meta.nreads = ta.countLines()
			new_meta.rpm_scale = new_meta.nreads / 1000000
			[new_meta, treat, control, ta, new_meta.rpm_scale]
		}
		.set{ch_bdgcmp_input}

	MACS2_BDGCMP(
		ch_bdgcmp_input,
		ch_faidx
	)
	ch_fc_bigwig   = MACS2_BDGCMP.out.fc_bigwig
	ch_pval_bigwig = MACS2_BDGCMP.out.pval_bigwig


	publish:
	ch_narrowPeak   >> "encode/macs2/raw"
	ch_fc_bigwig    >> "encode/macs2/signal"
	ch_pval_bigwig  >> "encode/macs2/signal"

	emit:
	narrowPeak  = ch_narrowPeak
	fc_bigwig   = ch_fc_bigwig
	pval_bigwig = ch_pval_bigwig


}