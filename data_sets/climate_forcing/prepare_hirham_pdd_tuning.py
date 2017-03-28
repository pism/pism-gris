#!/usr/bin/env python
# Copyright (C) 2016 Andy Aschwanden


from argparse import ArgumentParser
import numpy as np
from pyproj import Proj
import os
try:
    import subprocess32 as sub
except:
    import subprocess as sub
from netCDF4 import Dataset as CDF
from cdo import Cdo
cdo = Cdo()
from netcdftime import utime
from datetime import datetime
from dateutil.parser import parse
from dateutil import rrule
from nco import Nco
from nco import custom as c
nco = Nco()

import logging
import logging.handlers

try:
    import pypismtools.pypismtools as ppt
except:
    import pypismtools as ppt

# create logger
logger = logging.getLogger('prepare HIRHAM5')
logger.setLevel(logging.DEBUG)

# create file handler which logs even debug messages
fh = logging.handlers.RotatingFileHandler('prepare.log')
fh.setLevel(logging.DEBUG)
# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
# create formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(module)s:%(lineno)d - %(message)s')

# add formatter to ch and fh
ch.setFormatter(formatter)
fh.setFormatter(formatter)

# add ch to logger
logger.addHandler(ch)
logger.addHandler(fh)


def create_epsg3413_grid(ofile, grid_spacing):
    
    xdim = 'x'
    ydim = 'y'

    # define output grid, these are the extents of Mathieu's domain (cell
    # corners)
    e0 = -638000
    n0 = -3349600
    e1 = 864700
    n1 = -657600

    # Add a buffer on each side such that we get nice grids up to a grid spacing
    # of 36 km.

    buffer_e = 148650
    buffer_n = 130000
    e0 -= buffer_e + 468000
    n0 -= buffer_n
    e1 += buffer_e
    n1 += buffer_n

    # Shift to cell centers
    e0 += grid_spacing / 2
    n0 += grid_spacing / 2
    e1 -= grid_spacing / 2
    n1 -= grid_spacing / 2

    de = dn = grid_spacing  # m
    M = int((e1 - e0) / de) + 1
    N = int((n1 - n0) / dn) + 1

    easting = np.linspace(e0, e1, M)
    northing = np.linspace(n0, n1, N)
    ee, nn = np.meshgrid(easting, northing)

    # Set up EPSG 3413 (NSIDC north polar stereo) projection
    projection = "+init=epsg:3413"
    proj = Proj(projection)

    lon, lat = proj(ee, nn, inverse=True)

    # number of grid corners
    grid_corners = 4
    # grid corner dimension name
    grid_corner_dim_name = "nv4"

    # array holding x-component of grid corners
    gc_easting = np.zeros((M, grid_corners))
    # array holding y-component of grid corners
    gc_northing = np.zeros((N, grid_corners))
    # array holding the offsets from the cell centers
    # in x-direction (counter-clockwise)
    de_vec = np.array([-de / 2, de / 2, de / 2, -de / 2])
    # array holding the offsets from the cell centers
    # in y-direction (counter-clockwise)
    dn_vec = np.array([-dn / 2, -dn / 2, dn / 2, dn / 2])
    # array holding lat-component of grid corners
    gc_lat = np.zeros((N, M, grid_corners))
    # array holding lon-component of grid corners
    gc_lon = np.zeros((N, M, grid_corners))
    
    for corner in range(0, grid_corners):
        ## grid_corners in x-direction
        gc_easting[:, corner] = easting + de_vec[corner]
        # grid corners in y-direction
        gc_northing[:, corner] = northing + dn_vec[corner]
        # meshgrid of grid corners in x-y space
        gc_ee, gc_nn = np.meshgrid(
            gc_easting[:, corner], gc_northing[:, corner])
        # project grid corners from x-y to lat-lon space
        gc_lon[:, :, corner], gc_lat[:, :, corner] = proj(
            gc_ee, gc_nn, inverse=True)


    nc = CDF(ofile, 'w')

    nc.createDimension(xdim, size=easting.shape[0])
    nc.createDimension(ydim, size=northing.shape[0])
    
    var = xdim
    var_out = nc.createVariable(var, 'f', dimensions=(xdim))
    var_out.axis = xdim
    var_out.long_name = "X-coordinate in Cartesian system"
    var_out.standard_name = "projection_x_coordinate"
    var_out.units = "meters"
    var_out[:] = easting

    var = ydim
    var_out = nc.createVariable(var, 'f', dimensions=(ydim))
    var_out.axis = ydim
    var_out.long_name = "Y-coordinate in Cartesian system"
    var_out.standard_name = "projection_y_coordinate"
    var_out.units = "meters"
    var_out[:] = northing

    var = 'lon'
    var_out = nc.createVariable(var, 'f', dimensions=(ydim, xdim))
    var_out.units = "degrees_east"
    var_out.valid_range = -180., 180.
    var_out.standard_name = "longitude"
    var_out.bounds = "lon_bnds"
    var_out[:] = lon

    var = 'lat'
    var_out = nc.createVariable(var, 'f', dimensions=(ydim, xdim))
    var_out.units = "degrees_north"
    var_out.valid_range = -90., 90.
    var_out.standard_name = "latitude"
    var_out.bounds = "lat_bnds"
    var_out[:] = lat

    nc.createDimension(grid_corner_dim_name, size=grid_corners)

    var = 'lon_bnds'
    # Create variable 'lon_bnds'
    var_out = nc.createVariable(
        var, 'f', dimensions=(ydim, xdim, grid_corner_dim_name))
    # Assign units to variable 'lon_bnds'
    var_out.units = "degreesE"
    # Assign values to variable 'lon_nds'
    var_out[:] = gc_lon
        
    var = 'lat_bnds'
    # Create variable 'lat_bnds'
    var_out = nc.createVariable(
        var, 'f', dimensions=(ydim, xdim, grid_corner_dim_name))
    # Assign units to variable 'lat_bnds'
    var_out.units = "degreesN"
    # Assign values to variable 'lat_bnds'
    var_out[:] = gc_lat

    var = 'dummy'
    var_out = nc.createVariable(
        var,
        'f',
        dimensions=(
            "y",
            "x"),
        fill_value=-2e9)
    var_out.units = "meters"
    var_out.long_name = "Just A Dummy"
    var_out.comment = "This is just a dummy variable for CDO."
    var_out.grid_mapping = "mapping"
    var_out.coordinates = "lon lat"
    var_out[:] = 0.

    mapping = nc.createVariable("mapping", 'c')
    mapping.ellipsoid = "WGS84"
    mapping.false_easting = 0.
    mapping.false_northing = 0.
    mapping.grid_mapping_name = "polar_stereographic"
    mapping.latitude_of_projection_origin = 90.
    mapping.standard_parallel = 70.
    mapping.straight_vertical_longitude_from_pole = -45.

    from time import asctime
    historystr = 'Created ' + asctime() + '\n'
    nc.history = historystr
    nc.proj4 = projection
    nc.Conventions = 'CF-1.5'
    nc.close()

