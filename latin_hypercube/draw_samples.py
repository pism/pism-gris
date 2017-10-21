import numpy as np
import pandas as pd
from pyDOE import lhs
from scipy.stats.distributions import truncnorm,gamma,uniform,randint

# The number of allowable model runs
n_samples = 1000

# scipy.stats.distributions objects for each distribution, per Table 1 in the paper.  Note that for truncated normal, the bounds are relative to the mean in units of scale, so if we want a positive distribution for a normal with mean 8 and sigma 4, then the lower bound is -8/4=-2
distributions = {'FICE':  truncnorm(-2,1e6,loc=8,scale=4),
                 'FSNOW': truncnorm(-4.1/1.5,1e6,loc=4.1,scale=1.5),
                 'PRS':   uniform(loc=5,scale=2),
                 'RFR':   truncnorm(-0.5/0.2,1e6,loc=0.5,scale=0.2),
                 'OCM':   randint(-1,2),
                 'OCS':   randint(-1,2),
                 'TCT':   randint(-1,2),
                 'VCM':   truncnorm(-1./0.35,1e6,loc=1,scale=0.35),
                 'PPQ':   truncnorm(-0.6/0.3,1e6,loc=0.6,scale=0.3),
                 'SIA':   gamma(5,scale=1.25/4.)}

# Names of all the variables
keys = ['FICE','FSNOW','PRS','RFR','OCM','OCS','TCT','VCM','PPQ','SIA']

# Generate the latin hypercube samples with uniform distributions
unif_sample = lhs(len(keys),n_samples)

# To hold the transformed variables
dist_sample = np.zeros_like(unif_sample)

# For each variable, transform with the inverse of the CDF (inv(CDF)=ppf)
for i,key in enumerate(keys):
    dist_sample[:,i] = distributions[key].ppf(unif_sample[:,i])

# Convert to Pandas dataframe, append column headers, output as csv
df = pd.DataFrame(dist_sample)
df.to_csv('lhs_samples.csv',header=keys,index=True)

# Plot a histogram of each variable
plot = True
if plot:
    import matplotlib.pyplot as plt
    fig,axs = plt.subplots(len(keys),1)
    fig.set_size_inches(6,15)
    fig.subplots_adjust(hspace=0.45)
    for i,key in enumerate(keys):
        axs[i].hist(dist_sample[:,i],20,normed=True,histtype='step')
        axs[i].set_ylabel(key)
    fig.savefig('parameter_histograms.pdf')
        

    










