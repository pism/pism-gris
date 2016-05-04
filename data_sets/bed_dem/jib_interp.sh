

for radius in 150 200 250 300; do
gdal_grid -zfield A_BED -l jib_cresis_flightlines_clipped -txe -188750.0 -141950.0 -tye -2266200.0 -2287200.0 -a average:radius1=${radius}.0:radius2=${radius}.0:angle=0.0:min_points=0:nodata=0.0 -outsize 312 140 -of GTiff /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/shape_files/jib_cresis_flightlines_clipped.shp /Volumes/Isunnguata_Sermia/data/pism-gris/data_sets/bed_dem/jib_cresis_clipped_ma_${radius}m.tif
gdal_translate -of netCDF jib_cresis_clipped_ma_${radius}m.tif jib_cresis_clipped_ma_${radius}m.nc
mpiexec -np 4  fill_missing_petsc.py -v Band1 -f jib_cresis_clipped_ma_${radius}m.nc -o jib_cresis_clipped_ma_${radius}m_filled.nc
done