def adjust_time_axis(ifile, start_date, end_date, ref_unit, ref_date, periodicity):
    
    nc = CDF(ifile, 'a')

    time_units = ("%s since %s" % (ref_unit, ref_date))
    time_calendar = "standard"

    cdftime = utime(time_units, time_calendar)

    # create a dictionary so that we can supply the periodicity as a
    # command-line argument.
    pdict = {}
    pdict['SECONDLY'] = rrule.SECONDLY
    pdict['MINUTELY'] = rrule.MINUTELY
    pdict['HOURLY'] = rrule.HOURLY
    pdict['DAILY'] = rrule.DAILY
    pdict['WEEKLY'] = rrule.WEEKLY
    pdict['MONTHLY'] = rrule.MONTHLY
    pdict['YEARLY'] = rrule.YEARLY
    prule = pdict[periodicity.upper()]

    # reference date from command-line argument
    r = time_units.split(' ')[2].split('-')
    refdate = datetime(int(r[0]), int(r[1]), int(r[2]))

    # create list with dates from start_date until end_date with
    # periodicity prule.
    bnds_datelist = list(rrule.rrule(prule, dtstart=parse(start_date), until=parse(end_date)))

    # calculate the days since refdate, including refdate, with time being the
    # mid-point value:
    # time[n] = (bnds[n] + bnds[n+1]) / 2
    bnds_interval_since_refdate = cdftime.date2num(bnds_datelist)
    time_interval_since_refdate = (bnds_interval_since_refdate[0:-1] +
                                   np.diff(bnds_interval_since_refdate) / 2)

    # create a new dimension for bounds only if it does not yet exist
    time_dim = "time"
    if time_dim not in nc.dimensions.keys():
        nc.createDimension(time_dim)

    # create a new dimension for bounds only if it does not yet exist
    bnds_dim = "nb2"
    if bnds_dim not in nc.dimensions.keys():
        nc.createDimension(bnds_dim, 2)

    # variable names consistent with PISM
    time_var_name = "time"
    bnds_var_name = "time_bnds"

    # create time variable
    if time_var_name not in nc.variables:
        time_var = nc.createVariable(time_var_name, 'd', dimensions=(time_dim))
    else:
        time_var = nc.variables[time_var_name]
    time_var[:] = time_interval_since_refdate
    time_var.bounds = bnds_var_name
    time_var.units = time_units
    time_var.calendar = time_calendar
    time_var.standard_name = time_var_name
    time_var.axis = "T"

    # create time bounds variable
    if bnds_var_name not in nc.variables:
        time_bnds_var = nc.createVariable(bnds_var_name, 'd', dimensions=(time_dim, bnds_dim))
    else:
        time_bnds_var = nc.variables[bnds_var_name]
        
    time_bnds_var[:, 0] = bnds_interval_since_refdate[0:-1]
    time_bnds_var[:, 1] = bnds_interval_since_refdate[1::]

    nc.close()


