#!/bin/bash

options="-O"

for year in {1992..1993}; do 
    echo "set grid to regular lat lon grid, fix time and vertical axis"
    ifile=THETA.${year}.nc
    ofile=THETA.${year}.cf.nc
    tmpfile=tmp_$ifile
    # This is a regular lat/lon grid, so we can use setgrid to ajdust the grid specifications
    # Next we set the z-axis with the information given in the file
    # Finally we adjust the time axis to make it relative and CF-conforming
    cdo $options -r sellonlatbox,-180,180,-90,90 -setgrid,r720x360 -setzaxis,zaxis.txt -settaxis,${year}-1-1,0:00:00,1mon $ifile $ofile
done

exit


start_year=1992
end_year=2015

cdo $options mergetime THETA.*.cf.nc THETA.${start_year}-${end_year}.nc


cdo -L -O selyear,1995/2015 -sellevel,5,15,25,35,45,55,65,75.004997253418,85.0250015258789,95.0950012207031,105.309997558594,115.870002746582,127.150001525879,139.740005493164,154.470001220703,172.399993896484,194.735000610352,222.710006713867,257.470001220703,299.929992675781,350.679992675781,409.929992675781,477.470001220703 THETA.${start_year}-${end_year}.nc THETA.1995-2015.nc
cdo -L -O vertmean -selyear,2000/2015 -sellevel,5,15,25,35,45,55,65,75.004997253418,85.0250015258789,95.0950012207031,105.309997558594,115.870002746582,127.150001525879,139.740005493164,154.470001220703,172.399993896484,194.735000610352,222.710006713867,257.470001220703,299.929992675781 THETA.${start_year}-${end_year}.nc THETA.2000-2015.vmean.nc

cdo sellonlatbox,-180,180,-90,90 THETA.2000-2015.vmean.nc LL.THETA.2000-2015.vmean.nc
box="-74,-11,58,88"
cdo sellonlatbox,$box THETA.1995-2015.vmean.nc GRIS.THETA.1995-2015.vmean.nc


buffer_x=148650
buffer_y=130000
xmin=$((-638000 - $buffer_x - 468000))
ymin=$((-3349600 - $buffer_y))
xmax=$((864700 + $buffer_x))
ymax=$((-657600 + $buffer_y))

xres=450
yres=450

gdal_rasterize -a UGID -tr $xres $yres -te $xmin $ymin $xmax $ymax "~/Google\ Drive\ File\ Stream/My\ Drive/data/gris-basins/GRE_Basins_IMBIE2_epsg3413_v1.3_ext.shp" mask_g450m_GRE_Basins_IMBIE2_epsg3413_v1.3_ext.nc
ncrename -v Band1,mask mask_g450m_GRE_Basins_IMBIE2_epsg3413_v1.3_ext.nc
