process RENDER_MULTIQC_RMD {
	tag "Summary Report"
	container "community.wave.seqera.io/library/r-argparse_r-gt_r-gtextras_r-gtsummary_pruned:b5d515e22785d5ed"

	input:
	path rmd
	path multiqc_json

	output:
	path ("*.{md,html,pdf}"), emit: report

	script:
	def args = task.ext.args ?: ""
	def wf_args = [
		name: workflow.manifest.name ?: "",
		version: workflow.manifest.version ?: "",
		url: workflow.manifest.homePage ?: "",
		nf_version: nextflow.version ?: "",
		run_name: workflow.runName ?: "",
		revision: workflow.revision ?: "",
		user: workflow.userName ?: "",
	]
	"""
	#!/usr/bin/env Rscript

	rmarkdown::render(
		input = "${rmd}",
		output_format = "all",
		output_dir = ".",
		params = list(
			multiqc_json = "${multiqc_json}",
			wf_name = "${wf_args.name}",
			wf_version = "${wf_args.version}",
			wf_url = "${wf_args.url}",
			wf_user = "${wf_args.user}",
			wf_revision = "${wf_args.revision}",
			nf_version = "${wf_args.nf_version}",
			run_name = "${wf_args.run_name}"
		)
	)
	
	"""

	stub:
	"""
	touch report.md
	"""
}
