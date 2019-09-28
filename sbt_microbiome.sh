#!/bin/bash

source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('unmapped')
parser.add_argument('out_dir')
EOF

prefix=$(basename "$UNMAPPED" .fastq)
OUT=$OUT_DIR"/"$prefix

mkdir $OUT_DIR


sample=$OUT_DIR/${prefix}

. /u/local/Modules/default/init/modules.sh
module load samtools
module load bowtie2
module load bcftools


pwd

DB=/u/home/s/serghei/project/code/needle/db_human/


echo $sample


module load bwa 

echo "start"



bwa mem ${DB}/viral.vipr/NONFLU_All.fastq $UNMAPPED | samtools view -S -b -F 4 - | samtools sort -  >${sample}.virus.bam
bwa mem ${DB}/fungi/fungi.ncbi.february.3.2018.fasta $UNMAPPED | samtools view -S -b -F 4 -  | samtools sort -  >${sample}.fungi.bam
bwa mem ${DB}/protozoa/protozoa.ncbi.february.3.2018.fasta $UNMAPPED | samtools view -S -b -F 4 - | samtools sort - >${sample}.protozoa.bam




ls -l ${sample}.protozoa.bam


samtools view ${sample}.virus.bam  | awk '{print $1}' | sort | uniq >${OUT_DIR}/temp_viral_reads.txt
samtools view ${sample}.fungi.bam  | awk '{print $1}' | sort | uniq >${OUT_DIR}/temp_fungi_reads.txt
samtools view ${sample}.protozoa.bam  | awk '{print $1}' | sort | uniq >${OUT_DIR}/temp_protozoa_reads.txt


n_viral=$( cat ${OUT_DIR}/temp_viral_reads.txt | wc -l)
n_fungi=$( cat ${OUT_DIR}/temp_fungi_reads.txt | wc -l)
n_protozoa=$( cat ${OUT_DIR}/temp_protozoa_reads.txt | wc -l)

n_microbiome=$( cat ${OUT_DIR}/temp_viral_reads.txt ${OUT_DIR}/temp_fungi_reads.txt  ${OUT_DIR}/temp_protozoa_reads.txt | wc -l)

echo n_viral,n_fungi,n_protozoa,n_microbiome>${OUT_DIR}/summary_microbiome.csv
echo $n_viral,$n_fungi,$n_protozoa,$n_microbiome>>${OUT_DIR}/summary_microbiome.csv

rm -fr ${OUT_DIR}/temp*







#rm -fr ${OUT_DIR}_temp


