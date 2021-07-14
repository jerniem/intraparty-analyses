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
    pathroot = "/home/jernie/"
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
if empirical == 1:
    suffix = suffix
else:
    suffix = suffix + "_" + covariates

if empirical == 1:
    filenamestart = 'partisanship-' + partyvar + suffix

    inputpath =	pathroot + 'analysis/temp/' + partyvar + '/empirical/'
    filename = 'empirical-partisanship-left' + suffix + '.csv'
else:
    filenamestart = 'partisanship-' + partyvar + suffix

    inputpath = pathroot + 'analysis/temp/' + partyvar + '/inference/'
    filename = "partisanship-" + partyvar + suffix + ".csv"

print("Infile: ", filename)

#hq = 90 # high quantile
#lq = 11 # low quantile
hq = 89
lq = 10

partyvar = "randlabel" if fake_indicator == 1 else partyvar

################################################################################
def checkN(df, n=30):

    mlist = []
    for value in df.columns:
        if df[value].iloc[0] < n:
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

        # ck = checkN(thisyear, 3)
        ck = checkN(thisyear, 15)

        if ck == False:
            print("Making nan append for year ", year)   
            cis.append([year, np.nan, np.nan, np.nan])
            continue

        # Main estimate
        try:
            estimate = estimates.pi[estimates.session == year].iloc[0]
        except:
            print("Making nan append for year ", year)
            cis.append([year, np.nan, np.nan, np.nan])
            continue

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
            #print(inputpath + filenamestart + '-' + str(i) + '.csv')
            if empirical == 1:
                df = pd.read_csv(inputpath + filenamestart + '-' + str(i) + '-yearsonly.csv', delimiter = ',', lineterminator = "\n", encoding = "utf-8")

            else:
                df = pd.read_csv(inputpath + filenamestart + '-' + str(i) + '.csv', delimiter = ',', lineterminator = "\n", encoding = "utf-8")

            #print("Reading file from ", inputpath + filenamestart + '-' + str(i) + '.csv')
        
            #nspeakers_all = df.all_speakers[df.session == year].iloc[0]
            nspeakers_all = np.sum(df.all_speakers.tolist())
            #sub_pi =  df.pi[df.session == year].iloc[0]
            sub_pi =  df.pi[df.session == year]
            #print(sub_pi)
            sub_pi = sub_pi.iloc[0]

            #sub_n =  df.n[df.session == year].iloc[0]

            sub_n = np.sum(df.n.tolist())

            #print("Sum: ", sub_n)
            #print("Sum all: ", nspeakers_all)
            subsample_pis.append(sub_pi)

        #if year < 1945 and year >1939:
        #    print(sorted(subsample_pis))

        # zip transposes subsample_pis, map(sum, ) applies sum function to
        # each list
        #totals = list(map(sum, zip(*subsample_pis)))
        sub_mean = np.mean(subsample_pis)

       	#print(sub_mean)
        #print(sub_n)
        print("Min: ", min(subsample_pis), "Median: ", statistics.median(subsample_pis), 
            "Mean: ", sub_mean, "Max: ", max(subsample_pis))
        print("Year %d mean: %f"%(year, sub_mean))

        # Some estimates are exactly 0.5 and this results in log(0).
        # Solution now: just add these values as min q.
        
        # gets negative values when pi_k below mean(pi_k), positive values otherwise
        q = [math.sqrt(sub_n) * (math.log(pi_k - 0.5) - math.log(sub_mean - 0.5)) for pi_k in subsample_pis if pi_k != 0.5]

        #example_q = math.sqrt(20) * (math.log(0.53 - 0.5) - math.log(0.52 - 0.5))
        #print("example q: ", example_q)
        pointfives = 100 - len(q)
        print("Nr subsample estimates neq 0.5", len(q))
        print("Nr subsample estimates = 0.5", pointfives)
        curmin = min(q)        
        adj = [curmin - 0.01] * pointfives

        #print("subsample_pis: ", sorted(subsample_pis))
        q = adj + q
       	#print("adj q: ", sorted(q))
        #print("adjq: ", sorted(q))

        q = sorted(q)
        print("Nr subsample estimates after adjustment", len(q))
        
        q_up = q[hq]
        #q_up  = np.percentile(q, hq)
        med = np.percentile(q, 50)
        #med1 = statistics.median(q)
        #print(med, med1)
        #median = 0.5 + math.exp(math.log(estimate - 0.5) - med/math.sqrt(nspeakers_all))
        #print(median)
        #q_low = np.percentile(q, lq)
        q_low = q[lq]

        # lower bound:  Divide estimates distance from .5 by quantile 90's distance from .5 
        # higher bound: Divide estimates distance from .5 by quantile 10's distance from .5 (smaller nr than the divider above)
        # if q_up is negative then lb is above the estimate :/
        lb = 0.5 + math.exp(math.log(estimate - 0.5) - q_up/math.sqrt(nspeakers_all))
        hb = 0.5 + math.exp(math.log(estimate - 0.5) - q_low/math.sqrt(nspeakers_all))
        #print(year, estimate, q_up, q_low, hb, lb)
        print(year, estimate, hb, lb)
        cis.append([year, estimate, lb, hb])

outdf = pd.DataFrame(cis, columns = ["year", "estimate", "lb", "hb"])
outdf.to_csv(outputpath + filename.split('.csv')[0] + '-cis.csv', index = False)
print("Output written to ", outputpath + filename.split('.csv')[0] + '-cis.csv')
