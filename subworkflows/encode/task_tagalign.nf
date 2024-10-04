include { BAM_TO_TA         } from "../../modules/encode/bam_to_ta/main"
include { CREATE_PSEUDOREPS } from "../../modules/encode/create_pseudoreplicates/main"
include { CAT_FILES         } from "../../modules/local/cat_files/main"

workflow TASK_TAGALIGN {
	take:
	ch_bam                 // [ val(meta), path(bam) ]
	pseudorep_seed         // integer
	skip_pseudoreplication // boolean
	save_sample_tagalign   // boolean
	save_pr_tagalign       // boolean
	save_pooled_tagalign   // boolean

	main:

	ch_tagalign_output = Channel.empty()
	ch_tagalign_pr     = Channel.empty()

	BAM_TO_TA(ch_bam)
	ch_tagalign_reps   = BAM_TO_TA.out.tagAlign

	if(!skip_pseudoreplication){
		CREATE_PSEUDOREPS(
			ch_tagalign_reps,
			pseudorep_seed
		)
		CREATE_PSEUDOREPS.out.tagAlign
			.transpose()
			.map { meta, ta ->
				def new_meta = meta.clone()
				new_meta.sample_type = "pr"
				def (pr_full, pr_rep) = (ta.toString() =~ /.*pr(\d+)\.tagAlign\.gz$/)[0]
				new_meta.pr_rep = "pr${pr_rep}"
				new_meta.id = "${new_meta.sample_id}_${new_meta.pr_rep}"
				[ new_meta, ta ]
			}
			.set { ch_tagalign_pr }
	}

	ch_tagalign_reps
		| mix(ch_tagalign_pr)
		| map{meta, ta ->
			def group_meta = [id: []] + meta.subMap("group", "single_end", "sample_type", "pr_rep")
			[group_meta,meta.sample_id,meta.control_group_id, ta]
		}
		| groupTuple(by: 0)
		| map{meta, sample_id, control_group_id, ta_list ->
			def new_meta = meta.clone()
			def control_group_id_unique = control_group_id.flatten().unique().sort()
			if (control_group_id_unique.size() > 1){
				throw new Exception("Multiple control groups found for ${meta.group} when pooling tagAligns. Please check the sample sheet.")
			}
			new_meta.sample_type = "pooled"
			new_meta.id = new_meta.pr_rep ? [new_meta.group, new_meta.sample_type, new_meta.pr_rep].join("_") : [new_meta.group, new_meta.sample_type].join("_")
			new_meta.sample_id = sample_id.flatten().unique().sort()
			new_meta.control_sample_id = []
			new_meta.control_group_id  = control_group_id_unique[0]
			[new_meta, ta_list.flatten().sort()]
		}
		// | filter {meta, ta_list -> ta_list.size() > 1}
		| set{ch_pooled_ta_input}

	CAT_FILES(ch_pooled_ta_input,"tagAlign.gz")

	ch_tagalign_reps
		| mix(ch_tagalign_pr)
		| mix(CAT_FILES.out.output)
		| set{ch_tagalign_output}
	
	ch_tagalign_output
		| branch{meta, ta ->
			sample_ta: meta.sample_type == "sample"
				[meta, ta]
			pr_ta: meta.sample_type == "pr"
			pooled_ta: meta.sample_type == "pooled" && !meta.pr_rep
				[meta, ta]
			pooled_pr_ta: meta.sample_type == "pooled" && meta.pr_rep
		}
		| set{ch_tagalign_publish}

	publish:
	ch_tagalign_publish.sample_ta    >> (save_sample_tagalign ? "encode/tagAlign" : null)
	ch_tagalign_publish.pr_ta        >> (save_pr_tagalign ? "encode/tagAlign" : null)
	ch_tagalign_publish.pooled_ta    >> (save_pooled_tagalign ? "encode/tagAlign" : null)
	ch_tagalign_publish.pooled_pr_ta >> (save_pooled_tagalign && save_pr_tagalign ? "encode/tagAlign" : null)

	emit:
	tagAlign = ch_tagalign_output

}