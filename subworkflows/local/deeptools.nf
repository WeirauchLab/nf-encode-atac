include { DEEPTOOLS_BAMCOVERAGE     } from "../../modules/local/deeptools/bamCoverage/main"
include { DEEPTOOLS_PLOTFINGERPRINT } from "../../modules/local/deeptools/plotFingerprint/main"

workflow DEEPTOOLS {
	take:
	ch_bam
	ch_bai
	skip_bamcoverage

	main:

	ch_bam_bai = ch_bam.join(ch_bai, by: 0)

	//----------------------------------------------------------//
	// bamCoverage
	//----------------------------------------------------------//
	
	ch_bamcoverage_bigwig = Channel.empty()
	if(!skip_bamcoverage){
		DEEPTOOLS_BAMCOVERAGE(
			ch_bam_bai
		)
		ch_bamcoverage_bigwig = DEEPTOOLS_BAMCOVERAGE.out.bigwig
	}

	//----------------------------------------------------------//
	// plotFingerprint
	//----------------------------------------------------------//

	ch_fingerprint_metrics = Channel.empty()
	ch_fingerprint_counts  = Channel.empty()
	DEEPTOOLS_PLOTFINGERPRINT(
		ch_bam_bai
	)
	ch_fingerprint_metrics = DEEPTOOLS_PLOTFINGERPRINT.out.quality_metrics
	ch_fingerprint_counts  = DEEPTOOLS_PLOTFINGERPRINT.out.raw_counts

	emit:
	bigwig              = ch_bamcoverage_bigwig
	fingerprint_metrics = ch_fingerprint_metrics
	fingerprint_counts  = ch_fingerprint_counts

	publish:
	ch_bamcoverage_bigwig  >> 'deeptools/bamcoverage'
	ch_fingerprint_metrics >> 'deeptools/plotFingerprint'
	ch_fingerprint_counts  >> 'deeptools/plotFingerprint'

}