def prepare_pr(dry=False):
    logger.info('processing variable PR')    
    PR_files = ['DMI-HIRHAM5_GL2_ERAI_2001_2010_PR_DM.nc.gz', 'DMI-HIRHAM5_GL2_ERAI_2011_2014_PR_DM.nc.gz']
    pr_files = []
    for pr_file in PR_files:
        logger.info('extracting {}'.format(pr_file))
        cmd = ['gunzip', pr_file]
        # sub.call(cmd)
        pr_files.append(pr_file[:-3])
        
    pr_merged_file_daily_mean = 'DMI-HIRHAM5_GL2_ERAI_2001_2014_PR_{}.nc'.format(daily_mean)
    pr_merged_file_time_mean = 'DMI-HIRHAM5_GL2_ERAI_2001_2014_PR_{}.nc'.format(time_mean)

    if dry == False:
        logger.info('merge files {} to {}'.format(pr_files, pr_merged_file_daily_mean))  
        tmpfile = cdo.mergetime(input=' '.join(pr_files))
    
        logger.info('removing height dimension')
        nco.ncwa(input=tmpfile, output=pr_merged_file_daily_mean, average='height')
    
        logger.info('adjusting time axis')
        adjust_time_axis(pr_merged_file_daily_mean, '2001-1-1', '2015-1-1', 'days', '1980-1-1', 'daily')
    
        opt = [c.Atted(mode="o", att_name="units", var_name="time", value="days since 1980-01-01 03:00:00")]
        nco.ncatted(input=pr_merged_file_daily_mean, options=opt)
    
        logger.info('calculate time mean')
        cdo.timmean(input='-yearsum ' + pr_merged_file_daily_mean, output=pr_merged_file_time_mean)

        logger.info('renaming variable')
        rDict={ 'pr': 'precipitation'}
        nco.ncrename(input=pr_merged_file_time_mean, options=[ c.Rename("variable", rDict)])
        opt = [c.Atted(mode="o", att_name="units", var_name="precipitation", value="kg m-2 yr-1"),
               c.Atted(mode="o", att_name="standard_name", var_name="precipitation", value="precipitation_flux")]
        nco.ncatted(input=pr_merged_file_time_mean, options=opt)

    return pr_merged_file_time_mean

