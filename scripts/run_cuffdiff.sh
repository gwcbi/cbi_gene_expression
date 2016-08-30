#!/bin/bash
#SBATCH -p short,defq
#SBATCH -N 1
#SBATCH -t 12:00:00

umask 0002
module load tophat/2.0.12
module load cufflinks/2.2.1
module swap samtools/1.2 samtools/0.1.19

### Variables ############################################################################
# Sample sheet file
[[ -z "$samplesheet" ]] && echo "samplesheet not provided" && exit 1
# Output directory
[[ -z "$outdir" ]] && outdir=$(pwd)
# Output directory name
[[ -z "$diffout" ]] && diffout="cuffdiff"
# Merged annotation GTF
[[ -z "$gtffile" ]] && gtffile=${outdir}/merged_asm/merged.gtf

# Check whether GTF exists
[ ! -e "$gtffile" ] && echo "gtf file ${gtffile} not found" && exit 1

### Report settings ######################################################################
echo "Sample sheet:  $samplesheet"
echo "GTF file:      $gtffile"
echo "Output dir:    ${outdir}/${diffout}"

### Run cuffdiff #########################################################################
mkdir -p ${outdir}/${diffout}
cmd="cuffdiff --use-sample-sheet -p $(nproc) -q -o ${outdir}/${diffout} $gtffile $samplesheet"
echo $cmd
time $cmd

echo "complete" && exit 0
