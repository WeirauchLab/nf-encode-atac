# NF-ENCODE-ATAC Outputs

This pipeline generates several different files as output.

## ENCODE

### Genome Indices

```bash
├── genome
│   └── bowtie2
│       ├── genome.1.bt2
│       ├── genome.2.bt2
│       ├── genome.3.bt2
│       ├── genome.4.bt2
│       ├── genome.rev.1.bt2
│       └── genome.rev.2.bt2
```

If enabled, this will save the Bowtie2 indices for the genome that were built.

### TSS Regions

```bash
├── genome
│   └── *_tss.bed
```

If TSS regions were extracted from the GTF, they will be saved here.

### FASTQC

```bash
├── fastqc
│   ├── raw
│   │   ├── *_fastqc.html
│   │   └── *_fastqc.zip
│   └── trimmed
│       ├── *_fastqc.html
│       └── *_fastqc.zip
```

These are standard output files from FASTQC. They contain the typical report.

### FASTP

```bash
├── fastp
│   ├── *.fastp.html
│   └── *.fastp.json
```

FASTP report files. These contain the quality control information for the reads and trimming statistics.

### Alignments

```bash
├── encode
│   ├── alignments
│   │   ├── filtered
│   │   │   ├── *.nodup.bam
│   │   │   ├── *.nodup.bam.bai
│   │   │   └── alignments_filtered_index.csv
│   │   ├── flagstats
│   │   │   ├── aligned
│   │   │   │   └── *.flagstat
│   │   │   └── filtered
│   │   │       └── *.flagstat
│   │   └── raw
│   │       ├── *.bam
│   │       └── alignments_raw_index.csv
```

- `*.nodup.bam` represents the bam alignments that have been quality and duplicate filtered.
- `*.flagstat` contains the flagstats for the alignments.
- `*.bam` is the raw alignment file.

### Library complexity

```bash
├── encode
│   ├── lib_qc
│   │   └── *.lib_qc.tsv
```

The custom library complexity metric that is calculated by ENCODE.
Please see the multiQC report for more information.

### MACS2 Peaks

```bash
├── encode
│   ├── macs2
│   │   ├── filtered
│   │   │   ├── *.excl_filt.narrowPeak
│   │   │   ├── *_pr1.excl_filt.narrowPeak
│   │   │   └── *_pr2.excl_filt.narrowPeak
│   │   ├── idr
│   │   │   ├── *_idr_conservative.narrowPeak
│   │   │   ├── *_idr_optimal.narrowPeak
│   │   │   ├── *_X-vs-Y.idr-thresh.narrowPeak
│   │   │   ├── *_pr1-vs-pr2.idr-thresh.narrowPeak
│   │   │   └── macs2_idr_index.csv
│   │   ├── overlap
│   │   │   ├── *_overlap_conservative.narrowPeak
│   │   │   ├── *_overlap_optimal.narrowPeak
│   │   │   └── *_X-vs-Y.overlap.narrowPeak
│   │   └── raw
│   │       ├── *.narrowPeak
│   │       ├── *_pr1.narrowPeak
│   │       └── *_pr2.narrowPeak
```

- `.excl_filt.narrowPeak` MACS2 peaks that have had exclusion filtering applied.
- `*.idr-thresh.narrowPeak` IDR thresholded peaks. There will be several sets of these.
- `*.overlap.narrowPeak` Overlapping peaks between two conditions.

Conservative / optimal peak sets are determined by ENCODE's reproducibility analysis.
Please see the multiQC report for more information.

- `*_pr[12]*` are pseudoreplicate peaks.

#### Q-filtered peaks

Several of the commonly used peak files output by ENCODE are also filtered by a Q-value threshold.
These can be found in the following directory: `encode/macs2/qfiltered`.

The file pattern for these is: `qfilt-<THRESHOLD>_*`

#### Consensus Peaks

Consensus peaks across replicates are saved in the following directory: `encode/macs2/consensus_peaks`.
**This is not part of ENCODE's original outputs**.

To generate these peaks, the following steps are performed:
1. For each group with multiple replicates, the pooled replicate peaks are used as the "master" peak set.
2. Each replicate's peaks are overlapped with the pooled peaks. If there is at least 1 overlap for a peak that passes thresholds, it is given a score of 1 for that replicate.
3. The score column of the bed file is updated to reflect the number of replicates that overlap each pooled peak.

