#!/bin/bash

# -------------------------
# FASTQ
# -------------------------

if [[ -z "$(which encode_task_merge_fastq.py 2> /dev/null || true)" ]]
then
  echo -e "\n* Error: pipeline environment (docker, singularity or conda) not found." 1>&2
  exit 3
fi
python3 $(which encode_task_merge_fastq.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-align/shard-0/execution/write_tsv_61adcbcb51c260689db07d99c8360463.tmp \
     \
    --nth 6

if [ -z '' ]; then
    SUFFIX=
else
    SUFFIX=_trimmed
    python3 $(which encode_task_trim_fastq.py) \
        R1/*.fastq.gz \
        --trim-bp  \
        --out-dir R1$SUFFIX
    if [ 'false' == 'true' ]; then
        python3 $(which encode_task_trim_fastq.py) \
            R2/*.fastq.gz \
            --trim-bp  \
            --out-dir R2$SUFFIX
    fi
fi
if [ '0' == '0' ]; then
    SUFFIX=$SUFFIX
else
    NEW_SUFFIX="$SUFFIX"_cropped
    python3 $(which encode_task_trimmomatic.py) \
        --fastq1 R1$SUFFIX/*.fastq.gz \
         \
         \
        --crop-length 0 \
        --crop-length-tol "2" \
        --phred-score-format auto \
        --out-dir-R1 R1$NEW_SUFFIX \
         \
        --trimmomatic-java-heap 8G \
        --nth 6
    SUFFIX=$NEW_SUFFIX
fi

if [[ -z "$(which encode_task_merge_fastq.py 2> /dev/null || true)" ]]
then
  echo -e "\n* Error: pipeline environment (docker, singularity or conda) not found." 1>&2
  exit 3
fi
python3 $(which encode_task_merge_fastq.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-align_R1/shard-2/execution/write_tsv_0f5409d24c4dca3de46045f2c3c5c491.tmp \
     \
    --nth 6

if [ -z '50' ]; then
    SUFFIX=
else
    SUFFIX=_trimmed
    python3 $(which encode_task_trim_fastq.py) \
        R1/*.fastq.gz \
        --trim-bp 50 \
        --out-dir R1$SUFFIX
    if [ 'false' == 'true' ]; then
        python3 $(which encode_task_trim_fastq.py) \
            R2/*.fastq.gz \
            --trim-bp 50 \
            --out-dir R2$SUFFIX
    fi
fi
if [ '0' == '0' ]; then
    SUFFIX=$SUFFIX
else
    NEW_SUFFIX="$SUFFIX"_cropped
    python3 $(which encode_task_trimmomatic.py) \
        --fastq1 R1$SUFFIX/*.fastq.gz \
         \
         \
        --crop-length 0 \
        --crop-length-tol "0" \
        --phred-score-format auto \
        --out-dir-R1 R1$NEW_SUFFIX \
         \
        --trimmomatic-java-heap 8G \
        --nth 6
    SUFFIX=$NEW_SUFFIX
fi

if [[ -z "$(which encode_task_merge_fastq.py 2> /dev/null || true)" ]]
then
  echo -e "\n* Error: pipeline environment (docker, singularity or conda) not found." 1>&2
  exit 3
fi
python3 $(which encode_task_merge_fastq.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-align_R1/shard-0/execution/write_tsv_fc94d4590f672ef5cbd94f59aca0cbca.tmp \
     \
    --nth 6

if [ -z '50' ]; then
    SUFFIX=
else
    SUFFIX=_trimmed
    python3 $(which encode_task_trim_fastq.py) \
        R1/*.fastq.gz \
        --trim-bp 50 \
        --out-dir R1$SUFFIX
    if [ 'false' == 'true' ]; then
        python3 $(which encode_task_trim_fastq.py) \
            R2/*.fastq.gz \
            --trim-bp 50 \
            --out-dir R2$SUFFIX
    fi
fi
if [ '0' == '0' ]; then
    SUFFIX=$SUFFIX
else
    NEW_SUFFIX="$SUFFIX"_cropped
    python3 $(which encode_task_trimmomatic.py) \
        --fastq1 R1$SUFFIX/*.fastq.gz \
         \
         \
        --crop-length 0 \
        --crop-length-tol "0" \
        --phred-score-format auto \
        --out-dir-R1 R1$NEW_SUFFIX \
         \
        --trimmomatic-java-heap 8G \
        --nth 6
    SUFFIX=$NEW_SUFFIX
fi

if [[ -z "$(which encode_task_merge_fastq.py 2> /dev/null || true)" ]]
then
  echo -e "\n* Error: pipeline environment (docker, singularity or conda) not found." 1>&2
  exit 3
fi
python3 $(which encode_task_merge_fastq.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-align_R1/shard-1/execution/write_tsv_e351a21e61e0de5886159f4907613dd9.tmp \
     \
    --nth 6

if [ -z '50' ]; then
    SUFFIX=
else
    SUFFIX=_trimmed
    python3 $(which encode_task_trim_fastq.py) \
        R1/*.fastq.gz \
        --trim-bp 50 \
        --out-dir R1$SUFFIX
    if [ 'false' == 'true' ]; then
        python3 $(which encode_task_trim_fastq.py) \
            R2/*.fastq.gz \
            --trim-bp 50 \
            --out-dir R2$SUFFIX
    fi
fi
if [ '0' == '0' ]; then
    SUFFIX=$SUFFIX
else
    NEW_SUFFIX="$SUFFIX"_cropped
    python3 $(which encode_task_trimmomatic.py) \
        --fastq1 R1$SUFFIX/*.fastq.gz \
         \
         \
        --crop-length 0 \
        --crop-length-tol "0" \
        --phred-score-format auto \
        --out-dir-R1 R1$NEW_SUFFIX \
         \
        --trimmomatic-java-heap 8G \
        --nth 6
    SUFFIX=$NEW_SUFFIX
fi

if [[ -z "$(which encode_task_merge_fastq.py 2> /dev/null || true)" ]]
then
  echo -e "\n* Error: pipeline environment (docker, singularity or conda) not found." 1>&2
  exit 3
fi
python3 $(which encode_task_merge_fastq.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-align/shard-2/execution/write_tsv_365b108cefe1f4dea44be9dda99755a8.tmp \
     \
    --nth 6

if [ -z '' ]; then
    SUFFIX=
else
    SUFFIX=_trimmed
    python3 $(which encode_task_trim_fastq.py) \
        R1/*.fastq.gz \
        --trim-bp  \
        --out-dir R1$SUFFIX
    if [ 'false' == 'true' ]; then
        python3 $(which encode_task_trim_fastq.py) \
            R2/*.fastq.gz \
            --trim-bp  \
            --out-dir R2$SUFFIX
    fi
fi
if [ '0' == '0' ]; then
    SUFFIX=$SUFFIX
else
    NEW_SUFFIX="$SUFFIX"_cropped
    python3 $(which encode_task_trimmomatic.py) \
        --fastq1 R1$SUFFIX/*.fastq.gz \
         \
         \
        --crop-length 0 \
        --crop-length-tol "2" \
        --phred-score-format auto \
        --out-dir-R1 R1$NEW_SUFFIX \
         \
        --trimmomatic-java-heap 8G \
        --nth 6
    SUFFIX=$NEW_SUFFIX
fi

# -------------------------
# alignment
# -------------------------

if [ 'bowtie2' == 'bowtie2' ]; then
    python3 $(which encode_task_bowtie2.py) \
        /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-align_R1/shard-2/inputs/1155345878/hg38_no_ebv.fa.tar.gz \
        R1$SUFFIX/*.fastq.gz \
         \
         \
         \
         \
        --mem-gb 7.087223538085819 \
        --nth 6

python3 $(which encode_task_post_align.py) \
    R1$SUFFIX/*.fastq.gz $(ls *.bam) \
    --mito-chr-name chrM \
    --mem-gb 7.087223538085819 \
    --nth 6
rm -rf R1 R2 R1$SUFFIX R2$SUFFIX
)

if [ 'bowtie2' == 'bowtie2' ]; then
    python3 $(which encode_task_bowtie2.py) \
        /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-align_R1/shard-0/inputs/1155345878/hg38_no_ebv.fa.tar.gz \
        R1$SUFFIX/*.fastq.gz \
         \
         \
         \
         \
        --mem-gb 7.1314882738515735 \
        --nth 6

python3 $(which encode_task_post_align.py) \
    R1$SUFFIX/*.fastq.gz $(ls *.bam) \
    --mito-chr-name chrM \
    --mem-gb 7.1314882738515735 \
    --nth 6
rm -rf R1 R2 R1$SUFFIX R2$SUFFIX
)

elif [ 'bowtie2' == 'bowtie2' ]; then
    python3 $(which encode_task_bowtie2.py) \
        /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-align_R1/shard-1/inputs/1155345878/hg38_no_ebv.fa.tar.gz \
        R1$SUFFIX/*.fastq.gz \
         \
         \
         \
         \
        --mem-gb 7.0902054631710065 \
        --nth 6

python3 $(which encode_task_post_align.py) \
    R1$SUFFIX/*.fastq.gz $(ls *.bam) \
    --mito-chr-name chrM \
    --mem-gb 7.0902054631710065 \
    --nth 6
rm -rf R1 R2 R1$SUFFIX R2$SUFFIX
)

elif [ 'bowtie2' == 'bowtie2' ]; then
    python3 $(which encode_task_bowtie2.py) \
        /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-align/shard-2/inputs/1155345878/hg38_no_ebv.fa.tar.gz \
        R1$SUFFIX/*.fastq.gz \
         \
         \
         \
         \
        --mem-gb 7.087223538085819 \
        --nth 6

python3 $(which encode_task_post_align.py) \
    R1$SUFFIX/*.fastq.gz $(ls *.bam) \
    --mito-chr-name chrM \
    --mem-gb 7.087223538085819 \
    --nth 6
rm -rf R1 R2 R1$SUFFIX R2$SUFFIX
)

if [ 'bowtie2' == 'bowtie2' ]; then
    python3 $(which encode_task_bowtie2.py) \
        /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-align/shard-0/inputs/1155345878/hg38_no_ebv.fa.tar.gz \
        R1$SUFFIX/*.fastq.gz \
         \
         \
         \
         \
        --mem-gb 7.1314882738515735 \
        --nth 6

python3 $(which encode_task_post_align.py) \
    R1$SUFFIX/*.fastq.gz $(ls *.bam) \
    --mito-chr-name chrM \
    --mem-gb 7.1314882738515735 \
    --nth 6
rm -rf R1 R2 R1$SUFFIX R2$SUFFIX

# --------------
# filter
# --------------


python3 $(which encode_task_filter.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter_R1/shard-2/inputs/-358999444/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.trim_50bp.srt.bam \
     \
    --multimapping 0 \
    --dup-marker picard \
    --mapq-thresh 30 \
    --filter-chrs  \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter_R1/shard-2/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --no-dup-removal \
    --mito-chr-name chrM \
    --mem-gb 5.321590542197228 \
    --nth 4 \
    --picard-java-heap 6G


python3 $(which encode_task_filter.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter_R1/shard-0/inputs/-343480726/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.trim_50bp.srt.bam \
     \
    --multimapping 0 \
    --dup-marker picard \
    --mapq-thresh 30 \
    --filter-chrs  \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter_R1/shard-0/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --no-dup-removal \
    --mito-chr-name chrM \
    --mem-gb 5.417828753590584 \
    --nth 4 \
    --picard-java-heap 6G


python3 $(which encode_task_filter.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter_R1/shard-1/inputs/-351240085/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.trim_50bp.srt.bam \
     \
    --multimapping 0 \
    --dup-marker picard \
    --mapq-thresh 30 \
    --filter-chrs  \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter_R1/shard-1/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --no-dup-removal \
    --mito-chr-name chrM \
    --mem-gb 5.330585401952267 \
    --nth 4 \
    --picard-java-heap 6G

python3 $(which encode_task_filter.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter/shard-2/inputs/1507790812/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.bam \
     \
    --multimapping 0 \
    --dup-marker picard \
    --mapq-thresh 30 \
    --filter-chrs  \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter/shard-2/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
     \
    --mito-chr-name chrM \
    --mem-gb 5.53434184640646 \
    --nth 4 \
    --picard-java-heap 6G

python3 $(which encode_task_filter.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter/shard-0/inputs/1523309530/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.bam \
     \
    --multimapping 0 \
    --dup-marker picard \
    --mapq-thresh 30 \
    --filter-chrs  \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter/shard-0/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
     \
    --mito-chr-name chrM \
    --mem-gb 5.643867046535015 \
    --nth 4 \
    --picard-java-heap 6G

python3 $(which encode_task_filter.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter/shard-1/inputs/1515550171/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.bam \
     \
    --multimapping 0 \
    --dup-marker picard \
    --mapq-thresh 30 \
    --filter-chrs  \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-filter/shard-1/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
     \
    --mito-chr-name chrM \
    --mem-gb 5.54207851946354 \
    --nth 4 \
    --picard-java-heap 6G

# --------------
# bam 2 ta
# --------------

python3 $(which encode_task_bam2ta.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-bam2ta/shard-2/inputs/-165347637/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.bam \
    --disable-tn5-shift \
     \
    --mito-chr-name chrM \
    --subsample 0 \
    --mem-gb 3.556065698899329 \
    --nth 2
)
python3 $(which encode_task_bam2ta.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-bam2ta/shard-0/inputs/-149828919/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.bam \
    --disable-tn5-shift \
     \
    --mito-chr-name chrM \
    --subsample 0 \
    --mem-gb 3.5275596095249058 \
    --nth 2
)
python3 $(which encode_task_bam2ta.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-bam2ta/shard-1/inputs/-157588278/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.bam \
    --disable-tn5-shift \
     \
    --mito-chr-name chrM \
    --subsample 0 \
    --mem-gb 3.5958179824426773 \
    --nth 2
)

python3 $(which encode_task_bam2ta.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-bam2ta_no_dedup_R1/shard-2/inputs/-1731063523/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.trim_50bp.srt.filt.bam \
    --disable-tn5-shift \
     \
    --mito-chr-name chrM \
    --subsample 0 \
    --mem-gb 3.5637846633791925 \
    --nth 2
)
python3 $(which encode_task_bam2ta.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-bam2ta_no_dedup_R1/shard-0/inputs/-1715544805/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.trim_50bp.srt.filt.bam \
    --disable-tn5-shift \
     \
    --mito-chr-name chrM \
    --subsample 0 \
    --mem-gb 3.625803865417838 \
    --nth 2
)
python3 $(which encode_task_bam2ta.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-bam2ta_no_dedup_R1/shard-1/inputs/-1723304164/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.trim_50bp.srt.filt.bam \
    --disable-tn5-shift \
     \
    --mito-chr-name chrM \
    --subsample 0 \
    --mem-gb 3.576691505014897 \
    --nth 2
)

# -------------------------
# peak calling
# -------------------------

if [ 'macs2' == 'macs2' ]; then
    python3 $(which encode_task_macs2_chip.py) \
        /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-2/inputs/-113715497/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pr1.tagAlign.gz \
        --gensz hs \
        --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-2/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
        --fraglen 130 \
        --cap-num-peak 500000 \
        --pval-thresh 0.01 \
        --mem-gb 4.568712223321199


python3 $(which encode_task_post_call_peak_chip.py) \
    $(ls *Peak.gz) \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-2/inputs/-113715497/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pr1.tagAlign.gz \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-2/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --fraglen 130 \
    --peak-type narrowPeak \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-2/inputs/-215527706/ENCFF356LFX.bed.gz
)

if [ 'macs2' == 'macs2' ]; then
    python3 $(which encode_task_macs2_chip.py) \
        /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-0/inputs/-98196779/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pr1.tagAlign.gz \
        --gensz hs \
        --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-0/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
        --fraglen 65 \
        --cap-num-peak 500000 \
        --pval-thresh 0.01 \
        --mem-gb 4.516493343748152

python3 $(which encode_task_post_call_peak_chip.py) \
    $(ls *Peak.gz) \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-0/inputs/-98196779/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pr1.tagAlign.gz \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-0/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --fraglen 65 \
    --peak-type narrowPeak \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-0/inputs/-215527706/ENCFF356LFX.bed.gz

if [ 'macs2' == 'macs2' ]; then
    python3 $(which encode_task_macs2_chip.py) \
        /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-1/inputs/-105956138/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pr1.tagAlign.gz \
        --gensz hs \
        --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-1/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
        --fraglen 140 \
        --cap-num-peak 500000 \
        --pval-thresh 0.01 \
        --mem-gb 4.636018561199307

python3 $(which encode_task_post_call_peak_chip.py) \
    $(ls *Peak.gz) \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-1/inputs/-105956138/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pr1.tagAlign.gz \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-1/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --fraglen 140 \
    --peak-type narrowPeak \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-call_peak_pr1/shard-1/inputs/-215527706/ENCFF356LFX.bed.gz
)

# -------------------------
# pseudoreps
# -------------------------

python3 $(which encode_task_spr.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-spr/shard-2/inputs/43783909/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.tagAlign.gz \
    --pseudoreplication-random-seed 0 \
)

python3 $(which encode_task_spr.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-spr/shard-0/inputs/59302627/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.tagAlign.gz \
    --pseudoreplication-random-seed 0 \
)

python3 $(which encode_task_spr.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-spr/shard-1/inputs/51543268/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.tagAlign.gz \
    --pseudoreplication-random-seed 0 \
)

# -------------------------
# IDR
# -------------------------

python3 $(which encode_task_idr.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_ppr/inputs/-1558685416/rep-pr1.pooled.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_ppr/inputs/-1566444775/rep-pr2.pooled.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_ppr/inputs/-507072620/rep.pooled.pval0.01.500K.narrowPeak.gz \
    --prefix pooled-pr1_vs_pooled-pr2 \
    --idr-thresh 0.05 \
    --peak-type narrowPeak \
    --idr-rank p.value \
    --fraglen 112 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_ppr/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_ppr/inputs/-215527706/ENCFF356LFX.bed.gz \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_ppr/inputs/-999592172/rep.pooled.tagAlign.gz
)

python3 $(which encode_task_idr.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-2/inputs/-1228640528/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-2/inputs/-1244159246/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-2/inputs/-507072620/rep.pooled.pval0.01.500K.narrowPeak.gz \
    --prefix rep1_vs_rep3 \
    --idr-thresh 0.05 \
    --peak-type narrowPeak \
    --idr-rank p.value \
    --fraglen 112 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-2/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-2/inputs/-215527706/ENCFF356LFX.bed.gz \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-2/inputs/-999592172/rep.pooled.tagAlign.gz
)
python3 $(which encode_task_idr.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-5/inputs/-1236399887/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-5/inputs/-1244159246/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-5/inputs/-507072620/rep.pooled.pval0.01.500K.narrowPeak.gz \
    --prefix rep2_vs_rep3 \
    --idr-thresh 0.05 \
    --peak-type narrowPeak \
    --idr-rank p.value \
    --fraglen 112 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-5/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-5/inputs/-215527706/ENCFF356LFX.bed.gz \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-5/inputs/-999592172/rep.pooled.tagAlign.gz
)
python3 $(which encode_task_idr.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-1/inputs/-1228640528/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-1/inputs/-1236399887/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-1/inputs/-507072620/rep.pooled.pval0.01.500K.narrowPeak.gz \
    --prefix rep1_vs_rep2 \
    --idr-thresh 0.05 \
    --peak-type narrowPeak \
    --idr-rank p.value \
    --fraglen 112 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-1/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-1/inputs/-215527706/ENCFF356LFX.bed.gz \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr/shard-1/inputs/-999592172/rep.pooled.tagAlign.gz
)

python3 $(which encode_task_idr.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-2/inputs/1240474530/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pr1.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-2/inputs/1870933155/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pr2.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-2/inputs/-1244159246/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz \
    --prefix rep3-pr1_vs_rep3-pr2 \
    --idr-thresh 0.05 \
    --peak-type narrowPeak \
    --idr-rank p.value \
    --fraglen 130 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-2/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-2/inputs/-215527706/ENCFF356LFX.bed.gz \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-2/inputs/43783909/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.tagAlign.gz
)
python3 $(which encode_task_idr.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-0/inputs/1255993248/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pr1.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-0/inputs/1886451873/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pr2.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-0/inputs/-1228640528/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz \
    --prefix rep1-pr1_vs_rep1-pr2 \
    --idr-thresh 0.05 \
    --peak-type narrowPeak \
    --idr-rank p.value \
    --fraglen 65 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-0/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-0/inputs/-215527706/ENCFF356LFX.bed.gz \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-0/inputs/59302627/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.tagAlign.gz
)
python3 $(which encode_task_idr.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-1/inputs/1248233889/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pr1.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-1/inputs/1878692514/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pr2.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-1/inputs/-1236399887/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz \
    --prefix rep2-pr1_vs_rep2-pr2 \
    --idr-thresh 0.05 \
    --peak-type narrowPeak \
    --idr-rank p.value \
    --fraglen 140 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-1/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-1/inputs/-215527706/ENCFF356LFX.bed.gz \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-idr_pr/shard-1/inputs/51543268/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.tagAlign.gz
)



# --------------
# pool TA
# --------------

python3 $(which encode_task_pool_ta.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-pool_ta_pr2/inputs/-2061818082/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pr2.tagAlign.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-pool_ta_pr2/inputs/-2069577441/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pr2.tagAlign.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-pool_ta_pr2/inputs/-2077336800/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pr2.tagAlign.gz \
    --prefix rep-pr2 \
)

python3 $(which encode_task_pool_ta.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-pool_ta_pr1/inputs/-98196779/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pr1.tagAlign.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-pool_ta_pr1/inputs/-105956138/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pr1.tagAlign.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-pool_ta_pr1/inputs/-113715497/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pr1.tagAlign.gz \
    --prefix rep-pr1 \
)

python3 $(which encode_task_pool_ta.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-pool_ta/inputs/59302627/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.tagAlign.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-pool_ta/inputs/51543268/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.tagAlign.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-pool_ta/inputs/43783909/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.tagAlign.gz \
    --prefix rep \
)



# --------------
# reproducibility
# --------------

python3 $(which encode_task_reproducibility.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_idr/inputs/-17616282/rep1_vs_rep2.idr0.05.bfilt.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_idr/inputs/-25375641/rep1_vs_rep3.idr0.05.bfilt.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_idr/inputs/-48653718/rep2_vs_rep3.idr0.05.bfilt.narrowPeak.gz \
    --peaks-pr /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_idr/inputs/-1976944588/rep1-pr1_vs_rep1-pr2.idr0.05.bfilt.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_idr/inputs/-1984703947/rep2-pr1_vs_rep2-pr2.idr0.05.bfilt.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_idr/inputs/-1992463306/rep3-pr1_vs_rep3-pr2.idr0.05.bfilt.narrowPeak.gz \
    --peak-ppr /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_idr/inputs/1975236006/pooled-pr1_vs_pooled-pr2.idr0.05.bfilt.narrowPeak.gz \
    --prefix idr \
    --peak-type narrowPeak \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_idr/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv
)

python3 $(which encode_task_reproducibility.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_overlap/inputs/-1650348298/rep1_vs_rep2.overlap.bfilt.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_overlap/inputs/-1658107657/rep1_vs_rep3.overlap.bfilt.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_overlap/inputs/-1681385734/rep2_vs_rep3.overlap.bfilt.narrowPeak.gz \
    --peaks-pr /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_overlap/inputs/2103161252/rep1-pr1_vs_rep1-pr2.overlap.bfilt.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_overlap/inputs/2095401893/rep2-pr1_vs_rep2-pr2.overlap.bfilt.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_overlap/inputs/2087642534/rep3-pr1_vs_rep3-pr2.overlap.bfilt.narrowPeak.gz \
    --peak-ppr /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_overlap/inputs/129956406/pooled-pr1_vs_pooled-pr2.overlap.bfilt.narrowPeak.gz \
    --prefix overlap \
    --peak-type narrowPeak \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-reproducibility_overlap/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv
)

# --------------
# overlap
# --------------


python3 $(which encode_task_overlap.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-2/inputs/-1228640528/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-2/inputs/-1244159246/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-2/inputs/-507072620/rep.pooled.pval0.01.500K.narrowPeak.gz \
    --prefix rep1_vs_rep3 \
    --peak-type narrowPeak \
    --fraglen 112 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-2/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-2/inputs/-215527706/ENCFF356LFX.bed.gz \
    --nonamecheck \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-2/inputs/-999592172/rep.pooled.tagAlign.gz
)

python3 $(which encode_task_overlap.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-5/inputs/-1236399887/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-5/inputs/-1244159246/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-5/inputs/-507072620/rep.pooled.pval0.01.500K.narrowPeak.gz \
    --prefix rep2_vs_rep3 \
    --peak-type narrowPeak \
    --fraglen 112 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-5/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-5/inputs/-215527706/ENCFF356LFX.bed.gz \
    --nonamecheck \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-5/inputs/-999592172/rep.pooled.tagAlign.gz
)

python3 $(which encode_task_overlap.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-1/inputs/-1228640528/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-1/inputs/-1236399887/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-1/inputs/-507072620/rep.pooled.pval0.01.500K.narrowPeak.gz \
    --prefix rep1_vs_rep2 \
    --peak-type narrowPeak \
    --fraglen 112 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-1/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-1/inputs/-215527706/ENCFF356LFX.bed.gz \
    --nonamecheck \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap/shard-1/inputs/-999592172/rep.pooled.tagAlign.gz
)

python3 $(which encode_task_overlap.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_ppr/inputs/-1558685416/rep-pr1.pooled.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_ppr/inputs/-1566444775/rep-pr2.pooled.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_ppr/inputs/-507072620/rep.pooled.pval0.01.500K.narrowPeak.gz \
    --prefix pooled-pr1_vs_pooled-pr2 \
    --peak-type narrowPeak \
    --fraglen 112 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_ppr/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_ppr/inputs/-215527706/ENCFF356LFX.bed.gz \
    --nonamecheck \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_ppr/inputs/-999592172/rep.pooled.tagAlign.gz
)

python3 $(which encode_task_overlap.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-2/inputs/1240474530/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pr1.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-2/inputs/1870933155/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pr2.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-2/inputs/-1244159246/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz \
    --prefix rep3-pr1_vs_rep3-pr2 \
    --peak-type narrowPeak \
    --fraglen 130 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-2/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-2/inputs/-215527706/ENCFF356LFX.bed.gz \
    --nonamecheck \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-2/inputs/43783909/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.tagAlign.gz
)

python3 $(which encode_task_overlap.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-0/inputs/1255993248/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pr1.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-0/inputs/1886451873/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pr2.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-0/inputs/-1228640528/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz \
    --prefix rep1-pr1_vs_rep1-pr2 \
    --peak-type narrowPeak \
    --fraglen 65 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-0/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-0/inputs/-215527706/ENCFF356LFX.bed.gz \
    --nonamecheck \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-0/inputs/59302627/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.tagAlign.gz
)
python3 $(which encode_task_overlap.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-1/inputs/1248233889/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pr1.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-1/inputs/1878692514/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pr2.pval0.01.500K.narrowPeak.gz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-1/inputs/-1236399887/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pval0.01.500K.narrowPeak.gz \
    --prefix rep2-pr1_vs_rep2-pr2 \
    --peak-type narrowPeak \
    --fraglen 140 \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-1/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-1/inputs/-215527706/ENCFF356LFX.bed.gz \
    --nonamecheck \
    --regex-bfilt-peak-chr-name 'chr[\dXY]+' \
    --ta /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-overlap_pr/shard-1/inputs/51543268/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.tagAlign.gz
)

# --------------
# gc bias
# --------------

python3 $(which encode_task_gc_bias.py) \
    --nodup-bam /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-gc_bias/shard-2/inputs/-165347637/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.bam \
    --ref-fa /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-gc_bias/shard-2/inputs/-215527706/hg38_no_ebv.fa.gz \
    --picard-java-heap 4G
)
python3 $(which encode_task_gc_bias.py) \
    --nodup-bam /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-gc_bias/shard-0/inputs/-149828919/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.bam \
    --ref-fa /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-gc_bias/shard-0/inputs/-215527706/hg38_no_ebv.fa.gz \
    --picard-java-heap 4G
)
python3 $(which encode_task_gc_bias.py) \
    --nodup-bam /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-gc_bias/shard-1/inputs/-157588278/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.bam \
    --ref-fa /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-gc_bias/shard-1/inputs/-215527706/hg38_no_ebv.fa.gz \
    --picard-java-heap 4G
)

# --------------
# qc report
# --------------

python3 $(which encode_task_qc_report.py) \
    --pipeline-ver v2.0.0 \
    --title 'UM-SCC-6: TEAD1 ChIP' \
    --desc 'ChIP-seq for TEAD1 in the UM-SCC-6 cell line.' \
    --genome hg38 \
    --multimapping 0 \
    --paired-ends false false false \
    --ctl-paired-ends  \
    --pipeline-type tf \
    --aligner bowtie2 \
    --peak-caller macs2 \
    --cap-num-peak 500000 \
    --idr-thresh 0.05 \
    --pval-thresh 0.01 \
    --xcor-trim-bp 50 \
    --xcor-subsample-reads 15000000 \
    --samstat-qcs /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/412451225/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.samstats.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/404691866/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.samstats.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/396932507/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.samstats.qc \
    --nodup-samstat-qcs /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1260687224/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.samstats.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1268446583/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.samstats.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1276205942/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.samstats.qc \
    --dup-qcs /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/553578998/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.dup.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/545819639/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.dup.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/538060280/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.dup.qc \
    --lib-complexity-qcs /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1480122365/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.lib_complexity.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1487881724/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.lib_complexity.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1495641083/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.lib_complexity.qc \
    --xcor-plots /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/910526826/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.trim_50bp.srt.filt.no_chrM.15M.cc.plot.png_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/902767467/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.trim_50bp.srt.filt.no_chrM.15M.cc.plot.png_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/895008108/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.trim_50bp.srt.filt.no_chrM.15M.cc.plot.png \
    --xcor-scores /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-2028174458/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.trim_50bp.srt.filt.no_chrM.15M.cc.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-2035933817/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.trim_50bp.srt.filt.no_chrM.15M.cc.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-2043693176/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.trim_50bp.srt.filt.no_chrM.15M.cc.qc \
    --idr-plots /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/2929912/rep1_vs_rep2.idr0.05.unthresholded-peaks.txt.png_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-4829447/rep1_vs_rep3.idr0.05.unthresholded-peaks.txt.png_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-28107524/rep2_vs_rep3.idr0.05.unthresholded-peaks.txt.png \
    --idr-plots-pr /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1956398394/rep1-pr1_vs_rep1-pr2.idr0.05.unthresholded-peaks.txt.png_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1964157753/rep2-pr1_vs_rep2-pr2.idr0.05.unthresholded-peaks.txt.png_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1971917112/rep3-pr1_vs_rep3-pr2.idr0.05.unthresholded-peaks.txt.png \
    --ctl-samstat-qcs  \
    --ctl-nodup-samstat-qcs  \
    --ctl-dup-qcs  \
    --ctl-lib-complexity-qcs  \
    --jsd-plot /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1555611221/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.jsd_plot.png \
    --jsd-qcs /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1410456019/rep1.ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.bfilt.jsd.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1410456019/rep2.ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.bfilt.jsd.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1410456019/rep3.ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.bfilt.jsd.qc \
    --idr-plot-ppr /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1995782200/pooled-pr1_vs_pooled-pr2.idr0.05.unthresholded-peaks.txt.png \
    --frip-qcs /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1688128302/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1680368943/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1672609584/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.frip.qc \
    --frip-qcs-pr1 /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-122205218/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pr1.pval0.01.500K.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-129964577/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pr1.pval0.01.500K.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-137723936/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pr1.pval0.01.500K.bfilt.frip.qc \
    --frip-qcs-pr2 /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/508253407/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pr2.pval0.01.500K.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/500494048/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pr2.pval0.01.500K.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/492734689/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pr2.pval0.01.500K.bfilt.frip.qc \
    --frip-qc-pooled /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1885271086/rep.pooled.pval0.01.500K.bfilt.frip.qc \
    --frip-qc-ppr1 /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1358083414/rep-pr1.pooled.pval0.01.500K.bfilt.frip.qc \
    --frip-qc-ppr2 /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1350324055/rep-pr2.pooled.pval0.01.500K.bfilt.frip.qc \
    --frip-idr-qcs /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-505871802/rep1_vs_rep2.idr0.05.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-513631161/rep1_vs_rep3.idr0.05.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-536909238/rep2_vs_rep3.idr0.05.bfilt.frip.qc \
    --frip-idr-qcs-pr /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1829767188/rep1-pr1_vs_rep1-pr2.idr0.05.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1822007829/rep2-pr1_vs_rep2-pr2.idr0.05.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1814248470/rep3-pr1_vs_rep3-pr2.idr0.05.bfilt.frip.qc \
    --frip-idr-qc-ppr /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1486980486/pooled-pr1_vs_pooled-pr2.idr0.05.bfilt.frip.qc \
    --frip-overlap-qcs /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-2138603818/rep1_vs_rep2.overlap.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-2146363177/rep1_vs_rep3.overlap.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/2125326042/rep2_vs_rep3.overlap.bfilt.frip.qc \
    --frip-overlap-qcs-pr /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1614905732/rep1-pr1_vs_rep1-pr2.overlap.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1607146373/rep2-pr1_vs_rep2-pr2.overlap.bfilt.frip.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1599387014/rep3-pr1_vs_rep3-pr2.overlap.bfilt.frip.qc \
    --frip-overlap-qc-ppr /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-358299114/pooled-pr1_vs_pooled-pr2.overlap.bfilt.frip.qc \
    --idr-reproducibility-qc /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/738010581/idr.reproducibility.qc \
    --overlap-reproducibility-qc /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1096971035/overlap.reproducibility.qc \
    --gc-plots /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-776188248/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.gc_plot.png_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-783947607/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.gc_plot.png_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-791706966/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.gc_plot.png \
    --peak-region-size-qcs /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/827434091/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.peak_region_size.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/819674732/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.peak_region_size.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/811915373/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.peak_region_size.qc \
    --peak-region-size-plots /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-2037951758/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.peak_region_size.png_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-2045711117/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.peak_region_size.png_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-2053470476/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.peak_region_size.png \
    --num-peak-qcs /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1903046667/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.num_peak.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1895287308/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.num_peak.qc_:_/cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1887527949/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.pval0.01.500K.bfilt.num_peak.qc \
    --idr-opt-peak-region-size-qc /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/75186155/idr.optimal_peak.peak_region_size.qc \
    --idr-opt-peak-region-size-plot /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-330214014/overlap.optimal_peak.peak_region_size.png \
    --idr-opt-num-peak-qc /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/1150798731/idr.optimal_peak.num_peak.qc \
    --overlap-opt-peak-region-size-qc /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-1759795461/overlap.optimal_peak.peak_region_size.qc \
    --overlap-opt-peak-region-size-plot /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-330214014/overlap.optimal_peak.peak_region_size.png \
    --overlap-opt-num-peak-qc /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-qc_report/inputs/-684182885/overlap.optimal_peak.num_peak.qc \
    --out-qc-html qc.html \
    --out-qc-json qc.json \
)

# --------------
# signal track
# --------------

python3 $(which encode_task_macs2_signal_track_chip.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-macs2_signal_track/shard-2/inputs/43783909/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.tagAlign.gz \
    --gensz hs \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-macs2_signal_track/shard-2/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --fraglen 130 \
    --pval-thresh 0.01 \
    --mem-gb 5.93325087428093
)
python3 $(which encode_task_macs2_signal_track_chip.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-macs2_signal_track/shard-0/inputs/59302627/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.tagAlign.gz \
    --gensz hs \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-macs2_signal_track/shard-0/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --fraglen 65 \
    --pval-thresh 0.01 \
    --mem-gb 5.772495415061712
)
python3 $(which encode_task_macs2_signal_track_chip.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-macs2_signal_track/shard-1/inputs/51543268/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.tagAlign.gz \
    --gensz hs \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-macs2_signal_track/shard-1/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --fraglen 140 \
    --pval-thresh 0.01 \
    --mem-gb 6.155977007001638
)
python3 $(which encode_task_macs2_signal_track_chip.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-macs2_signal_track_pooled/inputs/-999592172/rep.pooled.tagAlign.gz \
    --gensz hs \
    --chrsz /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-macs2_signal_track_pooled/inputs/-215527706/GRCh38_EBV.chrom.sizes.tsv \
    --fraglen 112 \
    --pval-thresh 0.01 \
    --mem-gb 9.861713975667953
)


# --------------
# xcorr
# --------------

python3 $(which encode_task_xcor.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-xcor/shard-2/inputs/2064017028/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.trim_50bp.srt.filt.tagAlign.gz \
     \
    --mito-chr-name chrM \
    --subsample 15000000 \
    --chip-seq-type tf \
    --exclusion-range-min -500 \
     \
    --subsample 15000000 \
    --nth 2
)
python3 $(which encode_task_xcor.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-xcor/shard-0/inputs/2079535746/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.trim_50bp.srt.filt.tagAlign.gz \
     \
    --mito-chr-name chrM \
    --subsample 15000000 \
    --chip-seq-type tf \
    --exclusion-range-min -500 \
     \
    --subsample 15000000 \
    --nth 2
)
python3 $(which encode_task_xcor.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-xcor/shard-1/inputs/2071776387/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.trim_50bp.srt.filt.tagAlign.gz \
     \
    --mito-chr-name chrM \
    --subsample 15000000 \
    --chip-seq-type tf \
    --exclusion-range-min -500 \
     \
    --subsample 15000000 \
    --nth 2
)

# --------------
# jsd
# --------------

python3 $(which encode_task_jsd.py) \
    /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-jsd/inputs/-149828919/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepA_None_E006910_S67_L008_R1_001.srt.nodup.bam /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-jsd/inputs/-157588278/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepB_None_E006911_S78_L008_R1_001.srt.nodup.bam /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-jsd/inputs/-165347637/ChIP-seq_TEAD1_UM-SCC-6_CVCL7773-RepC_None_E006912_S84_L008_R1_001.srt.nodup.bam \
     \
    --mapq-thresh 30 \
    --blacklist /cromwell-executions/chip/bd4a164b-91df-4cf4-a744-1e947e3559d1/call-jsd/inputs/-215527706/ENCFF356LFX.bed.gz \
    --nth 4



