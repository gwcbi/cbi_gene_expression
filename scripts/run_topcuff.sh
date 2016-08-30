#!/bin/bash
#SBATCH -p short,defq
#SBATCH -N 1
#SBATCH -t 12:00:00

umask 0002
module load tophat/2.0.12
module load cufflinks/2.2.1
module swap samtools/1.2 samtools/0.1.19

### Variables ############################################################################
# File of file names
[[ -z "$fofn" ]] && echo "Fastq fofn not provided" && exit 1
# Tophat transcriptome index
[[ -z "$tindex" ]] && echo "Path to tophat index not provided" && exit 1
# Bowtie2 index
[[ -z "$bindex" ]] && echo "Path to bowtie2 index not provided" && exit 1
# Output directory
[[ -z "$outdir" ]] && outdir=$(pwd)

# Get fastq using SLURM array ID 
fastq1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" < $fofn)
# Check whether fastq exists
[[ ! -e "$fastq1" ]] && echo "Fastq file $fastq1 does not exist" && exit 1

# Get file name prefix
samp=$(basename ${fastq1%%.*})

# Create output directory if necessary
mkdir -p ${outdir}/${samp}

### Report settings ######################################################################
echo "Sample name:   $samp"
echo "Fastq fofn:    $fofn"
echo "Fastq file:    $fastq1"
echo "Tophat index:  $tindex"
echo "Bowtie2 index: $bindex"
echo "Output dir:    ${outdir}/${samp}"

### Run tophat ###########################################################################
cmd1="tophat -p $(nproc) -o ${outdir}/${samp} --transcriptome-index ${tindex} ${bindex} ${fastq1}"
echo $cmd1
time $cmd1

### Run cufflinks ########################################################################
cmd2="cufflinks -p $(nproc) -o ${outdir}/${samp} ${outdir}/${samp}/accepted_hits.bam"
echo $cmd2
time $cmd2

echo "complete" && exit 0
