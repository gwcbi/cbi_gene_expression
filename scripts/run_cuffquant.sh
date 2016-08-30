#!/bin/bash
#SBATCH -p short,defq
#SBATCH -N 1
#SBATCH -t 6:00:00

umask 0002
module load tophat/2.0.12
module load cufflinks/2.2.1
module swap samtools/1.2 samtools/0.1.19

### Variables ############################################################################
# File of file names
[[ -z "$fofn" ]] && echo "Fastq fofn not provided" && exit 1
# Merged annotation GTF
[[ -z "$gtffile" ]] && gtffile=${outdir}/merged_asm/merged.gtf
# Genomic DNA reference sequence
[[ -n "$refseq" ]] && refarg="--frag-bias-correct ${refseq}" || refarg=" "
# Output directory
[[ -z "$outdir" ]] && outdir=$(pwd)

# Get fastq using SLURM array ID 
fastq1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" < $fofn)
# Get file name prefix
samp=$(basename ${fastq1%%.*})
# Get path to BAM file
bamfile="${outdir}/${samp}/accepted_hits.bam"

# Check whether BAM exists
[ ! -e "$bamfile" ] && echo "$bamfile not found" && exit 1
# Check whether GTF exists
[ ! -e "$gtffile" ] && echo "$gtffile not found" && exit 1

### Report settings ######################################################################
echo "Fastq fofn:    $fofn"
echo "Sample name:   $samp"
echo "Accepted BAM:  $bamfile"
echo "Reference seq: $refseq"
echo "GTF file:      $gtffile"
echo "Output dir:    ${outdir}/${samp}"

### Run cuffquant ########################################################################
cmd="cuffquant -p $(nproc) -v -o ${outdir}/${samp} ${refarg} --multi-read-correct $gtffile $bamfile"
echo $cmd
time $cmd

echo "complete" && exit 0
