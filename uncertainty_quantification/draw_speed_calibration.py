#!/usr/bin/env python
# (C) 2017-2021 Andy Aschwanden, Doug Brinkerhoff

# This script draws samples with the Sobol Sequences
# using the Saltelli method
#
# Herman, J., Usher, W., (2017), SALib:
# An open-source Python library for Sensitivity Analysis, Journal of Open Source Software,
# 2(9), 97, doi:10.21105/joss.00097

from argparse import ArgumentParser
import numpy as np
import pandas as pd
from scipy.stats.distributions import truncnorm, gamma, uniform, randint

from SALib.sample import saltelli
from pyDOE import lhs

parser = ArgumentParser()
parser.description = "Draw samples using LHS or Saltelli."
parser.add_argument(
    "-s",
    "--n_samples",
    dest="n_samples",
    type=int,
    help="""number of samples to draw. default=10.""",
    default=10,
)
parser.add_argument(
    "-m",
    "--method",
    dest="method",
    type=str,
    choices=["lhs", "saltelli"],
    help="""number of samples to draw. default=saltelli.""",
    default="saltelli",
)
parser.add_argument("OUTFILE", nargs=1, help="Ouput file (CSV)", default="samples.csv")
options = parser.parse_args()
method = options.method
n_samples = options.n_samples
outfile = options.OUTFILE[-1]

np.random.seed(2)

distributions = {
    "SIAE": uniform(
        loc=1.0, scale=3.0
    ),  # uniform between 1 and 4    AS16 best value: 1.25
    "SSAN": uniform(
        loc=3.0, scale=0.5
    ),  # uniform between 3 and 3.5  AS16 best value: 3.25
    "PPQ": uniform(loc=0.25, scale=0.7),  # uniform between 0.25 and 0.95
    "TEFO": uniform(loc=0.005, scale=0.025),  # uniform between 0.015 and 0.030
    "PHIMIN": uniform(loc=5.0, scale=15.0),  # uniform between  5 and 20
    "PHIMAX": uniform(loc=40.0, scale=5.0),  # uniform between  40 and 45
    "ZMIN": uniform(loc=-1000, scale=1000),  # uniform between -1000 and 0
    "ZMAX": uniform(loc=0, scale=1000),  # uniform between 0 and 1000
}


# Names of all the variables
keys = [x for x in distributions.keys()]

# Describe the Problem
problem = {"num_vars": len(keys), "names": keys, "bounds": [[0, 1]] * len(keys)}

# Generate uniform samples (i.e. one unit hypercube)
if method == "saltelli":
    unif_sample = saltelli.sample(problem, n_samples, calc_second_order=False)
elif method == "lhs":
    unif_sample = lhs(len(keys), n_samples)
else:
    print(f"Method {method} not available")

# To hold the transformed variables
dist_sample = np.zeros_like(unif_sample)

# Now transform the unit hypercube to the prescribed distributions
# For each variable, transform with the inverse of the CDF (inv(CDF)=ppf)
for i, key in enumerate(keys):
    dist_sample[:, i] = distributions[key].ppf(unif_sample[:, i])

# Save to CSV file using Pandas DataFrame and to_csv method
header = keys
# Convert to Pandas dataframe, append column headers, output as csv
df = pd.DataFrame(data=dist_sample, columns=header)

df.to_csv(outfile, index=True, index_label="id")

df["PHIMAX"] = 45.0
df = df[["SIAE", "SSAN", "PPQ", "TEFO", "PHIMIN", "PHIMAX", "ZMIN", "ZMAX"]]
df.to_csv(f"ensemble_{outfile}", index=True, index_label="id")
