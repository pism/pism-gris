#!/bin/bash
#PBS -q analysis
#PBS -l walltime=36:00:00
#PBS -l nodes=1:ppn=1
#PBS -j oe
#SBATCH --mem=214GB

source ~/.bash_profile

cd $SLURM_SUBMIT_DIR


mkdir -p ../basins
~/base/gris-analysis/basins/extract_basins.py --basins $2 --o_dir basins  $1