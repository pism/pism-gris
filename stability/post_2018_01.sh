#!/bin/bash
#SBATCH --partition=analysis
#SBATCH --ntasks=7
#SBATCH --tasks-per-node=7
#SBATCH --time=48:00:00
#SBATCH --output=pism.%j
#SBATCH --mem=214G

cd $SLURM_SUBMIT_DIR

# odir=2018_01_les
# grid=1800
# mkdir -p $odir/scalar_pruned
# mkdir -p $odir/scalar_clean
# mkdir -p $odir/scalar_ensstat
# rsync -rvu --progress --min-size=470KB $odir/scalar/* $odir/scalar_pruned/
# cd $odir/scalar_pruned/
# for file in ts_*.nc; do
#     cdo selvar,tendency*,surface*,li*,ice_*,dt,basal* $file ../scalar_clean/$file
# done
# cd ../../
# for rcp in 26 45 85; do
#     for pctl in 16 50 84; do
#         cdo -O -P 7 enspctl,$pctl $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}*0_1000.nc  $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
#     done
# done


odir=2018_01_les
grid=1800
mkdir -p $odir/sftgif
mkdir -p $odir/sftgif_pctl
cd $odir/state
for file in gris_g${grid}m*id_*0_1000.nc; do
    if [ ! -f "../sftgif/$file" ]; then
    cdo selvar,sftgif $file ../sftgif/$file
    fi
done
cd ../../

rcp=26
cdo -O  enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
cdo divc,4.84 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc 
gdal_translate $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
gdal_contour -a pctl -fl 16 50 84  $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.shp
rcp=45
cdo -O  enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
cdo divc,4.88 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc 
gdal_translate $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
gdal_contour -a pctl -fl 16 50 84  $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.shp
rcp=85
cdo -O  enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
cdo divc,4.70 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc 
gdal_translate $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
gdal_contour -a pctl -fl 16 50 84  $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.shp
