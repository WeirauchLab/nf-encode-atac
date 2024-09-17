# Comparison of commands between ENCODE and current pipeline

This document seeks to compare the effective commands that are run between the pipelines
in order to ensure that the results are consistent.

## Genome preparation

### Bowtie2

This represents the code that is used to build the Bowtie2 index.

```bash

# ENCODE

bowtie2-build genome.fa genome --threads 1

# pipeline

bowtie2-build --threads 1 /path/to/genome.fa /path/to/genome

```

### gensz calculation

If not supplied, the genome size is calculated by the pipeline.

```bash

# ENCODE

GENSZ=$(cat $CHRSZ | awk '{sum+=$2} END{print sum}')
if [[ "${GENOME}" == hg* ]]; then GENSZ=hs; fi
if [[ "${GENOME}" == mm* ]]; then GENSZ=mm; fi

```

```nextflow
// pipeline
// this is done through channel manipulation on a genome fai file
// if supplied, the number or string is used

ch_genome_fai
	.map{ it[1] }
	.splitCsv(sep: '\t')
	.map {it -> it[1].toInteger() }
	.reduce {x,y -> x + y}
	.set {ch_gensz}

```

### Other

ENCODE creates a 2nd bowtie2 index based on the mitochondrial genome. We do not do this.
Additional files are downloaded such as global enhancers, region exclusions, global DNase hypersensitivity sites, etc.

## FASTQ pre-processing

### FASTQ merging

```bash
# ENCODE
zcat -f file1.fastq.gz file2.fastq.gz | gzip -c > merged.fastq.gz
```

```bash
# pipeline
cat file1.fastq.gz file2.fastq.gz > merged.fastq.gz
```

### FASTQC

This is specific to the current pipeline. It is run on the merged fastq files before and after trimming.

```bash
# renaming snippet from nf-core's fastqc module
printf "%s %s\n" ENCFF741YSW_subset_1.fastq.gz ENCFF741YSW_subset_1.gz ENCFF741YSW_subset_2.fastq.gz ENCFF741YSW_subset_2.gz | while read old_name new_name; do
    [ -f "${new_name}" ] || ln -s $old_name $new_name
done

fastqc \
    --threads 4 \
    ENCFF741YSW_subset_1.gz ENCFF741YSW_subset_2.gz

```

### Adapter trimming

ENCODE doesn't do this. They do have a step for truncating reads, but that is related to the re-alignment of R1 from
what I understand.

