#!/usr/bin/env python

import numpy as np
import pandas as pd
from scipy.stats.distributions import truncnorm, gamma, uniform, randint

from SALib.sample import saltelli
from SALib.analyze import sobol

# The number of allowable model runs
n_samples = 13

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
keys = ["GCM", "FICE", "FSNOW", "PRS", "RFR", "OCM", "OCS", "TCT", "VCM", "PPQ", "SIAE"]


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

# Plot a histogram of each variable
plot = True
if plot:
    import matplotlib.pyplot as plt

    fig, axs = plt.subplots(len(keys), 1)
    fig.set_size_inches(6, 15)
    fig.subplots_adjust(hspace=0.45)
    for i, key in enumerate(keys):
        axs[i].hist(dist_sample[:, i], 20, normed=True, histtype="step")
        axs[i].set_ylabel(key)
    fig.savefig("parameter_histograms.pdf")
