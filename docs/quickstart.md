# NF-ENCODE-ATAC Quickstart

This pipeline is designed to process ATAC-seq data. The pipeline takes raw fastq files as input and generates several different files as output. The pipeline performs several different steps. The main steps are:

## Requirements

The pipeline requires the following software to be installed:

- [Nextflow](https://www.nextflow.io/)

It is highly recommended that one of the following software packages be installed:

- [Docker](https://www.docker.com/)
- [Singularity](https://sylabs.io/singularity/)
- [Apptainer](https://apptainer.org/)
- [Conda](https://docs.conda.io/en/latest/)

## Installation

The pipeline can be installed using the following command:

```bash

nextflow pull cchmc/nf-encode-atac

```

If that fails, you can manually install the pipeline by cloning the repository:

```bash

git clone cchmc/nf-encode-atac

```

## Run configuration

At minimum the pipeline requires:

- A samplesheet in CSV format
- A reference genome in fasta format

It is HIGHLY recommended that a parameters file is created as well. This can be in either JSON or YAML format.

### Samplesheet

The samplesheet is a CSV file that contains the following columns:

| Column         | Required | Description                                                                                                                                       |
| -------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| id             | Yes      | The sample ID                                                                                                                                     |
| group          | Yes      | A group name. Anything matching this gets treated as a replicate                                                                                  |
| control_id     | No       | The ID of the control group                                                                                                                       |
| fastq_1        | Yes      | The path to the first fastq file                                                                                                                  |
| fastq_2        | No       | The path to the second fastq file                                                                                                                 |
| adapter_1      | No       | adapter sequence to trim for read 1. automatic if not supplied                                                                                    |
| adapter_2      | No       | adapter sequence to trim for read 2. automatic if not supplied                                                                                    |
| subsample_prop | No       | Can be a value between 0 and 1. If supplied, reads will be downsampled to X proportion of the original number. Ex: 0.6 will keep 60% of the reads |

A note about adapters:

If you do not specify an adapter, the pipeline will let fastp attempt to automatically detect the adapter sequence.
If you do specify an adapter, the pipeline will use that adapter sequence for trimming.
There are two params that can be used as well, `adapter_1` and `adapter_2`, which can be used to globally specify adapter sequences.
If these are set, any adapter sequences NOT specified in the samplesheet will use these values.

### Example samplesheet

```csv
id,group,fastq_1,fastq_2
CTCF_TREATED_1,CTCF_TREATED,/path/to/CTCF_TREATED_1_R1.fastq.gz,/path/to/CTCF_TREATED_1_R2.fastq.gz
CTCF_TREATED_2,CTCF_TREATED,/path/to/CTCF_TREATED_2_R1.fastq.gz,/path/to/CTCF_TREATED_2_R2.fastq.gz
CTCF_TREATED_3,CTCF_TREATED,/path/to/CTCF_TREATED_3_R1.fastq.gz,/path/to/CTCF_TREATED_3_R2.fastq.gz
CTCF_INPUT_1,CTCF_INPUT,/path/to/CTCF_INPUT_1_R1.fastq.gz,/path/to/CTCF_INPUT_1_R2.fastq.gz
CTCF_INPUT_2,CTCF_INPUT,/path/to/CTCF_INPUT_2_R1.fastq.gz,/path/to/CTCF_INPUT_2_R2.fastq.gz
CTCF_INPUT_3,CTCF_INPUT,/path/to/CTCF_INPUT_3_R1.fastq.gz,/path/to/CTCF_INPUT_3_R2.fastq.gz
```

#### What is a group?

A group is a set of samples that are treated as replicates. The pipeline will treat all samples with the same group name as replicates.

For instance, let's say there are 3 individual replicates for CTCF in a treatment:

- `CTCF_TREATED_1`
- `CTCF_TREATED_2`
- `CTCF_TREATED_3`

The group name for these samples should be `CTCF_TREATED`.

#### What is a control?

TODO: Add description

### TSS information

A pre-defined TSS bed file can be supplied using the `tss_bed` parameter. This file should be a bed file with a minimum of 3 columns: `chrom`, `start`, and `end`. The pipeline will use this file to extract TSS regions for the genome.

If a TSS file is not supplied (the default), then TSS regions will be extracted from the GTF file.
The regions included as a TSS are defined by the `gtf_tss_filters` parameter.
By default, the following filters are applied:

- `type`: `gene`
- `gene_type`: `protein_coding`

The parameter for this looks like: `"gtf_tss_filters": "type:gene,gene_type:protein_coding"`

`type` is a "special" column that is not found in the annotation string of the GTF file.
Rather, this represents the feature column (column 3) of the GTF file.
It is named `type` as `rtracklayer` / `GenomicRanges` uses this name for the feature column.

The structure for this string is `<META>:<VALUE>,<META2>:<VALUE1>:<VALUE2>,...` where `<META>` is the metadata field in the GTF file and `<VALUE>` is the value to filter on.
Multiple values can be supplied for a single metadata field by separating them with a colon.
Meta fields are separated by commas.
Fields that are not found are ignored with a warning.

An additional parameter, `gtf_tss_id_col`, can be supplied to name the output TSS regions.
By default, this is set to `gene_id`. Set this to `null` will not assign an ID to the TSS regions.

## Run execution

After setting up a samplesheet and parameters file, the pipeline can be run with variations of the following command:

```bash

nextflow run cchmc/nf-encode-atac ...

```

### Specify parameters at runtime

If you don't want to use a parameters file, you can specify parameters at runtime:

```bash

nextflow run cchmc/nf-encode-atac --input samplesheet.csv --outdir results --fasta /path/to/genome.fa

```

### Use a parameters file

This is the recommended approach. Create a parameters file in either JSON or YAML format:

```json
{
  "input": "samplesheet.csv",
  "outdir": "results",
  "fasta": "/path/to/genome.fa"
}
```

Then run the pipeline with the parameters file:

```bash

nextflow run cchmc/nf-encode-atac -params-file params.json

```
