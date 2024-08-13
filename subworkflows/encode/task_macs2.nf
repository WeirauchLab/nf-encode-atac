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

	ch_tagalign
		.collect{meta, ta -> [ [meta.id,ta] ]}
		.set{list_tagalign}
	// This tries to match the control tagAlign file with the treatment tagAlign file
	// TODO: Make this use the pooled control tagAlign file
	ch_tagalign
		.map{meta, ta -> 
			def new_meta = meta.clone()
			new_meta.tagalign_id = new_meta.id
			if(new_meta.control_id){
				def control_entry = list_tagalign.findAll{it[0].id == new_meta.control_id}
				if(control_entry) {
					[new_meta, ta, control_entry[1]]
				}
				} else {
					[new_meta, ta, []]
				}
			}
		.set {ch_macs2_input}
	
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