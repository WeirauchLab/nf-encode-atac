process TSS_EXTRACT {
    tag "${meta.id}"
    cpus { 1 * task.attempt }
    memory { 16.GB * task.attempt }
    time { 2.h * task.attempt }

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/bioconductor-genomicfeatures_bioconductor-rtracklayer_r-argparse_r-tidyverse:27dbc246e1ceb6a3"

    input:
    tuple val(meta), path(gtf)

    output:
    tuple val(meta), path("*.bed"), emit: bed

    script:
    def prefix = task.ext.prefix ?: "${meta.id}_tss"
    def args = task.ext.args ?: ""
    """
    tss_extract.R \\
        --gtf ${gtf} \\
        --output ${meta.id}.bed \\
        ${args}
    """
}
