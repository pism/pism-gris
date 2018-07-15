#!/bin/bash
#PBS -q analysis
#PBS -l walltime=36:00:00
#PBS -l nodes=1:ppn=1
#PBS -j oe
#SBATCH --mem=214G
source ~/.bash_profile

cd $SLURM_SUBMIT_DIR

cdo -f nc4 -z zip_3 -O --sortname mergetime 2018_05_ctrl_tmp/ex_gris_g600m_v3a_rcp_$1_id_$2_0_100.nc 2018_05_ctrl_tmp/ex_gris_g600m_v3a_rcp_$1_id_$2_100_200.nc  2018_05_ctrl_tmp/ex_gris_g600m_v3a_rcp_$1_id_$2_200_300.nc  2018_05_ctrl_tmp/ex_gris_g600m_v3a_rcp_$1_id_$2_300_400.nc  2018_05_ctrl_tmp/ex_gris_g600m_v3a_rcp_$1_id_$2_400_500.nc  2018_05_ctrl_tmp/ex_gris_g600m_v3a_rcp_$1_id_$2_500_600.nc  2018_05_ctrl_tmp/ex_gris_g600m_v3a_rcp_$1_id_$2_600_700.nc  2018_05_ctrl_tmp/ex_gris_g600m_v3a_rcp_$1_id_$2_700_800.nc  2018_05_ctrl_tmp/ex_gris_g600m_v3a_rcp_$1_id_$2_800_900.nc  2018_05_ctrl_tmp/ex_gris_g600m_v3a_rcp_$1_id_$2_900_1000.nc 2018_05_ctrl/spatial/ex_gris_g600m_v3a_rcp_$1_id_$2_0_1000.nc
adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 2018_05_ctrl/spatial/ex_gris_g600m_v3a_rcp_$1_id_$2_0_1000.nc
~/base/gris-analysis/scripts/nc_add_hillshade.py 2018_05_ctrl/spatial/ex_gris_g600m_v3a_rcp_$1_id_$2_0_1000.nc

