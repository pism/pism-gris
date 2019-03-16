#!/bin/bash
#SBATCH --partition=analysis
#SBATCH --ntasks=7
#SBATCH --tasks-per-node=7
#SBATCH --time=48:00:00
#SBATCH --output=pism.%j
#SBATCH --mem=214G

cd $SLURM_SUBMIT_DIR

## PLEIADES
odir=2018_09_les
grid=1800
MAXSIZE=2500000000
for file in ${odir}/state/*_0_1000.nc  ${odir}/state/*_0_1000_max*.nc; do
    FILESIZE=$(stat -c%s "$file")
    if (( $FILESIZE > $MAXSIZE)); then
        echo "compressing $file"
        ncks -O -4 -L 3 $file $file
    fi
done
prefix=ts_
mkdir -p $odir/scalar_pruned
for file in ${odir}/scalar/ts_*.nc; do
    nfile=${file##*/}
    sfile=${nfile#"$prefix"}
    ofile=${odir}/scalar_pruned/${nfile}
    if [ -f "${odir}/state/$sfile" ] && [ ! -f "$ofile" ]; then
        echo "copying ${file} to ${ofile}"
        nccopy $file ${ofile}
    fi
done


## CHINOOK
odir=2018_09_les
grid=1800
MAXSIZE=2500000000
for file in ${odir}_chi/state/*_0_1000.nc  ${odir}_chi/state/*_0_1000_max*.nc; do
    FILESIZE=$(stat -c%s "$file")
    if (( $FILESIZE > $MAXSIZE)); then
        echo "compressing $file"
        ncks -O -4 -L 3 $file $file
    fi
    nfile=${file##*/}
    ofile=${odir}/state/${nfile}
    if [ ! -f "$ofile" ]; then
        echo "copying ${file} to ${ofile}"
        nccopy $file ${ofile}
    fi
