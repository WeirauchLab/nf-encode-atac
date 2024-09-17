include { HOMER_FINDMOTIFSGENOME } from "../../modules/local/homer/findmotifsgenome/main"
include { HOMER_ANNOTATEPEAKS } from "../../modules/local/homer/annotatePeaks/main"
include { HOMER_POSTPROC_FINDMOTIFSGENOME } from "../../modules/local/homer/postproc_findmotifsgenome/main" 

workflow HOMER {
	take:
	ch_bed // channel: [ val(meta), path(bed) ]
	ch_genome_fasta // channel: [ val(meta), path(genome_fasta) ]
	ch_gtf // channel: [ val(meta), path(gtf) ]
	file_motif_lib // file: path(motif_lib) or []
	skip_findmotifsgenome
	skip_annotatepeaks

	main:

	ch_findmotifsgenome_results = Channel.empty()
	ch_findmotifsgenome_html    = Channel.empty()
	ch_findmotifsgenome_denovo  = Channel.empty()
	ch_findmotifsgenome_tar     = Channel.empty()
	if (!skip_findmotifsgenome) {
		HOMER_FINDMOTIFSGENOME(
			ch_bed,
			ch_genome_fasta,
			file_motif_lib
		)
		ch_findmotifsgenome_html   = HOMER_FINDMOTIFSGENOME.out.knownResults_html
		ch_findmotifsgenome_denovo = HOMER_FINDMOTIFSGENOME.out.homerResults_html
		ch_findmotifsgenome_tar    = HOMER_FINDMOTIFSGENOME.out.tar

		HOMER_POSTPROC_FINDMOTIFSGENOME(HOMER_FINDMOTIFSGENOME.out.knownResults)
		ch_findmotifsgenome_results = HOMER_POSTPROC_FINDMOTIFSGENOME.out.tsv
	}

	ch_annotatepeaks_tsv = Channel.empty()
	ch_annotatepeaks_annStats = Channel.empty()
	if (!skip_annotatepeaks) {
		HOMER_ANNOTATEPEAKS(
			ch_bed,
			ch_genome_fasta,
			ch_gtf
		)
		ch_annotatepeaks_tsv = HOMER_ANNOTATEPEAKS.out.tsv
		ch_annotatepeaks_annStats = HOMER_ANNOTATEPEAKS.out.annStats
	}

	emit:
	findMotifsGenome_tsv    = ch_findmotifsgenome_results
	annotatePeaks_tsv       = ch_annotatepeaks_tsv
	annotatePeaks_annStats  = ch_annotatepeaks_annStats
	findMotifsGenome_html   = ch_findmotifsgenome_html
	findMotifsGenome_denovo = ch_findmotifsgenome_denovo
	findMotifsGenome_tar    = ch_findmotifsgenome_tar

	publish:
	ch_findmotifsgenome_results >> "homer/findMotifsGenome"
	ch_findmotifsgenome_html    >> "homer/findMotifsGenome"
	ch_findmotifsgenome_denovo  >> "homer/findMotifsGenome"
	ch_findmotifsgenome_tar     >> "homer/findMotifsGenome"
	ch_annotatepeaks_tsv        >> "homer/annotatePeaks"
	ch_annotatepeaks_annStats   >> "homer/annotatePeaks"
}