This pipeline uses [fastp](https://github.com/OpenGene/fastp) to trim and filter reads.

```bash

# snippet from nf-core's fastp module
[ ! -f  ENCFF869TVW_subset.fastq.gz ] && ln -sf ENCFF869TVW_subset.fastq.gz ENCFF869TVW_subset.fastq.gz

fastp \
	--in1 ENCFF869TVW_subset.fastq.gz \
	--out1 ENCFF869TVW_subset.fastp.fastq.gz \
	--json ENCFF869TVW_subset.fastp.json \
	--html ENCFF869TVW_subset.fastp.html \
	--thread 1

```

## Alignment

### Bowtie2

```bash
# ENCODE
bowtie2 \
	-k 1 \
	-X2000 \
	--mm \
	-x index_prefix \
	-1 r1.fastq.gz \
	| samtools view -1 -S /dev/stdin \
	> tmp.bam

samtools sort tmp.bam -o final.bam
```

```bash
# pipeline
bowtie2 \
	--threads 4 \
	-x genome \
	-1 ENCFF741YSW_subset_1.fastp.fastq.gz -2 ENCFF741YSW_subset_2.fastp.fastq.gz \
	-X2000 \
	2> >(tee ENCFF741YSW_subset.bowtie2.log >&2) \
| samtools view -1 -S /dev/stdin \
| samtools sort -@ 4 -o ENCFF741YSW_subset.bam
samtools index ENCFF741YSW_subset.bam
```

`-k 1` is a multimapping flag. Can be included if needed.

`--mm` is memory mapping I/O for index. Doesn't affect results.

## post-alignment

ENCODE runs SAMstats on the aligned bam.
We just do a samtools flagstat (which is a subset of SAMstats).

## Filtering

### Removing low quality reads

```bash
# ENCODE
## single-end

samtools view -F 1804 -q {mapq_thresh} -u {bam} \
samtools sort /dev/stdin -o {filt_bam} -T {prefix}

## paired-end

samtools view -F 1804 -f 2 -q {mapq_thresh} -u {bam} \
	| samtools sort -n /dev/stdin -o {tmp_filt_bam} -T {prefix}
samtools fixmate -r {tmp_filt_bam} {fixmate_bam}
samtools view -F 1804 -f 2 -u {fixmate_bam} \
	| samtools sort /dev/stdin -o {filt_bam} -T {prefix}

```

```bash
# pipeline
## single-end

samtools view \\
	-F 1804 \\
	${mapq_threshold ? "-q ${mapq_threshold}": ""} \\
	-u ${bam} \\
	| samtools sort \\
		/dev/stdin \\
		-o ${prefix}.bam \\
		-T tmp_${prefix}

## paired-end

samtools view \\
	-F 1804 \\
	-f 2 \\
	${mapq_threshold ? "-q ${mapq_threshold}": ""} \\
	-u ${bam} \\
	| samtools sort \\
		-n \\
	| samtools fixmate \\
		-r - - \\
	| samtools view \\
		-F 1804 \\
		-f 2 \\
		-u \\
	| samtools sort \\
		-o ${prefix}.bam \\
		-T tmp_${prefix}
```

### Marking duplicates

ENCODE uses Picard's MarkDuplicates. This is possible, but we have Sambamba as the default
due to problems with Picard on Rhel9.

### Removing duplicates

```bash
# ENCODE
## single-end
samtools view -F 1804 -b {dupmark_bam} > {nodup_bam}

## paired-end
samtools view -F 1804 -f 2 -b {dupmark_bam} > {nodup_bam}
```

```bash
# pipeline
## single-end
samtools view \\
	-F 1804 \\
	-b ${bam} \\
	> ${prefix}.bam

## paired-end
samtools view \\
	-F 1804 \\
	-f 2 \\
	-b ${bam} \\
	> ${prefix}.bam
```

## Library complexity

ENCODE wrote their own library complexity script.

```bash
# ENCODE
## single-end
bedtools bamtobed -i ${bam} | \
awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$6}' \
	| grep -v "^${mito_chr_name}\s" \
	| sort ${sort_param} \
	| uniq -c \
	| awk 'BEGIN{mt=0;m0=0;m1=0;m2=0} ($1==1){m1=m1+1} ($1==2){m2=m2+1} {m0=m0+1} {mt=mt+$1} END{m1_m2=-1.0; if(m2>0) m1_m2=m1/m2; m0_mt=0; if (mt>0) m0_mt=m0/mt; m1_m0=0; if (m0>0) m1_m0=m1/m0; printf "%d\t%d\t%d\t%d\t%f\t%f\t%f\n",mt,m0,m1,m2,m0_mt,m1_m0,m1_m2}' \
	> ${pbc_qc}

## paired-end
bedtools bamtobed -bedpe -i ${nmsrt_bam} | \
awk 'BEGIN{OFS="\t"}{print $1,$2,$4,$6,$9,$10}' \
    | grep -v "^${mito_chr_name}\s" \
    | sort ${sort_param} \
    | uniq -c \
    | awk 'BEGIN{mt=0;m0=0;m1=0;m2=0} ($1==1){m1=m1+1} ($1==2){m2=m2+1} {m0=m0+1} {mt=mt+$1} END{m1_m2=-1.0; if(m2>0) m1_m2=m1/m2; m0_mt=0; if (mt>0) m0_mt=m0/mt; m1_m0=0; if (m0>0) m1_m0=m1/m0; printf "%d\t%d\t%d\t%d\t%f\t%f\t%f\n",mt,m0,m1,m2,m0_mt,m1_m0,m1_m2}' \
    > ${pbc_qc}
```

```bash
# pipeline
## single-end
bedtools bamtobed -i ${bam} \\
	| awk 'BEGIN{OFS="\\t"}{print \$1,\$2,\$3,\$6}' \\
	${chr_filter} \\
	| sort \\
	| uniq -c \\
	| awk '
		BEGIN { mt=0; m0=0; m1=0; m2=0 }
		\$1 == 1 { m1++ }
		\$1 == 2 { m2++ }
		{ m0++; mt += \$1 }
		END {
			m1_m2 = (m2 > 0) ? m1/m2 : -1.0
			m0_mt = (mt > 0) ? m0/mt : 0
			m1_m0 = (m0 > 0) ? m1/m0 : 0
			printf "total_fragments\\tdistinct_fragments\\tpositions_with_one_read\\tpositions_with_two_reads\\tnrf\\tpbc1\\tpbc2\\n%d\\t%d\\t%d\\t%d\\t%.6f\\t%.6f\\t%.6f\\n", mt, m0, m1, m2, m0_mt, m1_m0, m1_m2
	}
	' \\
	> ${prefix}.lib_qc.tsv

## paired-end
samtools sort -n ${bam} \\
	| bedtools bamtobed -bedpe -i - \\
	| awk 'BEGIN{OFS="\\t"}{print \$1,\$2,\$4,\$6,\$9,\$10}' \\
	${chr_filter} \\
	| sort \\
	| uniq -c \\
	| awk '
		BEGIN { mt=0; m0=0; m1=0; m2=0 }
		\$1 == 1 { m1++ }
		\$1 == 2 { m2++ }
		{ m0++; mt += \$1 }
		END {
			m1_m2 = (m2 > 0) ? m1/m2 : -1.0
			m0_mt = (mt > 0) ? m0/mt : 0
			m1_m0 = (m0 > 0) ? m1/m0 : 0
			printf "total_fragments\\tdistinct_fragments\\tpositions_with_one_read\\tpositions_with_two_reads\\tnrf\\tpbc1\\tpbc2\\n%d\\t%d\\t%d\\t%d\\t%.6f\\t%.6f\\t%.6f\\n", mt, m0, m1, m2, m0_mt, m1_m0, m1_m2
		}
		' \\
	> ${prefix}.lib_qc.tsv

```

This contains minor formatting differences in the AWK script, but the results should be the same.

## tagAlign generation

```bash
# ENCODE
## single-end
bedtools bamtobed -i ${input_bam} \
	| awk 'BEGIN{OFS="\t"}{$4="N";$5="1000";print $0}' \
	| gzip -nc > ${output_file}

## paired-end
nmsrt_bam=$(samtools sort -n -@ ${nth} -o ${out_dir}/${prefix}.nmsrt.bam ${bam})

LC_COLLATE=C
bedtools bamtobed -bedpe -mate1 -i ${nmsrt_bam} \
	| gzip -nc > ${bedpe}

zcat -f ${bedpe} \
	| awk 'BEGIN{OFS="\t"} \
	{printf "%s\t%s\t%s\tN\t1000\t%s\n%s\t%s\t%s\tN\t1000\t%s\n\$1,\$2,\$3,\$9,\$4,\$5,\$6,\$10}' \
	gzip -nc > ${ta}
```

```bash
# pipeline
## single-end
bedtools bamtobed -i ${bam} \\
	| awk 'BEGIN{OFS="\\t"}{\$4="N";\$5="1000";print \$0}' \\
	| gzip -c > ${prefix}.tagAlign.gz

## paired-end
samtools sort -n ${bam} -o tmp_${prefix}.sorted.bam -T ${prefix}
bedtools bamtobed -bedpe -mate1 -i tmp_${prefix}.sorted.bam \\
	| awk 'BEGIN{OFS="\\t"}{fmt="%s\\t%s\\t%s\\tN\\t1000\\t%s\\n"; printf fmt, \$1, \$2, \$3, \$9; printf fmt, \$4, \$5, \$6, \$10 }' \\
	| gzip -c > ${prefix}.tagAlign.gz
```

Minor formatting differences in the AWK script, but the results should be the same.

Pooled tagAlign files are generated by concatenating the individual tagAlign files.

## Pseudoreplicates

PR are generated by subsampling the tagAlign file.
ENCODE does this through a bash script.
For readability, I converted this to a python script.

Main differences:

- ENCODE uses a hash function to determine the seed, we just use a number.
- `shuf` and `split` are used in ENCODE
- This pipeline uses a python script that achieves the same goal.
  - Reads a chunk of lines from the tagAlign file (~500k lines)
  - Randomly splits that chunk into two lists
  - Writes lists to separate files

## MACS2

### Peak calling

```bash
# ENCODE
macs2 callpeak \
	-t ${ta} ${ctl_param} \
	-f BED \
	-n ${prefix} \
	-g ${gensz} \
	-p ${pval_thresh} \
	--nomodel \
	--shift 0 \
	--extsize ${frag_length} \
	--keep-dup all \
	-B \
	--SPMR
```

```bash
# pipeline
macs2 callpeak \
	-t ${ta} ${ctl_param} \
	-f BED \
	-n ${prefix} \
	-g ${gensz} \
	-p ${pthresh} \
	--nomodel \
	--shift 0 \
	--extsize ${frag_length} \
	--keep-dup all \
	-B \
	--SPMR
```

- Both have a peak # filter.
- Both used `bedtools slop` after.

### Filter peaks

Both remove peaks that overlap exclusion regions.

### Signal tracks

```bash
# ENCODE
macs2 bdgcmp \
	-t "{prefix}_treat_pileup.bdg" \
	-c "{prefix}_control_lambda.bdg" \
	--o-prefix "{prefix}" \
	-m FE \

bedtools slop \
	-i "{prefix}_FE.bdg" \
	-g {chrsz} \
	-b 0 \
	| awk '{if ($3 != -1) print $0}' \
	| bedClip stdin {chrsz} {fc_bedgraph}

sort -k1,1 -k2,2n {fc_bedgraph} \
	| awk 'BEGIN{OFS="\t"}{if (NR==1 || NR>1 && (prev_chr!=$1 || prev_chr==$1 && prev_chr_e<=$2)) {print $0}; prev_chr=$1; prev_chr_e=$3;}' \
	> {fc_bedgraph_srt}

bedGraphToBigWig {fc_bedgraph_srt} {chrsz} {fc_bigwig}

sval = float(get_num_lines(ta))/1000000.0

macs2 bdgcmp -t "{prefix}_treat_pileup.bdg" \
-c "{prefix}_control_lambda.bdg" \
--o-prefix {prefix} -m ppois -S {sval}

bedtools slop -i "{prefix}_ppois.bdg" -g {chrsz} -b 0 \
	| awk '{if ($3 != -1) print $0}' \
	| bedClip stdin {chrsz} {pval_bedgraph}

sort -k1,1 -k2,2n {sort_param} {pval_bedgraph} \
	| awk 'BEGIN{OFS="\t"}{if (NR==1 || NR>1 && (prev_chr!=$1 || prev_chr==$1 && prev_chr_e<=$2)) {print $0}; prev_chr=$1; prev_chr_e=$3;}' \

bedGraphToBigWig {pval_bedgraph_srt} {chrsz} {pval_bigwig}

```

```bash
# pipeline
macs2 bdgcmp \\
	-t ${treat_pileup} \\
	-c ${control_lambda} \\
	--o-prefix ${prefix} \\
	-m FE
cut -f1,2 ${fai} > genome.sizes

# Make the FC signal bigwig
bedtools slop -i ${prefix}_FE.bdg -g genome.sizes -b 0 \\
	| awk '{if (\$3 != -1) print \$0}' \\
	| sort -k1,1 -k2,2n \\
	| awk 'BEGIN{OFS="\\t"}{if (NR==1 || NR>1 && (prev_chr!=\$1 || prev_chr==\$1 && prev_chr_e<=\$2)) {print \$0}; prev_chr=\$1; prev_chr_e=\$3;}' \\
	> ${prefix}_FE.bedGraph

bedGraphToBigWig ${prefix}_FE.bedGraph genome.sizes ${prefix}.fc.signal.bigwig
rm -f ${prefix}_FE.bedGraph ${prefix}_FE.bdg

# Make pval signal track
echo "${scale_factor}"

macs2 bdgcmp \\
	-t ${treat_pileup} \\
	-c ${control_lambda} \\
	--o-prefix ${prefix} \\
	-m ppois \\
	-S ${scale_factor}

bedtools slop -i ${prefix}_ppois.bdg -g genome.sizes -b 0 \\
	| awk '{if (\$3 != -1) print \$0}' \\
	| sort -k1,1 -k2,2n \\
	| awk 'BEGIN{OFS="\\t"}{if (NR==1 || NR>1 && (prev_chr != \$1 || prev_chr==\$1 && prev_chr_e<=\$2)) {print \$0}; prev_chr=\$1; prev_chr_e=\$3;}' \\
	> ${prefix}_ppois.bedGraph

bedGraphToBigWig ${prefix}_ppois.bedGraph genome.sizes ${prefix}.pval.signal.bigwig
rm -f ${prefix}_ppois.bedGraph ${prefix}_ppois.bdg
```

## Peak analysis

### IDR

```bash
# ENCODE
idr \
	--samples {peak1} {peak2} \
	--peak-list {peak_pooled} \
	--input-file-type narrowPeak \
	--output-file {idr_out} \
	--rank p.value \
	--soft-idr-threshold {thresh} \
	--plot \
	--use-best-multisummit-IDR \
	--log-output-file {idr_stdout}

awk 'BEGIN{OFS="\t"} $12>={neg_log10_thresh} {if ($2<0) $2=0; print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' {idr_tmp} \
	| sort {sort_param} \
	| uniq \
	| sort -grk{col},{col} {sort_param} \
	| gzip -nc \
	> {idr_12col_bed}
```

```bash
# pipeline
idr \
	--samples {peak1} {peak2} \
	--peak-list {peak_pooled} \
	--input-file-type narrowPeak \
	--output-file {prefix}.unthresholded-peaks.txt \
	--rank p.value \
	--soft-idr-threshold {thresh} \
	--plot

cat {idr_output} \
	| awk 'BEGIN{OFS="\t"} $12 >= 1.3010299956639813 {if ($2<0) $2=0; print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' \
	| sort \
	| uniq \
	| sort -k1,1 -k2,2n \
	> {prefix}.idr-thresh.narrowPeak
```

### Overlap

```bash
# ENCODE
intersectBed \
	${nonamecheck_param} \
	-wo \
    -a ${tmp_pooled} \
	-b ${tmp1} \
	| awk 'BEGIN{FS="\t";OFS="\t"} {s1=$3-$2; s2=$13-$12; if (($21/s1 >= 0.5) || ($21/s2 >= 0.5)) {print $0}}' \
	| cut -f 1-10 \
	| sort ${sort_param} \
	| uniq \
	intersectBed \
		${nonamecheck_param} \
		-wo \
    	-a stdin \
		-b ${tmp2} \
	| awk 'BEGIN{FS="\t";OFS="\t"} {s1=$3-$2; s2=$13-$12; if (($21/s1 >= 0.5) || ($21/s2 >= 0.5)) {print $0}}' \
	| cut -f 1-10 \
	| sort ${sort_param} \
	| uniq \
	| gzip -nc \
	> ${overlap_peak}
```

```bash
# pipeline
bedtools intersect \\
	-a <(bedtools sort -i $peak1) \\
	-b <(bedtools sort -i $peak2) \\
	-wo \\
	| awk 'BEGIN{FS="\\t";OFS="\\t"} {s1=\$3-\$2; s2=\$13-\$12; if ((\$21/s1 >= 0.5) || (\$21/s2 >= 0.5)) {print \$0}}' \\
	| cut -f 1-10 \\
	| sort \\
	| uniq \\
	| bedtools intersect \\
		-a stdin \\
		-b <(bedtools sort -i $peak2) \\
		-wo \\
	| awk 'BEGIN{FS="\\t";OFS="\\t"} {s1=\$3-\$2; s2=\$13-\$12; if ((\$21/s1 >= 0.5) || (\$21/s2 >= 0.5)) {print \$0}}' \\
	| cut -f 1-10 \\
	| sort \\
	| uniq \\
	> ${prefix}.overlap.narrowPeak
```

## Peak reproducibility

ENCODE's python script was re-written, but the results should be the same.
