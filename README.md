# NF-ENCODE-ATAC

This is a nextflow-based pipeline designed to process ATAC-seq data based on
the ENCODE's ATAC-seq pipeline. It attempts to replicate the commands
that would normally be processed by ENCODE, but in a Nextflow-native format.

Please see the later section for more details.

## Citation / Credits

Please be sure you cite ENCODE's ATAC-seq pipeline if you use this pipeline:

- [ENCODE-DCC/atac-seq-pipeline:2.0.0](https://github.com/ENCODE-DCC/atac-seq-pipeline2/tree/v2.0.0)

## Quick Start

### Prerequisites

To use this workflow, you MUST have:

- [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html)

Additionally, it is HIGHLY recommended that you have one of:

- [Docker](https://www.docker.com/)
- [Singularity](https://sylabs.io/singularity/)
- [Apptainer](https://apptainer.org/)
- [Conda](https://docs.conda.io/en/latest/)

### Installation

The pipeline can be installed using the following command:

```bash
nextflow pull WeirauchLab/nf-encode-atac
```

If that fails, you can manually install the pipeline by cloning the repository:

```bash
git clone WeirauchLab/nf-encode-atac
```

### Prepare samplesheet

The pipeline requires a samplesheet in CSV format. The samplesheet should have
a combination of the following columns:

The samplesheet is a CSV file that contains the following columns:

| Column            | Required | Default | Description                                                      |
| ----------------- | -------- | ------- | ---------------------------------------------------------------- |
| id                | Yes      |         | The sample ID                                                    |
| group             | Yes      |         | A group name. Anything matching this gets treated as a replicate |
| control_sample_id | No       |         | The ID of the control sample.                                    |
| control_group_id  | No       |         | The ID of the control group                                      |
| fastq_1           | Yes      |         | The path to the first fastq file                                 |
| fastq_2           | No       |         | The path to the second fastq file                                |

An example samplesheet is shown below:

```csv
id,group,fastq_1,fastq_2
example1,example,/path/to/example1_R1.fastq.gz,/path/to/example1_R2.fastq.gz
example2,example,/path/to/example2_R1_1.fastq.gz,/path/to/example2_R2_1.fastq.gz
example2,example,/path/to/example2_R1_2.fastq.gz,/path/to/example2_R2_2.fastq.gz
```

If the fastq files for a sample are split across multiple files, you can specify
multiple rows for the same sample ID. They will be merged together (see "example2" in the csv table above).

#### About control groups

Control samples are typically IgG or input samples. This pipeline can handle this on a per-sample or per-group basis.
To implement this, you can specify either the `control_sample_id` or `control_group_id` column.

- Specify a sample ID that is a paired control

```csv
id,control_sample_id,group,fastq_1,fastq_2
target1,input1,example,/path/to/example1_R1.fastq.gz,/path/to/example1_R2.fastq.gz
target2,input2,example,/path/to/example1_R1.fastq.gz,/path/to/example1_R2.fastq.gz
input1,,example,/path/to/example2_R1_1.fastq.gz,/path/to/example2_R2_1.fastq.gz
input2,,example,/path/to/example2_R1_1.fastq.gz,/path/to/example2_R2_1.fastq.gz
```

If a `control_sample_id` is specified, the `control_group_id` column will be filled in during the pipeline.

- Specify a group name that is a control group

```csv
id,control_group_id,group,fastq_1,fastq_2
target1,input,target,/path/to/example1_R1.fastq.gz,/path/to/example1_R2.fastq.gz
target2,input,target,/path/to/example1_R1.fastq.gz,/path/to/example1_R2.fastq.gz
input1,,input,/path/to/example2_R1_1.fastq.gz,/path/to/example2_R2_1.fastq.gz
input2,,input,/path/to/example2_R1_1.fastq.gz,/path/to/example2_R2_1.fastq.gz
```

When doing it this way, the pooled control group will be used for all samples in the group.

### Locate reference genome files

At minimum, you need the following:

- reference genome in fasta format

It is recommended that you also have:

- GTF annotation file
- region exclusion bed file (if applicable)

### Create a parameters file

This is technically optional, but it is highly recommended.
A parameters file can be in either JSON or YAML format.
This file should contain the settings for the pipeline in a key-value format.
All available parameters can be found in the `nextflow.config` file and additional
validation information can be found in `nextflow_schema.json`.

A basic example may look like:

```json
{
  "input": "samplesheet.csv",
  "outdir": "results",
  "fasta": "/path/to/genome.fa",
  "gtf": "/path/to/annotation.gtf"
}
```

### Run the pipeline

To run the pipeline, you can use the following command:

```bash
# Basic command
nextflow run WeirauchLab/nf-encode-atac -params-file params.json

# Use profiles to specify execution profiles. Here, docker is used.
nextflow run WeirauchLab/nf-encode-atac -profile docker -params-file params.json
```

If all goes well, you should see the pipeline start processing your data.
Pipelines can also be resumed if needed by adding the `-resume` flag. This will
require that the `workDir` directory is still present.

## Pipeline Details

### From ENCODE's WDL to Nextflow

This pipeline is specifically based on [ENCODE-DCC/atac-seq-pipeline:2.0.0](https://github.com/ENCODE-DCC/atac-seq-pipeline/tree/v2.0.0).
The pipeline is designed to replicate the commands that would normally be processed by ENCODE, but in a Nextflow-native format.
This was done by looking through the repository, dissecting the commands, and converting them to Nextflow processes.
Several steps were validated by looking at the scripts run by Cromwell.

There are a few minor differences:

- SPP peak calling is not included.
- SPP's fragment estimation is performed on the full library, not just a subsampled tagAlign.
- SPP is not run using a re-aligned R1 file.
- Summits are not called by MACS2 (as default at least).
  - This is done in ENCODE, but we don't typically use them.
- Tool versions are not identical.

Additionally, there are a few "silent" differences:

- Pseudoreplicate generation was performed through a series of bash comands. This is now done through a python script.
- The method for determining conservative / optimal peak sets was coded in a new python script.

### Additional Features

Part of the reason for converting this pipeline was to add additional features that were not present in the original pipeline.
These features include:

- Support for building genome indices "on the fly"
  - There is no need to have a separate `genome.tsv` file anymore. Just supply what you have with the proper parameters. If a genome index isn't provided, it is built at the start of the run.
- Multiple conditions can be run at once.
- Additional bigwig normalized signal tracks are generated with `deepTools`.
- Trackhubs for UCSC Genome Browser can be generated.
- QC reporting is now done with MultiQC.
- Metagenomics section added to classify reads.

## FAQ

### Where can I find more information?

Check the documentation folder! This contains:

- rehash of the quickstart
- description of outputs
- comparison of commands between ENCODE and Nextflow
