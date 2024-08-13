include { BAM_TO_TA         } from "../../modules/encode/bam_to_ta/main"
include { CREATE_PSEUDOREPS } from "../../modules/encode/create_pseudoreplicates/main"
include { CAT_FILES         } from "../../modules/local/cat_files/main"

workflow TASK_TAGALIGN {
	take:
	ch_bam                 // [ val(meta), path(bam) ]
	pseudorep_seed         // integer
	skip_pseudoreplication // boolean
	save_tagAlign          // boolean

	main:

	ch_tagalign = Channel.empty()

	BAM_TO_TA(ch_bam)
	ch_tagalign = BAM_TO_TA.out.tagAlign

	if(!skip_pseudoreplication){
		CREATE_PSEUDOREPS(
			ch_tagalign,
			pseudorep_seed
		)
		CREATE_PSEUDOREPS.out.tagAlign
			.transpose()
			.map { meta, ta ->
				def new_meta = meta.clone()
				new_meta.sample_type = "pr"
				def (pr_full, pr_rep) = (ta.toString() =~ /.*pr(\d+)\.tagAlign\.gz$/)[0]
				new_meta.pr_rep = pr_rep.toInteger()
				new_meta.id = "${new_meta.sample_id}_pr${new_meta.pr_rep}"
				[ new_meta, ta ]
			}
			.set { ch_pr_ta }
		ch_tagalign = ch_tagalign.mix(ch_pr_ta)
	}

	// generate pooled tagAlign
	ch_tagalign
		.map{ meta, ta ->
			def new_meta = [:]
			if(meta.pr_rep){
				new_meta = [id: "${meta.group}_pooled_pr${meta.pr_rep}", sample_type: "pooled_pr"] + meta.subMap("group", "single_end", "pr_rep", "chip_mode")
			} else {
				new_meta = [id: "${meta.group}_pooled", sample_type: "pooled"] + meta.subMap("group", "single_end", "chip_mode")
			}
			[ new_meta, ta ]
		}
		.groupTuple(by: 0)
		.map{meta, ta_list -> [meta, ta_list.sort()]}
		.filter{meta, ta_list -> ta_list.size() > 1}
		.set{ch_pooled_ta_input}

	CAT_FILES(ch_pooled_ta_input,"tagAlign.gz")
	ch_tagalign = ch_tagalign.mix(CAT_FILES.out.output)

	publish:
	ch_tagalign >> (save_tagAlign ? "encode/tagAlign" : null)

	emit:
	tagAlign = ch_tagalign

}