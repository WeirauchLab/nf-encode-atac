process MULTIQC {
    tag "multiqc_report"
    cache false

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/multiqc:1.25--9968ff4994a2e2d7"

    input:
    path multiqc_config
    path "data/fastqc/raw/*"
    path "data/fastp/*"
    path "data/fastqc/trimmed/*"
    path "data/bowtie2_align/*"
    path "data/samtools_flagstat/filtered/*"
    path "data/picard_markduplicates/*"
    path "data/picard_collectinsertsizemetrics/*"
    path "data/mtnucratio/*"
    path "data/sambamba_markdup/*"
    path "data/lib_qc/*"
    path "data/spp/*"
    path "data/spp_xcor/*"
    path "data/encode_peakstats/*"
    path "data/encode_consistency/idr/*"
    path "data/encode_consistency/overlap/*"
    path "data/tss_enrichment/*"
    path "data/sourmash/gather/*"
    path "data/kraken2/*"
    path "data/encode_reproducibility_stats/idr/*"
    path "data/encode_reproducibility_stats/overlap/*"
    path "data/deeptools/plotFingerprint/qc_metrics/*"
    path "data/deeptools/plotFingerprint/raw_counts/*"
    path "data/homer/findMotifsGenome/*"
    path "data/homer/annStats/*"
    path "data/*"

    output:
    path "multiqc_report.html", optional: false, emit: html
    path "*_plots"            , optional:true  , emit: plots
    path "*_data"             , optional:true  , emit: data

    script:
    def args = task.ext.args ?: ""
    """
    run_multiqc.py --config ${multiqc_config}
    """
}