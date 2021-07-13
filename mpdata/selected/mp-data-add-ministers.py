'''
- Add minister data file to MP data
- Add row if minister year not in data, complement row if minister-year in data
- Manually identify ambiguous matches to avoid speaker year duplicates
(will appear if speaker has multiple entries for a year)
- Keep end of year situation

input:
mp-data.csv
ministers-with-genders.csv
party_key.csv

minister term:
spring if endyear
fall if startyear
full otherwise

EXCEPTIONS
To avoid double match

1. Aarne Johannes Koskinen vs. Hannu Erkki Johannes Koskinen):

Johannes Koskinen
->
fns = "Johannes, Hannu Erkki Johannes"
ln = "Koskinen"

2. Paavo Viktor Vihtori Vesterinen vs. Vihtori Vesterinen
Vihtori Vesterinen
->
id = 2201

'''

import pandas as pd
import re, csv, sys
from collections import Counter
import numpy as np

csc = 0
train = 0 # set training = 0 if not manually inputting ministers

if csc == 1:
    pathroot = '/home/jernie'
else:
    pathroot = '/Users/jeremiasnieminen/Dropbox/local_speech/mpdata/selected/'

path = pathroot + 'build/input/'
outdir = pathroot + 'build/output/'


###############################################################################
# Functions:
def getId(minister_name, pairs, training):
    '''
    Return id of a minister if he or she already has a record in MP data
    Ask for manual input if exact match not found
    '''
    matches = []
    lastnamematches = []
    minister_names = minister_name.split()
    minister_last_name = minister_names[-1].strip()

    # Hardcode one tricky exception (double match)
    if minister_name == 'Vihtori Vesterinen':
        return 2201

    # MP register has a more comprehensive record of first names than minister data.
    # Thus, match if all minister data names found in MP register entry name
    for pair in pairs:
        matching_names = 0

        mpnames = pair[1].split()
        mplastname = mpnames[-1].strip()

        if minister_last_name == mplastname:
            lastnamematches.append(pair)

        for name in minister_names:
            # If name in mp entry, go on
            if name.strip() in mpnames:
                matching_names += 1
            # If name not in mp entry, break out of loop
            else:
                continue

        # If all names found in namedictentry, append to matches list
        if matching_names == len(minister_names):
            matches.append(pair[0])

    if len(matches) > 1:
        print("Non-unique match:", minister_names, matches)

    if len(matches) == 1:
        return matches[0]

    else:
        if training == 1:
            if lastnamematches:
                print("\nMinister name: ", minister_name)
                for ind, pair in enumerate(lastnamematches):
                    print("Candidate %d: %s"%(ind, pair))

                try:
                    choice = int(input("\nCandidate nr of a matching MP? Input '99' if no match  "))
                except:
                    choice = int(input("\nCandidate nr of a matching MP? Input '99' if no match  "))

                if choice > len(lastnamematches):
                    print("Returning empty id")
                    return ''

                else:
                    mpair = lastnamematches[choice]
                    print(minister_name, "matched to ", mpair[1])
                    return mpair[0]
            else:
                print("No match for ", minister_name)
                return ''

        else:
            #print("No match for ", minister_name)
            return ''

def replacePartyName(party):
    '''
    To keep the party records consistent, replace party always with a
    consistent form of party's name.
    '''
    keyfile = pathroot + 'build/input/party_key.csv'

    key = pd.read_csv(keyfile, delimiter = '|', lineterminator = "\n", encoding = "utf-8")

    key = key[key.party == party]
    consistent_party_name = key["party2"].iloc[0]
    return consistent_party_name

