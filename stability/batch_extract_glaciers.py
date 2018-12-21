# Copyright (C) 2018 Andy Aschwanden

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
import fiona
import os


def batch_str(ugid, uri, odir):
    bstr = """#!/bin/bash
#PBS -q analysis
#PBS -l walltime=36:00:00
#PBS -l nodes=1:ppn=1
#PBS -j oe
#SBATCH --mem=214GB

source ~/.bash_profile

cd $SLURM_SUBMIT_DIR

ulimit -l unlimited
ulimit -s unlimited
ulimit

cd /import/c1/ICESHEET/aaschwanden/pism-gris/stability/2018_08_ctrl/spatial
mkdir -p ../glaciers/
python ~/base/gris-analysis/basins/extract_glacier.py --no_extraction --ugid {ugid} --o_dir {odir}  {uri}
""".format(
        odir=odir, ugid=ugid, uri=uri
    )

    return bstr


# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Extract basins from continental scale files."
parser.add_argument("FILE", nargs=1)
parser.add_argument("--o_dir", dest="odir", help="output directory", default="../glaciers")
parser.add_argument(
    "--shape_file",
    dest="shape_file",
    help="Path to shape file with basins",
    default="/home/aaschwanden/base/gris-analysis/basins/Greenland_Basins_PS_v1.4.2c.shp",
)
parser.add_argument(
    "-v",
    "--variable",
    dest="variable",
    help="Comma-separated list of variables to be extracted. By default, all variables are extracted.",
    default=None,
)
parser.add_argument("--start_date", help="Start date YYYY-MM-DD", default="2008-1-1")
parser.add_argument("--end_date", help="End date YYYY-MM-DD", default="2299-1-1")

options = parser.parse_args()
uri = os.path.basename(options.FILE[0])
shape_file = options.shape_file
odir = options.odir

ds = fiona.open(shape_file, encoding="utf-8")

glacier_ugids = []
for item in ds.items():
    if item[1]["properties"]["id"] is not None:
        glacier_ugids.append(item[1]["properties"]["UGID"])

for k in range(len(glacier_ugids)):
    ugid = glacier_ugids[k]
    script = "extract_ugid_{}.sh".format(ugid)
    with open(script, "w") as f:
        f.write(batch_str(ugid, uri, odir))
