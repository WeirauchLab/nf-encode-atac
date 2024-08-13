# NF-ENCODE-CHIP Quickstart

This pipeline is designed to process ChIP-seq data. The pipeline takes raw fastq files as input and generates several different files as output. The pipeline performs several different steps. The main steps are:

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

nextflow pull cchmc/nf-encode-chip

```

If that fails, you can manually install the pipeline by cloning the repository:

```bash

git clone cchmc/nf-encode-chip

```

## Run configuration

At minimum the pipeline requires:

- A samplesheet in CSV format
- A reference genome in fasta format

It is HIGHLY recommended that a parameters file is created as well. This can be in either JSON or YAML format.

### Samplesheet

The samplesheet is a CSV file that contains the following columns:

| Column     | Required | Description                                                      |
| ---------- | -------- | ---------------------------------------------------------------- |
| id         | Yes      | The sample ID                                                    |
| group      | Yes      | A group name. Anything matching this gets treated as a replicate |
| control_id | No       | The ID of the control group                                      |
| fastq_1    | Yes      | The path to the first fastq file                                 |
| fastq_2    | No       | The path to the second fastq file                                |

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

## Run execution

After setting up a samplesheet and parameters file, the pipeline can be run with variations of the following command:

```bash

nextflow run cchmc/nf-encode-chip ...

```

### Specify parameters at runtime

If you don't want to use a parameters file, you can specify parameters at runtime:

```bash

nextflow run cchmc/nf-encode-chip --input samplesheet.csv --outdir results --fasta /path/to/genome.fa

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

nextflow run cchmc/nf-encode-chip -params-file params.json

```
