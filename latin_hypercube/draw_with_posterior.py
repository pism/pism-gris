#!/usr/bin/env python

from argparse import ArgumentParser
import numpy as np
import pandas as pd
from pyDOE import lhs
from scipy.stats.distributions import truncnorm, gamma, uniform, randint
import pylab as plt

parser = ArgumentParser()
parser.description = "Draw samples using the Saltelli or LHS method"
parser.add_argument(
    "-s", "--n_samples", dest="n_samples", type=int, help="""number of samples to draw. default=10.""", default=500
)
parser.add_argument(
    "-m",
    "--method",
    dest="method",
    type=str,
    choices=["lhs", "saltelli"],
    help="""number of samples to draw. default=saltelli.""",
    default="lhs",
)
parser.add_argument("POSTERIORFILE", nargs=1, help="Ouput file (CSV)", default="X_posterior.csv.gz")
parser.add_argument("OUTFILE", nargs=1, help="Ouput file (CSV)", default="samples.csv")
options = parser.parse_args()
method = options.method
n_samples = options.n_samples
posteriorfile = options.POSTERIORFILE[-1]
outfile = options.OUTFILE[-1]


# scipy.stats.distributions objects for each distribution, per Table 1 in the paper.  Note that for truncated normal, the bounds are relative to the mean in units of scale, so if we want a positive distribution for a normal with mean 8 and sigma 4, then the lower bound is -8/4=-2
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
}

X_posterior = pd.read_csv(posteriorfile)

print(X_posterior)


# Names of all the variables that do not appear in X
keys_prior = ["GCM", "FICE", "FSNOW", "PRS", "RFR", "OCM", "OCS", "TCT", "VCM"]
keys_mc = list(X_posterior.keys()[1:])
keys = keys_prior + keys_mc

# Generate the latin hypercube samples with uniform distributions
unif_sample = lhs(len(keys_prior), n_samples)

# To hold the transformed variables
dist_sample = np.zeros_like(unif_sample)

# For each variable, transform with the inverse of the CDF (inv(CDF)=ppf)
for i, key in enumerate(keys_prior):
    dist_sample[:, i] = distributions[key].ppf(unif_sample[:, i])

mc_indices = np.random.choice(range(X_posterior.shape[0]), n_samples)
X_sample = X_posterior.to_numpy()[mc_indices, 1:]

dist_sample = np.hstack((dist_sample, X_sample))

# Convert to Pandas dataframe, append column headers, output as csv
df = pd.DataFrame(dist_sample)
df.to_csv(outfile, header=keys, index=True)

fig, axs = plt.subplots(len(keys[1:6]), 1)
fig.set_size_inches(6, 6)
fig.subplots_adjust(hspace=0.45)
for i, key in enumerate(keys[1:6]):
    axs[i].hist(dist_sample[:, i], 20, density=True, histtype="step")
    axs[i].set_ylabel(key)
fig.savefig("parameter_histograms.pdf", bbox_inches="tight")
