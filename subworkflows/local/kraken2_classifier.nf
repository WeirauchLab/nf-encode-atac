include { UNTAR           } from "../../modules/nf-core/untar/main"
include { KRAKEN2_KRAKEN2 } from "../../modules/local/kraken2/kraken2/main"

workflow KRAKEN2_CLASSIFIER {
	take:
	ch_fastq	   // channel: [ val(meta), path(fastq1), path(fastq2) ]
	kraken2_db     // file or []

	main:

	//----------------------------------------------------------//
	// database preparation
	//----------------------------------------------------------//

	def db_is_tar = kraken2_db.toString() ==~ /.*\.tar$|.*\.tar\.gz$/
	if( db_is_tar ){
		ch_db = Channel.value([ [:], kraken2_db])
		UNTAR(
			ch_db
		)
		ch_db = UNTAR.out.untar
	} else {
		ch_db = Channel.value([ [:], kraken2_db])
	}

	//----------------------------------------------------------//
	// kraken2
	//----------------------------------------------------------//

	KRAKEN2_KRAKEN2(
		ch_fastq,
		ch_db
	)

	emit:
	report = KRAKEN2_KRAKEN2.out.report

	publish:
	KRAKEN2_KRAKEN2.out.report >> "metagenomics/kraken2"

}