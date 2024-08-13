include { UCSC_BEDTOBIGBED } from '../../modules/local/ucsc/bedtoBigBed/main.nf'
include { UCSC_TRACKHUB                     } from '../../modules/local/ucsc_trackhub/main.nf'

workflow TRACKHUBS {
	take:
	ch_fai           // channel: [val(meta), path(fai)]
	ch_dt_bigwig     // channel: [val(meta), path(bigwig)]
	ch_encode_bigwig // channel: [val(meta), path(bigwig)]
	ch_idr_peaks     // channel: [val(meta), path(bed)]
	ch_overlap_peaks // channel: [val(meta), path(bed)]

	main:

	Channel.empty()
		.mix(ch_overlap_peaks.map{ meta, peak -> [ meta + [trackhub_peakset: "overlap"], peak ] })
		.mix(ch_idr_peaks.map{ meta, peak -> [ meta + [trackhub_peakset: "idr"], peak ] })
		.set{ch_peaks}

	UCSC_BEDTOBIGBED(ch_peaks, ch_fai)
	UCSC_BEDTOBIGBED.out.bigbed
		.branch{meta, bigbed ->
			idr: meta.trackhub_peakset == "idr"
			overlap: meta.trackhub_peakset == "overlap"
		}
		.set{ch_bigbed_branched}

	UCSC_TRACKHUB(
		ch_dt_bigwig.collect{it[1]}.ifEmpty{[]},
		ch_encode_bigwig.collect{it[1]}.ifEmpty{[]},
		ch_bigbed_branched.idr.collect{it[1]}.ifEmpty{[]},
		ch_bigbed_branched.overlap.collect{it[1]}.ifEmpty{[]}
	)

	publish:
	UCSC_TRACKHUB.out.data >> "trackhubs/ucsc"
	UCSC_TRACKHUB.out.hub  >> "trackhubs/ucsc"
}