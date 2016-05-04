#!/bin/bash

# GRID=450

# buffer_x=148650
# buffer_y=130000
# xmin=$((-638000 - $buffer_x - 468000))
# ymin=$((-3349600 - $buffer_y))
# xmax=$((864700 + $buffer_x))
# ymax=$((-657600 + $buffer_y))

for radius in 150; do
    gdal_grid -zfield A_BED -l jib_cresis_flightlines_clipped -txe -188750.0 -141950.0 -tye -2266200.0 -2287200.0 -a average:radius1=${radius}.0:radius2=${radius}.0:angle=0.0:min_points=0:nodata=0.0 -outsize 312 140 -of GTiff /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/shape_files/jib_cresis_flightlines_clipped.shp /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_${radius}m.tif
    gdal_translate -of netCDF jib_cresis_clipped_ma_${radius}m.tif jib_cresis_clipped_ma_${radius}m.nc
    mpiexec -np 4  fill_missing_petsc.py -v Band1 -f jib_cresis_clipped_ma_${radius}m.nc -o jib_cresis_clipped_ma_${radius}m_filled.nc
    gdalwarp -overwrite -cutline /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/shape_files/jib_cresis_channel_area.shp -tr 150.0 150.0 -of GTiff /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_${radius}m_filled.nc /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_${radius}m_filled_clipped.tif
    gdalwarp -overwrite -cutline /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/shape_files/jib_cresis_channel_area_cutline.shp -tr ${GRID} ${GRID} -of GTiff /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_${radius}m_filled.nc /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/gris_cresis_clipped_ma_${radius}m_filled_clipped.tif
    gdalwarp -overwrite  -r average -s_srs EPSG:3413 -t_srs EPSG:3413 -te $xmin $ymin $xmax $ymax -tr $GRID $GRID -of GTiff gris_cresis_clipped_ma_${radius}m_filled_clipped.tif g${GRID}m_cresis.tif
    gdal_translate -co "FORMAT=NC2" -of netCDF g${GRID}m_cresis.tif g${GRID}m_cresis.nc
    ncrename -O -v Band1,cresis_bed g${GRID}m_cresis.nc g${GRID}m_cresis.nc
done