done
prefix=ts_
mkdir -p $odir/scalar_pruned
for file in ${odir}_chi/scalar/ts_*.nc; do
    nfile=${file##*/}
    sfile=${nfile#"$prefix"}
    ofile=${odir}/scalar_pruned/${nfile}
    if [ -f "${odir}/state/$sfile" ] && [ ! -f "$ofile" ]; then
        echo "copying ${file} to ${ofile}"
        nccopy $file ${ofile}
    fi
done


## CHINOOK ONLY
odir=2018_09_les
grid=1800
mkdir -p $odir/scalar_clean
for file in $odir/scalar_pruned/ts_*.nc; do
    nfile=${file##*/}
    ofile=${odir}/scalar_clean/$nfile
    if [ ! -f "$ofile" ]; then
        echo "copying ${file} to ${ofile}"
        cdo -O seltimestep,1/1000 -selvar,tendency*,surface*,li*,ice_*,dt,basal* $file $ofile
        adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 $ofile
     fi
    # echo "copying ${file} to ${ofile}"
    # cdo -O seltimestep,1/1000 -selvar,tendency*,surface*,li*,ice_*,dt,basal* $file $ofile
    #adjust_timeline.py -i start -p yearly -a 2008-1-1 -u seconds -d 2008-1-1 $ofile
done


# Extract DGMSL
odir=2018_09_les
grid=1800
mkdir -p $odir/dgmsl
rprefix=ts_
postfix=_0_1000.nc
cd $odir/scalar_clean
for rcp in 26 45 85; do
    for year in 2100 2200 2300 3000; do
        for file in ts_gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc; do
            nfile=${file##*/}
            sfile=${nfile#"$prefix"}
            pfile=${sfile%"$postfix"}
            ofile=../dgmsl/dgmsl_${pfile}_${year}.nc
            if [ ! -f "$ofile" ]; then
            echo "Extracting DGMSL at year $year from $file and saving it to $ofile"
            cdo -L setattribute,limnsw@units="cm" -setattribute,limnsw@long_mame="contribution to global mean sea level" -divc,365 -divc,-1e13 -selvar,limnsw -sub -selyear,$year $file -seltimestep,1 $file $ofile
            fi
        done
    done
done
cd ../../

odir=2018_09_les
grid=1800
mkdir -p $odir/dgmsl
rprefix=ts_
postfix=_0_1000.nc
cd $odir/scalar_clean
for rcp in 26 45 85; do
    for file in ts_gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc; do
        nfile=${file##*/}
        sfile=${nfile#"$prefix"}
        pfile=${sfile%"$postfix"}
        ofile=../dgmsl/dgmsl_${pfile}_0_1000.nc
        if [ ! -f "$ofile" ]; then
            echo "Extracting DGMSL from $file and saving it to $ofile"
            cdo -O -L setattribute,limnsw@units="cm" -setattribute,limnsw@long_mame="contribution to global mean sea level" -divc,365 -divc,-1e13 -selvar,limnsw -sub $file -seltimestep,1 $file $ofile
        fi
    done
done
cd ../../


odir=2018_09_les
grid=1800
mkdir -p $odir/contrib_absolute
mkdir -p $odir/contrib_percent
mkdir -p $odir/contrib_flux_absolute
mkdir -p $odir/contrib_flux_percent
mkdir -p $odir/scalar_ensstat

for pctl in 5 16 50 84 95; do
    for rcp in 26 45 85; do
        cdo -O -P 16 --sortname enspctl,$pctl $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}*0_1000.nc  $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
        cdo mulc,-100 -selvar,limnsw -div -sub -selyear,3000 $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc -selyear,2008 $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc  -selyear,2008 $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/scalar_ensstat/percent_enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
            cdo -L  setattribute,discharge_contrib@units="cm" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_runoff_rate)*tendency_of_ice_mass" -divc,365 -divc,-1e13 -timcumsum $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/contrib_absolute/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
            cdo -L  setattribute,discharge_contrib@units="" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_runoff_rate)*100" -divc,365 -divc,-1e13 -timcumsum $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/contrib_percent/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
            cdo -L  setattribute,discharge_contrib@units="kg year-1" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_runoff_rate)*tendency_of_ice_mass"  $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/contrib_flux_absolute/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
            cdo -L  setattribute,discharge_contrib@units="" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_runoff_rate)*100"  $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/contrib_flux_percent/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
            for year in 2100 2200 2300 3000; do
                cdo selyear,${year} $odir/contrib_absolute/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/contrib_absolute/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_${year}.nc
                cdo selyear,${year}  $odir/contrib_percent/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc  $odir/contrib_percent/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_${year}.nc
                cdo selyear,${year} $odir/contrib_flux_absolute/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/contrib_flux_absolute/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_${year}.nc
                cdo selyear,${year} $odir/contrib_flux_percent/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/contrib_flux_percent/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_${year}.nc
            done
    done
done






odir=2018_09_les
grid=1800
for rcp in 26 45 85; do
    for year in {2015..3000}; do
        echo "Processing RCP ${rcp} at year ${year}"
        python ../latin_hypercube/dgmsl2csv.py -y ${year} ${odir}/les/les_gcm_rcp${rcp}_${year}.csv $odir/dgmsl/dgmsl_ts_gris_g1800m_v3a_rcp_${rcp}_id_*_0_1000.nc
    done
done

#PBS -l select=1:mem=250GB
#PBS -l walltime=24:00:00
#PBS -q ldan

cd $PBS_O_WORKDIR

odir=2018_09_les
grid=1800

for file in ${odir}_*/state/*_0_1000.nc; do
    echo $file
    ofile=${odir}/state/${file##*/}
    if [ ! -f "$ofile" ]; then
        ncks -O -4 -L 3 $file $ofile
    fi
done

odir=2018_09_les
grid=1800
mkdir -p $odir/sftgif
mkdir -p $odir/sftgif_pctl
cd $odir/state
for file in gris_g${grid}m*id_*0_1000.nc; do
    if [ ! -f "../sftgif/$file" ]; then
        echo "Processing $file"
        cdo selvar,sftgif $file ../sftgif/$file
    fi
done
cd ../../

odir=2018_09_les
grid=1800

rcp=26
cdo -O  enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
cdo divc,4.89 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc 
gdal_translate $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
gdal_contour -a pctl -fl 16 50 84  $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.shp
rcp=45
cdo -O enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
cdo divc,4.91 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc 
gdal_translate $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
gdal_contour -a pctl -fl 16 50 84  $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.shp
rcp=85
cdo -O enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
cdo divc,4.77 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc 
gdal_translate $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
gdal_contour -a pctl -fl 16 50 84  $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.shp

