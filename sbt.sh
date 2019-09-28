#!/bin/bash

source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument('bam')
parser.add_argument('out_dir')
EOF


DIRECTORY=/u/home/s/serghei/code/sbt_tool/

rm -fr $OUT_DIR
mkdir $OUT_DIR

cd $OUT_DIR

PREFIX=$(basename "$BAM" .bam)

FASTQ_UNM=${OUT_DIR}/${PREFIX}_extended_unmapped.fastq
FASTQ_candidate_rDNA=${OUT_DIR}/${PREFIX}_candidate_rDNA.fastq
FASTQ_MT=${OUT_DIR}/${PREFIX}_MT.fastq


rm -fr $FASTQ_UNM

echo ". /u/local/Modules/default/init/modules.sh" >master_${PREFIX}.sh
echo "module load samtools">>master_${PREFIX}.sh

samtools view -H $BAM  | grep SN | awk '{print $2}' | awk -F ":" '{if ($1=="SN") print $2}' | sort | uniq | grep -v chr  | grep -v "^[1-9]$" | grep -v "^[1-9][0-9]$" | grep -v "^MT$" | grep -v "^X$" | grep -v "^Y$" | grep -v "GL000">non.human.references.txt



echo "Number of non human references"
wc -l non.human.references.txt

rm -fr master_${PREFIX}.sh

while read line
do
echo $line
echo "samtools view -bh $BAM $line | samtools fastq - > $FASTQ_UNM">>master_${PREFIX}.sh
done<non.human.references.txt

samtools view -bh $BAM MT | samtools fastq - >$FASTQ_MT


rm -fr $FASTQ_candidate_rDNA
while read line
do 
chr=$(echo $line | awk -F "," '{print $1}')
x=$(echo $line | awk -F "," '{print $2}')
y=$(echo $line | awk -F "," '{print $3}')
echo "samtools view -bh $BAM $chr:$x-$y | samtools fastq - >>$FASTQ_candidate_rDNA">>master_${PREFIX}.sh
done<${DIRECTORY}/db/rDNA/rDNA.kmers.75.clean.filtered.bed



echo "samtools view -f4 -bh $BAM | samtools fastq - >>$FASTQ_UNM">>master_${PREFIX}.sh



echo "${DIRECTORY}/sbt_rDNA.sh $FASTQ_UNM $FASTQ_candidate_rDNA ${OUT_DIR}/${PREFIX}_rDNA/">>master_${PREFIX}.sh



echo "${DIRECTORY}/sbt_mtDNA.sh $FASTQ_MT ${OUT_DIR}/${PREFIX}_mtDNA/">>master_${PREFIX}.sh






echo "${DIRECTORY}/sbt_microbiome.sh ${BAM} ${OUT_DIR}/${PREFIX}_needle/">>master_${PREFIX}.sh
echo "${DIRECTORY}/sbt_offtarget_cov.sh ${BAM} ${OUT_DIR}/${PREFIX}_offcov/">>master_${PREFIX}.sh
#echo "${DIRECTORY}/sbt_imrep.sh ${BAM} ${OUT_DIR}/${PREFIX}_imrep/">>master_${PREFIX}.sh

mkdir ${OUT_DIR}/${PREFIX}_imrep/

echo "/u/home/s/serghei/project/anaconda2/bin/python /u/home/s/serghei/project/code/seeing.beyond.target/tools/imrep/imrep.py --bam  --noOverlapStep --noCast ${BAM} ${OUT_DIR}/${PREFIX}_imrep/${PREFIX}.cdr3">>master_${PREFIX}.sh

chmod 755 master_${PREFIX}.sh 
#./master_${PREFIX}.sh 