def prepare_tas(dry=False):
    logger.info('processing variable TAS')
    TAS_files = ['DMI-HIRHAM5_GL2_ERAI_2001_2010_TAS_DM.nc.gz', 'DMI-HIRHAM5_GL2_ERAI_2011_2014_TAS_DM.nc.gz']
    tas_files = []
    for tas_file in TAS_files:
        logger.info('extracting {}'.format(tas_file))
        cmd = ['gunzip', tas_file]
        # sub.call(cmd)
        tas_files.append(tas_file[:-3])

    tas_merged_file_daily_mean = 'DMI-HIRHAM5_GL2_ERAI_2001_2014_TAS_{}.nc'.format(daily_mean)
    tas_merged_file_time_mean = 'DMI-HIRHAM5_GL2_ERAI_2001_2014_TAS_{}.nc'.format(time_mean)

    if dry == False:

        logger.info('merge files {} to {}'.format(tas_files, tas_merged_file_daily_mean))
        tmpfile = cdo.mergetime(input=' '.join(tas_files))
        
        logger.info('removing height dimension')
        nco.ncwa(input=tmpfile, output=tas_merged_file_daily_mean, average='height')

        logger.info('adjusting time axis')
        adjust_time_axis(tas_merged_file_daily_mean, '2001-1-1', '2015-1-1', 'days', '1980-1-1', 'daily')

        opt = [c.Atted(mode="o", att_name="units", var_name="time", value="days since 1980-01-01 03:00:00")]
        nco.ncatted(input=tas_merged_file_daily_mean, options=opt)
        logger.info('calculate time mean')
        cdo.timmean(input=tas_merged_file_daily_mean, output=tas_merged_file_time_mean)
        
        logger.info('renaming variable')
        rDict={ 'tas':'air_temp'}
        nco.ncrename(input=tas_merged_file_time_mean, options=[ c.Rename("variable",rDict)])
        
        logger.info('calculate standard deviation')
        tmpfile = cdo.timstd(input=tas_merged_file_daily_mean)
        logger.info('renaming variable')
        rDict={ 'tas':'air_temp_sd'}
        nco.ncrename(input=tmpfile, options=[ c.Rename("variable",rDict)])
        nco.ncks(input=tmpfile, output=tas_merged_file_time_mean, append=True)

        logger.info('calculate mean July temp')
        tmpfile = cdo.timmean(input='-selmonth,7 ' + tas_merged_file_daily_mean)
        logger.info('renaming variable')
        rDict={ 'tas':'air_temp_mean_july'}
        nco.ncrename(input=tmpfile, options=[ c.Rename("variable",rDict)])
        nco.ncks(input=tmpfile, output=tas_merged_file_time_mean, append=True)

    return tas_merged_file_time_mean

def prepare_smb(dry=False):
    logger.info('processing variable SMB')
    SMB_files = ['DMI-HIRHAM5_GL2_ERAI_2001_2010_gld_DM.nc.gz', 'DMI-HIRHAM5_GL2_ERAI_2011_2014_gld_DM.nc.gz']
    smb_files = []
    for smb_file in SMB_files:
        logger.info('extracting {}'.format(smb_file))
        cmd = ['gunzip', smb_file]
        # sub.call(cmd)
        smb_files.append(smb_file[:-3])

    smb_merged_file_daily_mean = 'DMI-HIRHAM5_GL2_ERAI_2001_2014_SMB_{}.nc'.format(daily_mean)
    smb_merged_file_time_mean = 'DMI-HIRHAM5_GL2_ERAI_2001_2014_SMB_{}.nc'.format(time_mean)

    if dry == False:
        
        logger.info('merge files {} to {}'.format(smb_files, smb_merged_file_daily_mean))
        cdo.mergetime(input=' '.join(smb_files), output=smb_merged_file_daily_mean)

        logger.info('adjusting time axis')
        adjust_time_axis(smb_merged_file_daily_mean, '2001-1-1', '2015-1-1', 'days', '1980-1-1', 'daily')

        opt = [c.Atted(mode="o", att_name="units", var_name="time", value="days since 1980-01-01 03:00:00")]
        nco.ncatted(input=smb_merged_file_daily_mean, options=opt)
        
        logger.info('calculate time mean')
        # Convert mm to m and then to kg m-2
        cdo.timmean(input='-mulc,' + str(ice_density / 1000) + ' -yearsum ' + smb_merged_file_daily_mean, output=smb_merged_file_time_mean)
        
        logger.info('renaming variable')
        rDict={ 'gld':'climatic_mass_balance'}
        nco.ncrename(input=smb_merged_file_time_mean, options=[ c.Rename("variable",rDict)])
        opt = [c.Atted(mode="o", att_name="units", var_name="climatic_mass_balance", value="kg m-2 yr-1"),
               c.Atted(mode="o", att_name="standard_name", var_name="climatic_mass_balance", value="land_ice_surface_specific_mass_balance_flux")]
        nco.ncatted(input=smb_merged_file_time_mean, options=opt)
        
    return smb_merged_file_time_mean