**IMPORTANT:** The output peak file represents the full set of pooled peaks, with an updated score column. There is no filtering performed!
This is subject to change, but the idea is that users can apply their own thresholds based on the number of replicates they want to require overlap in.

The output files are named as follows:

`*_consensus.(bed|narrowPeak|broadPeak)`: The consensus peaks for the group.
`*_consensus.json`: A JSON file that contains summary information about the consensus peaks.
`*_consensus_sessinfo.txt`: A session info file that contains information about the software versions used to generate the peaks.
`*_consensus.csv`: A CSV that contains expanded information about the consensus peaks, including the matrix of per-replicate overlaps.

Where `*` is the group name.

### SPP

```bash
├── encode
│   ├── spp
│   │   ├── *.crosscorr.csv
│   │   ├── *.spp.Rdata
│   │   ├── *.spp.out
│   │   └── *.spp.pdf
```

- `*.crosscorr.csv` is information extracted from the `Rdata` file that shows the correlation profile
- `*.spp.Rdata` SPP's data output. Can be loaded in R with `load()`
- `*.spp.out` SPP's main output log
- `*.spp.pdf` SPP's cross-correlation plot

### tagAlign

```bash
├── encode
│   └── tagAlign
│       ├── *.tagAlign.gz
│       └── tagAlign_index.csv
```

These are the bed-formatted alignments. They are generated based on the de-duplicated bam.

## BAM-related

### DeepTools

```bash
├── deeptools
│   ├── bamcoverage
│   │   └── *_normalized.bw
│   └── plotFingerprint
│       ├── *_fingerprint.tab
│       └── *_fingerprint.txt
```

- `*.normalized.bw` are the normalized bigwig files generated by `bamCoverage`.
  - These are generated from the filtered alignments.
- `*_fingerprint.*` are the output files from `plotFingerprint`.
  - This is the Jensen-Shannon divergence plot.

## Motif Enrichment

### HOMER

```bash
├── homer
│   ├── annotatePeaks
│   │   ├── *annStats.tsv
│   │   └── *annotatePeaks.tsv
│   └── findMotifsGenome
│       └── *knownResults.tsv
```

- `*annStats.tsv` are the annotation statistics calculated by HOMER `annotatePeaks.pl`.
- `*annotatePeaks.tsv` are the annotated peaks generated by HOMER `annotatePeaks.pl`.
- `*knownResults.tsv` are the known motif results generated by HOMER `findMotifsGenome.pl`.
  - This is a file that has been post-processed to unify header info and add log10 P-value as an output.

## Trackhubs

### UCSC Trackhub

```bash
└── trackhubs
    └── ucsc
        ├── data
        │   ├── dt_bigwig
        │   │   └── *_normalized.bw
        │   ├── idr_peaks
        │   │   ├── *_idr_conservative.bb
        │   │   └── *_idr_optimal.bb
        │   └── overlap_peaks
        │       ├── *_overlap_conservative.bb
        │       └── *_overlap_optimal.bb
        └── hub.txt
```

A basic trackhub structure that can be shared with the [UCSC Genome Browser](https://genome.ucsc.edu/cgi-bin/hgHubConnect).

## Metagenomics

### Kraken2

```bash
├── metagenomics
│   └── kraken2
│       └── *.kraken2.report
```

Kraken2 report files. These contain the taxonomic classification information for the reads.

## MultiQC

```bash
└── multiqc
   ├── multiqc_report.html
   ├── multiqc_report_data
   ├── *_summary.md
   └── *_summary.xlsx
```

The [MultiQC](https://multiqc.info/) report. This contains a summary of the quality control metrics for the entire pipeline.

- `*_summary.md`: mediawiki-formatted summary of the report.
- `*_summary.xlsx`: Excel-formatted summary of the report.

## Pipeline Info

```bash
├── pipeline_info
│   ├── execution_report_*.html
│   ├── execution_timeline_*.html
│   ├── execution_trace_*.txt
│   └── pipeline_dag_*.mmd
```

These are Nextflow's execution reports. They contain information about the pipeline run.

- `execution_report_*.html` is the main report.
- `execution_timeline_*.html` is the timeline report.
- `execution_trace_*.txt` This contains the record of each proces task that occurred.
- `pipeline_dag_*.mmd` is the pipeline's directed acyclic graph in [mermaid](https://www.mermaidchart.com/) format.
