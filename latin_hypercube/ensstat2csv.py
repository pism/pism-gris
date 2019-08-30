#!/usr/bin/env python
# Copyright (C) 2019 Andy Aschwanden

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from braceexpand import braceexpand
import numpy as np
from netCDF4 import Dataset as NC
import os
import re
import pandas as pd


# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Generating scripts for warming experiments."
parser.add_argument(
    "-v", "--variable", dest="variable", help="Variable to read in. Default=ice_mass", default="ice_mass"
)

options = parser.parse_args()
variable = options.variable
pctls = ["5", "16", "50", "84", "95"]
glacier_ugids = [225, 105, 63]
ng = len(glacier_ugids)
for rcp in ["85"]:
    for idx in [42, 92]:
        df = pd.DataFrame(data=glacier_ugids, columns=["UGID"])
        for pctl in pctls:
            pctl_vals = np.zeros([ng])
            for k, ugid in enumerate(glacier_ugids):
                ifile = "2019_08_les/glaciers_ensstat/enspctl{}_fldsum_ugid_{}_ex_gris_g1800m_v3a_rcp_{}.nc".format(
                    pctl, ugid, rcp
                )
                nc = NC(ifile)
                val = nc.variables[variable][0] - nc.variables[variable][idx]
                val /= 365 * 1e13
                pctl_vals[k] = val
                nc.close()
            df = df.join(pd.DataFrame(data=pctl_vals, columns=[pctl]))
        year = 2008 + idx
        df.to_csv("2019_08_les/glaciers_pctls/pctls_dgmsl_rcp_{}_{}.csv".format(rcp, year), index=False)
