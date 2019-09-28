cat * | grep "\S" >rDNA_ref.fastq
bowtie2-build rDNA_ref.fastq rDNA_ref
