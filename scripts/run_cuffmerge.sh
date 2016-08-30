#!/bin/bash
#SBATCH -p short,defq
#SBATCH -N 1
#SBATCH -t 2:00:00

umask 0002
module load tophat/2.0.12
module load cufflinks/2.2.1
module swap samtools/1.2 samtools/0.1.19

### Variables ############################################################################
# File of file names
[[ -z "$fofn" ]] && echo "Fastq fofn not provided" && exit 1
# Genomic DNA reference sequence
[[ -z "$refseq" ]] && echo "Reference sequence not provided" && exit 1
# Reference annotation GTF (optional)
[[ -n "$refgtf" ]] && gtfarg="-g $refgtf" || gtfarg=" "
# Output directory
[[ -z "$outdir" ]] && outdir=$(pwd)

# Create file with list of assembly files
cat $fofn | while read f; do
  samp=$(basename ${f%%.*})
  [[ -e ${outdir}/${samp}/transcripts.gtf ]] && echo ${outdir}/${samp}/transcripts.gtf || exit 1
done > ${outdir}/assemblies.txt

### Report settings ######################################################################
echo "Fastq fofn:    $fofn"
echo "Reference seq: $refseq"
echo "Reference gtf: $refgtf"
echo "Output dir:    ${outdir}/merged_asm"

### Run cuffmerge ########################################################################
cmd="cuffmerge ${gtfarg} -s ${refseq} -p $(nproc) -o ${outdir}/merged_asm ${outdir}/assemblies.txt"
echo $cmd
time $cmd

echo "complete" && exit 0
