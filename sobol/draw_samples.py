#!/usr/bin/env python

import numpy as np
import pandas as pd
from scipy.stats.distributions import truncnorm, gamma, uniform, randint

from SALib.sample import saltelli
from SALib.analyze import sobol

# The number of allowable model runs
n_samples = 3

# Names of all the variables
keys = ["GCM", "PPQ", "SIAE"]


# scipy.stats.distributions objects for each distribution, per Table 1 in the paper.  Note that for truncated normal, the bounds are relative to the mean in units of scale, so if we want a positive distribution for a normal with mean 8 and sigma 4, then the lower bound is -8/4=-2
distributions = {
    "GCM": randint(0, 4),
    "PPQ": truncnorm(-0.35 / 0.2, 0.35 / 0.2, loc=0.6, scale=0.2),
    "SIAE": gamma(1.5, scale=0.8, loc=1),
}


# Generate the Sobol sequence samples with uniform distributions

problem = {"num_vars": len(keys), "names": keys, "bounds": [[0, 1]] * len(keys)}

# Generate samples
unif_sample = saltelli.sample(problem, n_samples, calc_second_order=False)


# To hold the transformed variables
dist_sample = np.zeros_like(unif_sample)


# For each variable, transform with the inverse of the CDF (inv(CDF)=ppf)
for i, key in enumerate(keys):
    dist_sample[:, i] = distributions[key].ppf(param_values[:, i])


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
