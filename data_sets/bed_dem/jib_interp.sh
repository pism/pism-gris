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
    gdalwarp -overwrite -cutline /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/shape_files/jib_cresis_channel_area.shp -tr 150.0 150.0 -of GTiff /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_${radius}m_filled.nc /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_${radius}m_filled_clipped_pre.tif 
    /opt/local/share/doc/py27-gdal/examples/scripts/gdal_polygonize.py  /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_${radius}m_filled_clipped_pre.tif -f "ESRI Shapefile" /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_${radius}m_filled_clipped_pre.shp
    cp /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_${radius}m_filled_clipped_pre.tif /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_${radius}m_filled_clipped_post.tif
    gdal_rasterize -a DN -l jib_cresis_clipped_ma_150m_filled_clipped_pre /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_150m_filled_clipped_pre.shp /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_150m_filled_clipped_post.tif
done

