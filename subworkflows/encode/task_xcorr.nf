include { RUN_SPP                } from "../../modules/local/phantompeakqualtools/run_spp/main"
include { EXTRACT_XCOR           } from "../../modules/local/phantompeakqualtools/extract_xcor/main"

workflow TASK_XCORR {
	take:
	ch_tagalign // [ val(meta), path(tagAlign) ]
	ch_mito_chr // string or []

	main:

	RUN_SPP(
		ch_tagalign.map{meta, tagalign -> [meta, tagalign, meta.chip_mode]},
		ch_mito_chr
	)
	EXTRACT_XCOR(RUN_SPP.out.rdata)
	// This extracts the fragment length from the SPP output and adds it to the metadata
	RUN_SPP.out.spp
		.join(ch_tagalign, by: 0)
		.map{meta, spp, ta ->
			def new_meta = meta.clone()
			// frag_len calculated by parsing spp's output. 3rd column, first entry.
			new_meta.frag_len = spp.readLines()[0].split("\t")[2] - ~/,.*/
			[ new_meta, ta ]
		}
		.set { ch_tagalign }

	publish:
	RUN_SPP.out          >> "encode/spp"
	EXTRACT_XCOR.out.csv >> "encode/spp"

	emit:
	spp       = RUN_SPP.out.spp
	xcorr_csv = EXTRACT_XCOR.out.csv
	tagAlign  = ch_tagalign

}