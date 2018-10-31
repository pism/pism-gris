#!/bin/bash

options="-O -f nc4 -z zip_3"
start_year=1992
end_year=2015
for year in {1992..2015}; do 
    echo "set grid to regular lat lon grid, fix time and vertical axis"
    ifile=THETA.${year}.nc
    ofile=THETA.${year}.cf.nc
    tmpfile=tmp_$ifile
    cdo $options -r setgrid,r720x360 -setzaxis,zaxis.txt -settaxis,${year}-1-1,0:00:00,1mon $ifile $ofile
done
cdo $options mergetime THETA.*.cf.nc THETA.${start_year}-${end_year}.nc


cdo -O selyear,1995/2015 -sellevel,5,15,25,35,45,55,65,75.004997253418,85.0250015258789,95.0950012207031,105.309997558594,115.870002746582,127.150001525879,139.740005493164,154.470001220703,172.399993896484,194.735000610352,222.710006713867,257.470001220703,299.929992675781,350.679992675781,409.929992675781,477.470001220703 THETA.${start_year}-${end_year}.nc THETA.1995-2015.nc
cdo -O vertmean -selyear,2000/2015 -sellevel,5,15,25,35,45,55,65,75.004997253418,85.0250015258789,95.0950012207031,105.309997558594,115.870002746582,127.150001525879,139.740005493164,154.470001220703,172.399993896484,194.735000610352,222.710006713867,257.470001220703,299.929992675781 THETA.${start_year}-${end_year}.nc THETA.1995-2015.vmean.nc


