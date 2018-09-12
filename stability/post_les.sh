#!/bin/bash
#SBATCH --partition=analysis
#SBATCH --ntasks=7
#SBATCH --tasks-per-node=7
#SBATCH --time=48:00:00
#SBATCH --output=pism.%j
#SBATCH --mem=214G

cd $SLURM_SUBMIT_DIR

## PLEIADES
odir=2018_08_les
grid=1800
MAXSIZE=2500000000
for dir in bro sky san; do
    for file in ${odir}_${dir}/state/*_0_1000.nc; do
        FILESIZE=$(stat -c%s "$file")
        if (( $FILESIZE > $MAXSIZE)); then
            echo "compressing $file"
            ncks -O -4 -L 3 $file $file
        fi
        ofile=${odir}/state/${file##*/}
        if [ ! -f "$ofile" ]; then
            echo "copying ${file} to ${ofile}"
            nccopy $file $ofile
        fi
    done
done
prefix=ts_
mkdir -p $odir/scalar_pruned
mkdir -p $odir/scalar_clean
for dir in bro sky san; do
    for file in ${odir}_${dir}/scalar/ts_*.nc; do
        nfile=${file##*/}
        sfile=${nfile#"$prefix"}
        ofile=${odir}/scalar_pruned/${nfile}
        if [ -f "${odir}/state/$sfile" ] && [ ! -f "$ofile" ]; then
            echo "copying ${file} to ${ofile}"
            nccopy $file ${ofile}
        fi
    done
done

## CHINOOK
odir=2018_08_les
grid=1800
MAXSIZE=2500000000
for dir in chi; do
    for file in ${odir}_${dir}/state/*_0_1000.nc; do
        FILESIZE=$(stat -c%s "$file")
        if (( $FILESIZE > $MAXSIZE)); then
            echo "compressing $file"
            ncks -O -4 -L 3 $file $file
        fi
        ofile=${odir}/state/${file##*/}
        if [ ! -f "$ofile" ]; then
            echo "copying ${file} to ${ofile}"
            nccopy $file $ofile
        fi
    done
done
prefix=ts_
mkdir -p $odir/scalar_pruned
mkdir -p $odir/scalar_clean
for dir in dir; do
    for file in ${odir}_${dir}/scalar/ts_*.nc; do
        nfile=${file##*/}
        sfile=${nfile#"$prefix"}
        ofile=${odir}/scalar_pruned/${nfile}
        if [ -f "${odir}/state/$sfile" ] && [ ! -f "$ofile" ]; then
            echo "copying ${file} to ${ofile}"
            nccopy $file ${ofile}
        fi
    done
done

odir=2018_08_les
grid=1800
for rcp in 26 45 85; do
    for id in {000..499}; do
        file=$odir/state/gris_g${grid}m_v3a_rcp_${rcp}_id_${id}_0_1000.nc
        if [ ! -f "$file" ]; then
            echo "$rcp, $id"
        fi
    done
done

odir=2018_08_les
grid=1800
for rcp in 26 45 85; do
    for id in {000..499}; do
        for dir in bro san sky; do
            file=${odir}_${dir}/state/gris_g${grid}m_v3a_rcp_${rcp}_id_${id}_0_1000_max_thickness.nc
            if [ -f "$file" ]; then
                echo "$rcp, $id"
            fi
        done
    done
done

## CHINOOK ONLY
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
odir=2018_08_les
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
            cdo -L setattribute,limnsw@units="cm" -setattribute,limnsw@long_mame="contribution to global mean sea level" -divc,365 -divc,-1e13 -selvar,limnsw -sub -selyear,$year $file -selyear,2008 $file $ofile
            fi
        done
    done
done
cd ../../


odir=2018_08_les
grid=1800
mkdir -p $odir/contrib_absolute
mkdir -p $odir/contrib_percent
for pctl in 16 84; do
    for rcp in 26 45 85; do
        # cdo -O -P 8 --sortname enspctl,$pctl $odir/scalar_clean/ts_gris_g${grid}m_v3a_rcp_${rcp}*0_1000.nc  $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
        # cdo mulc,-100 -selvar,limnsw -div -sub -selyear,3000 $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc -selyear,2008 $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc  -selyear,2008 $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/scalar_ensstat/percent_enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
            cdo -L  setattribute,discharge_contrib@units="cm" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_accumulation_rate)*tendency_of_ice_mass" -divc,365 -divc,-1e13 -timcumsum $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/contrib_absolute/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
            cdo -L  setattribute,discharge_contrib@units="" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_accumulation_rate)*100" -divc,365 -divc,-1e13 -timcumsum $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/contrib_percent/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
    #     for year in 2100 2200 2300 3000; do
    #         cdo -L  setattribute,discharge_contrib@units="cm" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_accumulation_rate)*tendency_of_ice_mass" -divc,365 -divc,-1e13 -selyear,${year} -timcumsum $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/contrib/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_${year}.nc
    #         cdo -L  setattribute,discharge_contrib@units="" -setattribute,discharge_contrib@long_mame="ice discharge contribution to global mean sea level" -expr,"discharge_contrib=tendency_of_ice_mass_due_to_discharge/(tendency_of_ice_mass_due_to_discharge-surface_accumulation_rate)*100" -divc,365 -divc,-1e13 -selyear,${year} -timcumsum $odir/scalar_ensstat/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/contrib_percent/enspctl${pctl}_gris_g${grid}m_v3a_rcp_${rcp}_${year}.nc
    #     done
    done
done





odir=2018_08_les
grid=1800
for rcp in 26 45 85; do
    for year in 2100 2200 2300 3000; do
        echo "Processing RCP ${rcp} at year ${year}"
        python ../latin_hypercube/dgmsl2csv.py ../latin_hypercube/les18_gcm_rcp${rcp}_${year}.csv $odir/dgmsl/dgmsl_gris_g1800m_v3a_rcp_${rcp}_id_*_${year}.nc
    done
done

#PBS -l select=1:mem=250GB
#PBS -l walltime=24:00:00
#PBS -q ldan

cd $PBS_O_WORKDIR

odir=2018_08_les
grid=1800

for file in ${odir}_*/state/*_0_1000.nc; do
    echo $file
    ofile=${odir}/state/${file##*/}
    if [ ! -f "$ofile" ]; then
        ncks -O -4 -L 3 $file $ofile
    fi
done

odir=2018_08_les
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

odir=2018_08_les
grid=1800

rcp=26
cdo -O  enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
cdo divc,5.88 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc 
gdal_translate $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
gdal_contour -a pctl -fl 16 50 84  $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.shp
rcp=45
cdo -O enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
cdo divc,5.72 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc 
gdal_translate $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
gdal_contour -a pctl -fl 16 50 84  $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.shp
rcp=85
cdo -O enssum $odir/sftgif/gris_g${grid}m_v3a_rcp_${rcp}_id_*_0_1000.nc $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc
cdo divc,5.76 $odir/sftgif_pctl/sum_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc 
gdal_translate $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.nc $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif
gdal_contour -a pctl -fl 16 50 84  $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.tif $odir/sftgif_pctl/percent_gris_g${grid}m_v3a_rcp_${rcp}_0_1000.shp

