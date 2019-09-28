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


module load samtools
module load bowtie2
module load bcftools


pwd

DB=/PHShome/sv188/needle/db_human/


echo $sample


module load bwa 

bwa mem -a ${DB}/viral.vipr/NONFLU_All.fastq $UNMAPPED | samtools view -S -b -F 4 - | samtools sort - >${sample}.virus.bam
bwa mem -a ${DB}/fungi/fungi.ncbi.february.3.2018.fasta $UNMAPPED | samtools view -S -b -F 4 - |  samtools sort - >${sample}.fungi.bam
bwa mem -a ${DB}/protozoa/protozoa.ncbi.february.3.2018.fasta $UNMAPPED | samtools view -S -b -F 4 - | samtools sort - >${sample}.protozoa.bam


samtools view ${sample}.virus.bam  | awk '{print $1}' | sort | uniq >temp_viral_reads.txt
samtools view ${sample}.virus.bam  | awk '{print $1}' | sort | uniq >temp_fungi_reads.txt
samtools view ${sample}.virus.bam  | awk '{print $1}' | sort | uniq >temp_protozoa_reads.txt


n_viral=$( cat temp_viral_reads.txt | wc -l)
n_fungi=$( cat temp_fungi_reads.txt | wc -l)
n_protozoa=$( cat temp_protozoa_reads.txt | wc -l)

n_microbiome=$( cat temp_viral_reads.txt temp_fungi_reads.txt  temp_protozoa_reads.txt | wc -l)

echo n_viral,n_fungi,n_protozoa,n_microbiome>>summary_microbiome.csv
echo $n_viral,$n_fungi,$n_protozoa,$n_microbiome>>summary_microbiome.csv








exit 1
/PHShome/sv188/needle/needle.sh -f ${BAM} ${OUT_DIR}_temp
mv ${OUT_DIR}_temp/*contigs.fa ${OUT_DIR}
mv ${OUT_DIR}_temp/*filtered.csv ${OUT_DIR}
mv ${OUT_DIR}_temp/*putative.bacteria.csv ${OUT_DIR}

#rm -fr ${OUT_DIR}_temp


