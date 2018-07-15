#!/bin/bash
#PBS -q analysis
#PBS -l walltime=36:00:00
#PBS -l nodes=1:ppn=1
#PBS -j oe
#SBATCH --mem=214G
source ~/.bash_profile

cd $SLURM_SUBMIT_DIR

cdo -f nc4 -z zip_5 mergetime 2018_05_ctrl_tmp/ex_gris_g900m_v3a_rcp_$1_id_$2_0_500.nc 2018_05_ctrl_tmp/ex_gris_g900m_v3a_rcp_$1_id_$2_500_1000.nc 2018_05_ctrl/spatial/ex_gris_g900m_v3a_rcp_$1_id_$2_0_1000.nc
adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 2018_05_ctrl/spatial/ex_gris_g900m_v3a_rcp_$1_id_$2_0_1000.nc
~/base/gris-analysis/scripts/nc_add_hillshade.py 2018_05_ctrl/spatial/ex_gris_g900m_v3a_rcp_$1_id_$2_0_1000.nc

