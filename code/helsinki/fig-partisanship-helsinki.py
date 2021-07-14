'''
- Plot the main estimate and confidence intervals
Created Jan 2020 Salla Simola
'''
import pandas as pd
import numpy as np
import math
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pylab

##################################################################################
csc = 1
include_random = 1
empirical = 0

if csc == 1:
    pathroot = '/home/jernie/'
else:
    pathroot = '/Users/jeremiasnieminen/Dropbox/local_speech/analysis/code/helsinki/'

partyvar = "helsinki"
print("Party variable: %s"%(partyvar))

inputpath = pathroot + 'analysis/output/' + partyvar + '/'
outputpath = pathroot + 'analysis/output/' + partyvar + '/'

if empirical == 1:
    infilename1 = "empirical-partisanship-" + partyvar + "_Cadj-cis.csv"
    infilename2 = "empirical-partisanship-" + partyvar + "_randlabels_Cadj-cis.csv"
else:
    infilename1 = 'partisanship-helsinki_Cadj_c0_partyf-cis.csv'
    infilename2 = 'partisanship-helsinki_randlabels_Cadj_c0_partyf-cis.csv'

if include_random == 1:
    outfilename = infilename1.split(".csv")[0] + "-w_random"
else:
    outfilename = infilename1.split(".csv")[0]

###############################################################################
def round_nearest(x, a):
    return round(x / a) * a
################################################################################
df1 = pd.read_csv(inputpath + infilename1, delimiter = ',', lineterminator = "\n")
if include_random == 1:
    df2 = pd.read_csv(inputpath + infilename2, delimiter = ',', lineterminator = "\n")

#df1 = pd.read_csv(inputpath + "cis-" + partyvar + ".csv", delimiter = ',', lineterminator = "\n")
#df2 = pd.read_csv(inputpath + "cis-" + partyvar + "_randlabels.csv", delimiter = ',', lineterminator = "\n")
print(df1.columns)
years = df1.year

# Construct lower and upper error for errorbar function
#df["lerror"] = df.estimate - df.lb
#df["herror"] = df.hb - df.estimate
# Error bars
#plt.errorbar(df.year, df.estimate, yerr=[df.lerror, df.herror])
#plt.show()
#plt.close()
if include_random == 1:
    maxpi = max(np.nanmax(df1.hb), np.nanmax(df2.hb))
else:
    maxpi = np.nanmax(df1.hb)

#steps = (maxpi-0.5)/10
steps = round_nearest((maxpi-0.5)/10, 0.0005)

# Shaded confidence intervals
plt.style.use('seaborn-whitegrid')
plt.plot(years, df1.estimate, color = 'saddlebrown', label = 'Real')
plt.fill_between(years, df1.lb, df1.hb, color = 'peru')
if include_random == 1:
    plt.plot(years, df2.estimate, linestyle = 'dashed', color = 'saddlebrown', label = 'Random')
    plt.fill_between(years, df2.lb, df2.hb, color = 'sandybrown')
pylab.legend(loc='upper left')
plt.xticks(np.arange(1910, 2030, step = 10))
#plt.yticks(np.arange(0.4995, maxpi + 0.0001, step = steps))
plt.ylabel('Average partisanship of a phrase')

plt.savefig(outputpath +  outfilename)
