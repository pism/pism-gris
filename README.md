PISM, a Parallel Ice Sheet Model
================================

The Parallel Ice Sheet Model is an open source, parallel, high-resolution ice sheet model:

* hierarchy of available stress balances
* marine ice sheet physics, dynamic calving fronts
* polythermal, enthalpy-based conservation of energy scheme
* extensible coupling to atmospheric and ocean models
* verification and validation tools
* complete [documentation](http://www.pism-docs.org/) for users and developers
* uses [MPI](http://www-unix.mcs.anl.gov/mpi/) and [PETSc](http://www-unix.mcs.anl.gov/petsc/petsc-as/) for parallel simulations
* reads and writes [CF-compliant](http://cf-pcmdi.llnl.gov/) [NetCDF](http://www.unidata.ucar.edu/software/netcdf/) files

PISM is jointly developed at the [University of Alaska, Fairbanks (UAF)](http://www.uaf.edu/) and the [Potsdam Institute for Climate Impact Research (PIK)](http://www.pik-potsdam.de/).  UAF developers are based in the [Glaciers Group](http://www.gi.alaska.edu/snowice/glaciers/) at the [Geophysical Institute](http://www.gi.alaska.edu).

PISM development is supported by the [NASA Modeling, Analysis, and Prediction program](http://map.nasa.gov/) (grant #NNX13AM16G) and the [NASA Cryospheric Sciences program](http://ice.nasa.gov/) (grant #NNX13AK27G).


Homepage
--------

[www.pism-docs.org](http://www.pism-docs.org/)


pism-gris
================================

Repository which contains scripts and tools for simulations of the Greenland Ice Sheet (GrIS) with PISM.

data_sets
--------

initMIP
--------

Scripts related to [initMIP](http://http://www.climate-cryosphere.org/wiki/index.php?title=InitMIP)

initialization
--------

Scripts for paleo simulations / initial states

prognostic
--------

Scripts for prognostic simulations