# set up the option parser
parser = ArgumentParser()
parser.description = "Generating scripts for prognostic simulations."
options = parser.parse_args()

ice_density = 910.

daily_mean = 'DM'
time_mean = 'TM'

topo_file = 'topo_geog.nc'
rotated_grid_file = 'rotated_grid.txt'

dry = True
pr_merged_file_time_mean = prepare_pr(dry=dry)
tas_merged_file_time_mean = prepare_tas(dry=dry)
smb_merged_file_time_mean = prepare_smb(dry=dry)

merged_file_time_mean = 'DMI-HIRHAM5_GL2_ERAI_2001_2014_{}.nc'.format(time_mean)
logger.info('merge PR, TAS, and SMB')
nco.ncks(input=smb_merged_file_time_mean, output=merged_file_time_mean, overwrite=True)
nco.ncks(input=pr_merged_file_time_mean, output=merged_file_time_mean, append=True)
nco.ncks(input=tas_merged_file_time_mean, output=merged_file_time_mean, append=True)

# add topo file
logger.info('removing height dimension of topo file')
topo_file_tmp_1 = 'tmp1_topo_geog.nc'
topo_file_tmp_2 = 'tmp2_topo_geog.nc'
nco.ncwa(input=topo_file, output=topo_file_tmp_1, average='height')
nco.ncwa(input=topo_file_tmp_1, output=topo_file_tmp_2, average='time')
logger.info('renaming variables and dimensions')
rDict={ 'var6':'usurf'}
dDict={ 'x':'rlon', 'y': 'rlat'}
nco.ncrename(input=topo_file_tmp_2, options=[c.Rename("variable", rDict),
                                             c.Rename("dimension", dDict)])

logger.info('add topo file {} to {}'.format(topo_file, merged_file_time_mean))
nco.ncks(input=topo_file_tmp_2, output=merged_file_time_mean, append=True, variable='usurf')
opt = [c.Atted(mode="o", att_name="units", var_name="usurf", value="m"),
       c.Atted(mode="o", att_name="standard_name", var_name="usurf", value="surface_altitude")]
nco.ncatted(input=merged_file_time_mean, options=opt)


# for grid_spacing in (18000, 9000, 4500, 3600, 3000, 2400, 1800, 1500, 1200, 900, 600):
for grid_spacing in [9000]:
    grid_file = 'epsg3413_griddes_{}m.nc'.format(grid_spacing)
    logger.info('generating grid description {}'.format(grid_file))
    create_epsg3413_grid(grid_file, grid_spacing)
    epsg3413_merged_file_time_mean = 'DMI-HIRHAM5_GL2_ERAI_2001_2014_{}_EPSG3413_{}m.nc'.format(time_mean, grid_spacing)
    logger.info('remapping {} to {}'.format(merged_file_time_mean, epsg3413_merged_file_time_mean))
    tmpfile = cdo.remapycon('{} -setgrid,{}'.format(grid_file, rotated_grid_file),
                            input=merged_file_time_mean,
                            options='-f nc4')
    cdo.setmisstoc(0, input=tmpfile, output=epsg3413_merged_file_time_mean)
    nco.ncks(input=grid_file, output=epsg3413_merged_file_time_mean, append=True)
    opt = [c.Atted(mode="d", att_name="_FillValue", var_name="precipitation"),
           c.Atted(mode="d", att_name="missing_value", var_name="precipitation"),
           c.Atted(mode="o", att_name="grid_mapping", var_name="precipitation", value="mapping"),
           c.Atted(mode="d", att_name="_FillValue", var_name="air_temp"),
           c.Atted(mode="d", att_name="missing_value", var_name="air_temp"),
           c.Atted(mode="o", att_name="grid_mapping", var_name="air_temp", value="mapping"),
           c.Atted(mode="d", att_name="_FillValue", var_name="climatic_mass_balance"),
           c.Atted(mode="d", att_name="missing_value", var_name="climatic_mass_balance"),
           c.Atted(mode="o", att_name="grid_mapping", var_name="climatic_mass_balance", value="mapping")]
    nco.ncatted(input=epsg3413_merged_file_time_mean, options=opt)
    
