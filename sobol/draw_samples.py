#!/usr/bin/env python
# (C) 2017-2019 Andy Aschwanden, Doug Brinkerhoff

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

parser = ArgumentParser()
parser.description = "Draw samples using the Saltelli methods"
parser.add_argument(
    "-s", "--n_samples", dest="n_samples", type=int, help="""number of samples to draw. default=40.""", default=40
)
parser.add_argument("OUTFILE", nargs=1, help="Ouput file (CSV)", default="saltelli_samples.csv")
options = parser.parse_args()
n_samples = options.n_samples
outfile = options.OUTFILE[-1]

distributions = {
    "GCM": randint(0, 4),
    "FICE": truncnorm(-4 / 4.0, 4.0 / 4, loc=8, scale=4),
    "FSNOW": truncnorm(-4.1 / 3, 4.1 / 3, loc=4.1, scale=1.5),
    "PRS": uniform(loc=5, scale=2),
    "RFR": truncnorm(-0.4 / 0.3, 0.4 / 0.3, loc=0.5, scale=0.2),
    "OCM": randint(-1, 2),
    "OCS": randint(-1, 2),
    "TCT": randint(-1, 2),
    "VCM": truncnorm(-0.35 / 0.2, 0.35 / 0.2, loc=1, scale=0.2),
    "PPQ": truncnorm(-0.35 / 0.2, 0.35 / 0.2, loc=0.6, scale=0.2),
    "SIAE": gamma(1.5, scale=0.8, loc=1),
}

# Generate the Sobol sequence samples with uniform distributions


# Names of all the variables
keys = [x for x in distributions.keys()]

# Describe the Problem
problem = {"num_vars": len(keys), "names": keys, "bounds": [[0, 1]] * len(keys)}

# Generate uniform samples (i.e. one unit hypercube)
unif_sample = saltelli.sample(problem, n_samples, calc_second_order=False)

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
