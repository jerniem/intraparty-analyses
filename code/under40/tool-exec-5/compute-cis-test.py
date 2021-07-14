'''
- Read in estimates from subsamples
- Use the distribution of subsample estimates to create confidence intervals
with (default) 80% nominal coverage
- Save CI lb, ub to csv
- Plot the main estimate and confidence intervals

Example usage: python compute-cis.py "govparty" 0 0 "c0" "Cadj"

Created Jan 2020 Salla Simola

'''
import pandas as pd
import numpy as np
import sys
import math
import statistics
##################################################################################

csc = 1

if csc == 1:
    pathroot = "/home/jernie"
else:
    pathroot = '/Users/jeremiasnieminen/Dropbox/local_speech/'

partyvar = sys.argv[1]
fake_indicator = int(sys.argv[2])
empirical = int(sys.argv[3])
covariates = sys.argv[4]
Cpar = sys.argv[5]

print("Party variable: %s, fake = %d, empirical: %d"%(partyvar, fake_indicator, empirical))

outputpath = pathroot + 'analysis/output/' + partyvar + '/'
temppath   = pathroot + 'analysis/temp/' + partyvar + '/'

suffix = '_randlabels' if fake_indicator == 1 else ""
suffix = suffix + "_Cadj" if Cpar == "Cadj" else suffix
suffix = suffix + "_" + covariates
filenamestart = 'partisanship-' + partyvar + suffix 

if empirical == 1:
    inputpath =	pathroot + 'analysis/temp/' + partyvar + '/empirical/'
    filename = 'empirical-partisanship-left' + suffix + '.csv'
else:
    inputpath = pathroot + 'analysis/temp/' + partyvar + '/inference/'
    filename = "partisanship-" + partyvar + suffix + ".csv"

print("Infile: ", filename)

#hq = 90 # high quantile
#lq = 11 # low quantile
hq = 89
lq = 10

partyvar = "randlabel" if fake_indicator == 1 else partyvar

################################################################################
def checkN(df):

    mlist = []
    for value in df.columns:
        if df[value].iloc[0] < 30:
            print("Too few MPs, %s = %d: %d"%(partyvar, value, df[value].iloc[0]))
            mlist.append(False)
        else:
            mlist.append(True)
    # all() evaluates whether all list items == True
    return all(mlist)

################################################################################

print(outputpath+filename)
estimates = pd.read_csv(outputpath + filename, delimiter = ',', lineterminator = "\n", encoding = "utf-8")

speakers = pd.read_csv(temppath + '/speaker_metadata_bipartisan_mu.csv', delimiter = '|', lineterminator = "\n", encoding = "utf-8")

speakersnon0 = speakers[(speakers.mu.isnull() == False)]
assert len(speakers) != len(speakersnon0)

yearly = speakersnon0.groupby('year')[partyvar].value_counts().unstack().fillna(0)

cis = []
for year in range(1907, 2018 + 1):
#for year in range(2015, 2016):
#for year in range(1908, 1909):

    print("Year: ", year)

    if partyvar == "govparty" and year < 1917:
        print("No government data, output nan")
        cis.append([year, np.nan, np.nan, np.nan])
        continue

    elif year == 1915 or year == 1916:
        print("Parliament didn't gather, output nan")
        cis.append([year, np.nan, np.nan, np.nan])
        continue

    else:
        thisyear = yearly[(yearly.index == year)]

        ck = checkN(thisyear)

        if ck == False:
            print("Making nan append for year ", year)   
            cis.append([year, np.nan, np.nan, np.nan])
            continue

        # Main estimate
        estimate = estimates.pi[estimates.session == year].iloc[0]
        
        if estimate == 0.5:
            print("Year: %d, Estimate = 0.5, output 0.5 for lb and ub"%(year))
            lb = 0.5
            hb = 0.5
            cis.append([year, 0.5, 0.5, 0.5])
            continue

        # Initialize list
        subsample_pis = []

        # Collect all subsample estimates for pi_{year = 1907} etc.
        for i in range(1,100 + 1):
            try:
                df = pd.read_csv(inputpath + filenamestart + '-' + str(i) + '.csv', delimiter = ',', lineterminator = "\n", encoding = "utf-8")
            except:
                print("Subsample %d"%(i))