def toCleanDf(list):
    '''
    input a list of lists.
    output: a df with unique row per minister-year
    '''
    df = pd.DataFrame(list, columns = ["year", "minister_term", "speaker_id", "full_name", "last_name", "first_names", "party", "female", "dates", "minister_title"])

    # Create a new column with all ministerships collapsed to minister-year level
    df['titles'] = df.groupby(['full_name', 'year'])['minister_title'].transform(lambda col: ', '.join(col))
    df['titles'] = df['titles'].apply(lambda x: keepUnique(x))
    df['minister_terms'] = df.groupby(['full_name', 'year'])['minister_term'].transform(lambda col: ', '.join(col))
    df['minister_terms'] = df['minister_terms'].apply(lambda x: keepUnique(x))

    # Set value for term (this is super non-elegant ad hoc):
    df['term'] = ""
    for i in range(len(df)):
        terms = df["minister_terms"][i]
        # Order important, do not change
        if terms.find("full") != -1 or terms.find("fall, spring") != -1 or terms.find("spring, fall") != -1:
            df["term"].iloc[i] = "full"
        elif terms.find("fall") != -1:
            df["term"].iloc[i] = "fall"
        elif terms.find("spring") != -1:
            df["term"].iloc[i] = "spring"
    df = df.drop(["minister_title", "minister_term"], axis = 1)
    df = df.drop_duplicates()
    return df

def keepUnique(value):
    vals = str(value).split(',')
    vals = [v.strip() for v in vals if v != " " and v != ""]
    vs = list(set(vals))
    return ', '.join(vs)

###############################################################################

df = pd.read_csv(path + 'ministers-with-genders.csv', delimiter = '|', lineterminator = "\n", encoding = "utf-8")
mpdf = pd.read_csv(outdir + 'mp-data.csv', delimiter = '|', lineterminator = "\n", encoding = "utf-8")

mpdf["year"] = mpdf["year"].apply(lambda x: int(x))
mpdf["speaker_id"] = mpdf["speaker_id"].apply(lambda x: int(x))

# Input all unique MP id, full name pairs for later usage in the getNameVersions program
pairs = [[mpdf["speaker_id"].iloc[i], mpdf["full_name"].iloc[i]] for i in range(len(mpdf))]
pairs = np.array(pairs)
allnames = np.unique(pairs, axis = 0)
print(allnames)

print("Names in total:", len(allnames))

nonmatched = []
appendable = []
mergeable = []
newids = {}

# Loop through minister data: get firstname, lastname, startyear, endyear
# Data is on post level - there can be multiple entries for a minister
for i in range(len(df)):

    # Name format: 'Ahde, Matti Allan'
    if df["name"].iloc[i] == "Koskinen, Hannu Erkki Johannes":
        fns = "Johannes, Hannu Erkki Johannes"
        ln = "Koskinen"

    else:
        # Separate last name and first names
        names = df["name"].iloc[i].split(',')
        fns = names[1].strip()

        # Remove any parentheses
        fns = re.sub(r'[\(\)]', '', fns)

        # Last name
        ln = names[0].strip()

    fullname = ' '.join([fns, ln])

    dates = df["in_office"].iloc[i].split('-')
    startyear = dates[0].split('.')[-1].strip()
    endyear = dates[1].split('.')[-1].strip()

    if endyear != '':
        endmonth = int(dates[1].split('.')[1])
    else:
        endmonth = 12

    if endyear == '':
        endyear = '2020'

    # getId returns id of a minister already in party data, '' otherwise
    id = getId(fullname, allnames, train)

    # Replace party with coherent form of party name
    party = replacePartyName(df["party"].iloc[i])

    if id == "":
        nonmatched.append(fullname)

        # Create an id for minister with no record in MP data
        # id = currentmax +1

        # Check if name was added to newids dictionary
        if newids.get(fullname) is None:
            if newids:
                currentmax = max(newids.values())
            else:
                print("You should see this print only once")
                currentmax = max(set(mpdf.speaker_id))

            id = currentmax + 1

            # Add mpname, id pair to newids dictionary
            newids[fullname] = id
        else:
            id = newids.get(fullname)

    for year in range(int(startyear), int(endyear) + 1):
        if year == int(endyear):
            minister_term = "spring"
        elif year == int(startyear):
            minister_term = "fall"
        else:
            minister_term = "full"

        entry = [int(year), minister_term, int(id), fullname, ln, fns, party, df["female"].iloc[i], df["in_office"].iloc[i], df["title"].iloc[i]]

        # Add new ids to appendable list
        if newids.get(fullname):
        #if id > max(set(mpdf.speaker_id)):
            appendable.append(entry)
        else:
            mergeable.append(entry)

# toCleanDf converts list of lists to a dataframe and keeps one row per id
adf     = toCleanDf(appendable)
mergedf = toCleanDf(mergeable)

