#!/usr/bin/env python

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
options = parser.parse_args()
n_samples = options.n_samples

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

# Names of all the variables
keys = [x for x in distributions.keys()]


# Generate the Sobol sequence samples with uniform distributions

problem = {"num_vars": len(keys), "names": keys, "bounds": [[0, 1]] * len(keys)}

# Generate samples
unif_sample = saltelli.sample(problem, n_samples, calc_second_order=False)

# To hold the transformed variables
dist_sample = np.zeros_like(unif_sample)


# For each variable, transform with the inverse of the CDF (inv(CDF)=ppf)
for i, key in enumerate(keys):
    dist_sample[:, i] = distributions[key].ppf(unif_sample[:, i])


# Convert to Pandas dataframe, append column headers, output as csv
df = pd.DataFrame(dist_sample)
df.to_csv("saltelli_samples.csv", header=keys, index=True)
