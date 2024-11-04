process SUMMARY {
    tag "summary"
    cache false

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/pip_pyyaml_openpyxl_pandas:481b30b6e965b4cd"

    input:
    path summary_config
    path key_motif_config
    path multiqc_data
    path "homer/*.tsv"

    output:
    path "ATAC_summary.xlsx", emit: summary

    script:
    def args = task.ext.args ?: ""
    def motifs = key_motif_config ? "--motif ${key_motif_config}" : ""
    """
    parse_chip_metrics.py --config ${summary_config} ${motifs} ${args} -o ATAC_summary ${multiqc_data}
    """
}