# Append those ministers that were not found in MP register
print("New ministers:", len(set(adf.speaker_id)))

for s in sorted(list(set(adf.full_name))):
    print(s)

mpdf = mpdf.append(adf, sort = True, ignore_index = True)

# Merge mergeable:
print("Ministers already in MP data:", len(set(mergedf.speaker_id)))
mpdf2 = pd.merge(mpdf, mergedf, how = 'outer', on = ['year', 'speaker_id'])

# Retain values (name, etc) from mpdf dataset except when they are missing
mpdf2['minister_term'] = mpdf2['minister_terms_x'].fillna(mpdf2['minister_terms_y'])
mpdf2['first_names'] = mpdf2['first_names_x'].fillna(mpdf2['first_names_y'])
mpdf2['full_name'] = mpdf2['full_name_x'].fillna(mpdf2['full_name_y'])
mpdf2['last_name'] = mpdf2['last_name_x'].fillna(mpdf2['last_name_y'])
mpdf2['party'] = mpdf2['party_x'].fillna(mpdf2['party_y'])
mpdf2['titles'] = mpdf2['titles_x'].fillna(mpdf2['titles_y'])
mpdf2['term'] = mpdf2['term_x'].fillna(mpdf2['term_y'])
mpdf2['dates'] = mpdf2['dates_x'].fillna(mpdf2['dates_y'])
mpdf2['female'] = mpdf2['female_x'].fillna(mpdf2['female_y'])

mpdf2 = mpdf2.drop(['minister_terms_x', 'minister_terms_y',\
    'first_names_x', 'first_names_y', 'full_name_x', 'full_name_y',\
    'last_name_x', 'last_name_y', 'party_x', 'party_y',\
    'titles_x', 'titles_y', 'term_x', 'term_y', 'dates_x', \
    'dates_y', 'female_y', 'female_x'], axis = 1)

# education lisätty
# profession lisätty
# birthday lisätty
# birthyear lisätty
new_order = ["year", "term", "minister_term",
    "speaker_id", "full_name", "last_name", "first_names", "party",
    "dates", "titles", "female", "birthplace", "electroral_districts", "first_district", "education", "profession", "birthday", "birthyear"]

mpdf2 = mpdf2[new_order]
mpdf2 = mpdf2.drop_duplicates()

# Last, drop speaker_id, year duplicates
# They appear if electroral district or party changes during a year
# Keep the end of the year situation for party information

print("Data length before dropping speaker-year duplicates:", len(mpdf2))

# Extract startdate and convert to pd.datetime for sorting
mpdf2["startdate"]= mpdf2.dates.apply(lambda x: pd.to_datetime(str(x).split('-')[0]))
mpdf2 = mpdf2.sort_values(by = ['speaker_id', 'year', 'startdate'])

# Combine all active terms before dropping duplicates
mpdf2['term'] = mpdf2.groupby(['speaker_id', 'year'])['term'].transform(lambda col: ', '.join(col))
mpdf2['dates'] = mpdf2.groupby(['speaker_id', 'year'])['dates'].transform(lambda col: ', '.join(col))

# Sort, print and drop duplicates.
# Note that this way of dropping duplicates loses the background data in MP
# register
mpdf2 = mpdf2.sort_values(by = ['speaker_id', 'year', 'startdate'])

# List duplos
duplos = mpdf2[mpdf2.duplicated(subset = ['speaker_id', 'year'], keep = 'last')]
print(duplos[['full_name']])

mpdf2 = mpdf2.drop_duplicates(subset = ['speaker_id', 'year'], keep = 'last')
mpdf2 = mpdf2.drop(['startdate'], axis = 1)
print("Data length after dropping speaker-year duplicates:", len(mpdf2))

# Propagate non-na value of first_district for speaker
mpdf2['first_district'] = mpdf2.groupby('speaker_id')['first_district'].transform('first')

mpdf2["female"] = mpdf2["female"].apply(lambda x : int(x))
mpdf2["term"] = mpdf2["term"].apply(lambda x : keepUnique(x))
mpdf2.to_csv(outdir + 'mps-ministers-trained.csv', sep ='|', index = False, encoding = 'utf-8')
