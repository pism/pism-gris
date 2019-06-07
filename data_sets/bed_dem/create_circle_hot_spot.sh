#!/bin/bash

# Produces geothermal hot spot in variable bheatflx.

# Version 2:  instead of circular hot blob near divide, an elliptical blob
#   along the NE Greenland ice stream route; the ends of the long, narrow
#   ellipse were eye-balled to be at the original center (-32000m, -1751180m)
#   and at (103000m,-1544330) (in projection coords used by SeaRISE)
# here are relevant octave computations:
# > 0.5*(-32000+103000)
# ans =  35500  # x coord of new center
# > 0.5*(-1751180 + -1544330)
# ans = -1647755  # y coord center
# > theta = atan( (-1544330 - (-1647755)) / (103000 - 35500) )
# theta =  0.99256  # rotation angle; = 56.9 deg
# > cos(theta)
# ans =  0.54655
# > sin(theta)
# ans =  0.83743
# > a = sqrt( (103000 - 35500)^2 +  (-1544330 - (-1647755))^2 )
# a =  1.2350e+05
# > b = 50000^2 / a  #  set b so that ab=R^2 where R = 50 km is orig radius
# b =  2.0242e+04

# Version 1:  The spot is at the
# source area of the NE Greenland ice stream.  The spot has the location,
# magnitude and extent suggested by
#    M. Fahnestock, et al (2001).  High geothermal heat flow, basal melt, and 
#    the origin of rapid ice flow in central Greenland, Science vol 294, 2338--2342.
# Uses NCO (ncrename, ncap2, ncks, ncatted).
# Run preprocess.py first to generate $PISMVERSION.
# center of hot spot is  (-40 W lon, 74 deg N lat)  which is
#   (x,y) = (-32000m, -1751180m)  in projection already used in $DATANAME
# parameters: radius of spot = 50000m and heat is 970 mW m-2 from Fahnstock et al 2001

# NOTE 5/20/2014:
# Switch to EPSG:3413, use coordinates in EPSG:3413 projection
# (x0, y0) = (207000, -1630000)
# 

set -e  -x # exit on error

INFILE=foo.nc
if [ $# -gt 0 ] ; then
  INFILE="$1"
fi

OUTFILE=bar.nc
if [ $# -gt 1 ] ; then
  OUTFILE="$2"
fi

cp $INFILE $OUTFILE

# center:
X0=206500
Y0=1630000
R=100000

GHFSPOT=0.970   # from Fahnstock et al 2001; in W m-2

ncrename -v bheatflx,bheatflxSR $OUTFILE  # keep Shapiro & Ritzwoller

# do equivalent of Matlab's:  [xx,yy] = meshgrid(x,y)
ncap2 -O -s 'zero=0.0*lat' $OUTFILE $OUTFILE # note lat=lat(x,y)
ncap2 -O -s 'xx=zero+x' $OUTFILE $OUTFILE
ncap2 -O -s 'yy=zero+y' $OUTFILE $OUTFILE
R2="r2=(xx-${X0})^2/${R}^2+(yy+${Y0})^2/${R}^2;"
ncap2 -O -s $R2 $OUTFILE $OUTFILE
ncap2 -O -s 'hotmask=(r2-1<0)' $OUTFILE $OUTFILE

# actually create hot spot
NEWBHEATFLX="bheatflx=hotmask*${GHFSPOT}+!hotmask*bheatflxSR"
ncap2 -O -s $NEWBHEATFLX $OUTFILE $OUTFILE

# ncap2 leaves hosed attributes; start over
ncatted -a units,bheatflx,o,c,"W m-2" $OUTFILE
ncatted -a long_name,bheatflx,c,c,"basal geothermal flux" $OUTFILE
ncatted -a _CoordinateAxisType,bheatflx,d,, -a standard_name,bheatflx,d,, -a bounds,bheatflx,d,, -a propose_standard_name,bheatflx,c,c,"lithosphere_upward_heat_flux" $OUTFILE

# clear out the temporary variables and only leave additional 'bheatflxSR'
ncks -O -x -v r2,xx,yy,xi,eta,eleft,eright,hotmask,zero,bheatflxSR $OUTFILE $OUTFILE

echo "PISM-readable file '$OUTFILE' created from '$INFILE':"
echo "  * variable 'bheatflxSR' is copy of 'bheatflx' from '$INFILE'"
echo "  * variable 'bheatflx' has added hot spot near source of NE Greenland ice stream:"
echo "      center: (74 deg N lat, -40 W lon)"
echo "      radius: $RSPOT m"
echo "      value : $GHFSPOT W m-2"
echo "  * reference for hot spot is"
echo "      M. Fahnestock, et al (2001).  High geothermal heat flow, basal melt, and"
echo "      the origin of rapid ice flow in central Greenland, Science vol 294, 2338--2342."
