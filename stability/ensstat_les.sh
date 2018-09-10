#!/bin/bash
#PBS -q analysis
#PBS -l walltime=36:00:00
#PBS -l nodes=1:ppn=7
#PBS -j oe
#SBATCH --mem=214GB

source ~/.bash_profile

cd $SLURM_SUBMIT_DIR

odir=2018_08_les
grid=1800
mkdir -p $odir/scalar_ensstat
cdo -O -P 7 --sortname enspctl,$2 $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_$1_*0_1000.nc  $odir/scalar_ensstat/enspctl$2_gris_g${grid}m_v3a_rcp_$1_0_1000.nc
