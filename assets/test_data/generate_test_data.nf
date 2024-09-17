nextflow.preview.output = true

process SUBSET_BAM {
    input:
    tuple val(meta), path(bam)

    conda "environment.yml"

    output:
    tuple val(meta), path("${meta.id}.{bam,bam.bai}"), emit: bam

    script:
    """
    samtools index ${bam}
    samtools view -b ${bam} ${meta.chr}:${meta.start}-${meta.end} > ${meta.id}.bam
    samtools index ${meta.id}.bam
    """
}

process BAMTOFASTQ {
    input:
    tuple val(meta), path(bam)

    conda "environment.yml"

    output:
    tuple val(meta), path("*_1.fastq.gz"), emit: fastq1
    tuple val(meta), path("*_2.fastq.gz"), emit: fastq2, optional: true

    script:
    def out_args = meta.single_end ? "-1 ${meta.id}_1.fastq" : "-1 ${meta.id}_1.fastq -2 ${meta.id}_2.fastq"
    """
    samtools fastq ${out_args} ${bam[0]}
    gzip *.fastq
    """
}

process SUBSET_FASTA {
    input:
    tuple val(meta), path(fasta)

    conda "environment.yml"

    output:
    tuple val(meta), path("${meta.id}.fa"), emit: fasta

    script:
    """
    gunzip -c ${fasta} > tmp.fa
    samtools faidx tmp.fa
    samtools faidx tmp.fa ${meta.chr}:${meta.start}-${meta.end} \\
        | sed 's/>\\(chr[0-9XYM]*\\):/>\\1 \\1:/' \\
        > ${meta.id}.fa
    """

}

workflow {

    Channel.fromPath("metadata.csv")
        .splitCsv(header: true)
        .map { row -> [row, file(row.file_path)] }
        .branch{meta, item -> 
            bam: meta.type == "bam"
            fasta: meta.type == "fasta"
        }
        .set { ch_sample_input }

    ch_sample_input.bam
        | SUBSET_BAM
        | BAMTOFASTQ
    
    BAMTOFASTQ.out.fastq1
        .join(BAMTOFASTQ.out.fastq2, by: 0, remainder: true)
        .map { meta, fastq1, fastq2 -> [meta, fastq1, fastq2 ?: []] }
        .set{ch_fastq}

    SUBSET_FASTA(ch_sample_input.fasta)

    publish:
    SUBSET_BAM.out   >> "bam"
    SUBSET_FASTA.out >> "fasta"
    ch_fastq         >> "fastq"
}

output {
    directory "data"
    mode "copy"

    'fastq' {
        index {
            path 'samplesheet.csv'
            header true
            mapper {meta, fastq1, fastq2 -> 
                def new_meta = meta.subMap("id","group","control_id") + ["fastq_1": fastq1.name]
                if (fastq2) new_meta.fastq_2 = fastq2.name
                new_meta
            }
        }
    }

    'bam' {
        index {
            path 'bam_index.csv'
            header true
            mapper {meta, bam -> meta}
        }
    }
}
