#!/bin/bash
#PBS -q analysis
#PBS -l walltime=36:00:00
#PBS -l nodes=1:ppn=1
#PBS -j oe
#SBATCH --mem=214G
source ~/.bash_profile

cd $SLURM_SUBMIT_DIR

odir=2018_08_ctrl
ncap2 -O -4 -L 3  -s "limnsw=ice_mass; where(mask!=2) {limnsw=0;};" ${odir}_tmp/ex_gris_g900m_v3a_rcp_$1_id_$2_0_1000.nc ${odir}/spatial/ex_gris_g900m_v3a_rcp_$1_id_$2_0_1000.nc
adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 ${odir}/spatial/ex_gris_g900m_v3a_rcp_$1_id_$2_0_1000.nc
~/base/gris-analysis/scripts/nc_add_hillshade.py ${odir}/spatial/ex_gris_g900m_v3a_rcp_$1_id_$2_0_1000.nc

