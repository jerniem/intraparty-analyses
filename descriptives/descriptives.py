'''
Descriptives: 
* share:

*** female
*** district
*** UNDER 40 YEAR OLD
*** HIGHER EDUCATION
*** WHITECOLLAR 


- out of active MPs
- out of speakers
- out of speeches
input:
- analysis/input/speaker_metadata_bipartisan.csv (party labels, female, district, govparty, whether spoke)
- build/output/speeches/linked/speeches-year.csv (nr speeches)
output:
'''

import pandas as pd
import sys
import time
import numpy as np

csc = 1

# Options
if csc == 1:
    pathroot = '/home/jernie/'
else:
    pathroot = 'C:/Users/jernie/Dropbox/local_speech/analysis'

inputpath = pathroot + 'analysis/temp/uusimaa/'
outputpath = pathroot + 'analysis/output/'
speechpath = pathroot + "build/output/speeches/linked/"

##################################################################################
# Read data:
start = time.time()
metadata = pd.read_csv(inputpath + "speaker_metadata_bipartisan_mu.csv", \
    delimiter = '|', lineterminator = "\n", encoding = "utf-8")

#print(metadata[(metadata.speaker_id ==  2325)])
print("Reading metadata took %d seconds"%(time.time()-start))

# Edit metadata: Fix wrong party labels
#exceptions = pd.read_excel(pathroot + "build/output/speaker-exceptions.xlsx")
#metadata = metadata.merge(exceptions, how = 'left', on = ['year', 'speaker_id'])
#party = metadata.party_y.fillna(value = metadata.party_x) 
#metadata["party"] = party

#districts = list(set(metadata.dialect.values))
#y = ["year"]
#district_df = pd.DataFrame(columns = y + districts)
#print(district_df.columns)

years = list(set(metadata.year.values))

speakers = metadata[(metadata.mu.isna() == False)]
print("MPs: ", len(metadata))
print("Speakers: ", len(speakers))

print(metadata.columns)

femalespeech = []
under40speech = []
uusimaaspeech = []
educationspeech = []
whitecollarspeech = []
firsttermspeeech = []

def getShare(variable, frame, first_only = 1):
    dff = frame[['year', variable, 'speaker_id']].groupby(['year', variable]).count()
    dff = dff.add_suffix('_count').reset_index()
    totals = dff[['year', 'speaker_id_count']].groupby(['year']).transform('sum')
    dff['totals'] = totals
    dff['share'] = dff.speaker_id_count/dff.totals

    if first_only == 1:
        dff = dff[(dff[variable] == 1)].reset_index(drop = True)

    return dff

#district_df = pd.DataFrame(columns = districts)
#dmps_df = pd.DataFrame(columns = ["mp"+d for d in districts])
#dspeakers_df = pd.DataFrame(columns = ["sp"+d for d in districts])

#print(district_df)

# speeches by year:
for year in sorted(years):

    if year == 1915 or year == 1916:
        continue
    else:

        df = pd.read_csv(speechpath + "speeches-" + str(year) + ".csv", \
            delimiter = '|', lineterminator = "\n", encoding = "utf-8")
        #print(df.speech_raw[(df.speaker_id ==  2325)])

        yspeakers = speakers[(speakers.year == year)]
        ymps = metadata[(metadata.year == year)]

        # Remove speeches by chair and speeches missing speaker_id 
        df = df[(df.speaker_id.isna() == False) & (df.speaker_id != 99999)]

        #print(metadata[(metadata.year == year)])

        # merge metadata to speeches
        mdf = df.merge(metadata, on = ['year', 'speaker_id'], how = 'left')
        mdf = mdf[['year', 'id', 'speaker_id', 'female', 'uusimaa', 'under40', 'education', 'whitecollar', 'firstterm']]

        #print(mdf.head(20))
        #print(mdf.speaker_id.head(20))

        # Stats:
        fspeech = getShare("female", mdf)
        uspeech = getShare("uusimaa", mdf)
        yspeech = getShare("under40", mdf)
        hspeech = getShare("education", mdf)
        wspeech = getShare("whitecollar", mdf)
        ftspeech = getShare("firstterm", mdf)

        femalespeech.append([year, fspeech.share.iloc[0]])

        uusimaaspeech.append([year, uspeech.share.iloc[0]])

        under40speech.append([year, yspeech.share.iloc[0]])

        educationspeech.append([year, hspeech.share.iloc[0]])

        whitecollarspeech.append([year, wspeech.share.iloc[0]])

        firsttermspeech.append([year, ftspeech.share.iloc[0]])
       
         
f = lambda x: x if isinstance(x, str) else str(round(x, 3))

fspeech = pd.DataFrame(femalespeech, columns = ['year', 'share'])        
fspeech["fshare_speech"] = fspeech.share.apply(f)

uspeech = pd.DataFrame(uusimaaspeech, columns = ['year', 'share'])
uspeech["ushare_speech"] = uspeech.share.apply(f)

yspeech = pd.DataFrame(under40speech, columns = ['year', 'share'])
yspeech["yshare_speech"] = yspeech.share.apply(f)

hspeech = pd.DataFrame(educationspeech, columns = ['year', 'share'])
hspeech["hshare_speech"] = hspeech.share.apply(f)

wspeech = pd.DataFrame(whitecollarspeech, columns = ['year', 'share'])
wspeech["wshare_speech"] = wspeech.share.apply(f)

ftspeech = pd.DataFrame(firsttermspeech, columns = ['year', 'share'])
wspeech["ftshare_speech"] = ftspeech.share.apply(f)


mps_female = getShare("female", metadata)
mps_female["fshare_mps"] = mps_female.share.apply(f)
speakers_female = getShare("female", speakers)
speakers_female["fshare_speakers"] = speakers_female.share.apply(f)

mps_uusimaa = getShare("uusimaa", metadata)
mps_uusimaa["ushare_mps"] = mps_uusimaa.share.apply(f)
speakers_uusimaa = getShare("uusimaa", speakers)
speakers_uusimaa["ushare_speakers"] = speakers_uusimaa.share.apply(f)

mps_under40 = getShare("under40", metadata)
mps_under40["yshare_mps"] = mps_under40.share.apply(f)
speakers_under40 = getShare("under40", speakers)
speakers_under40["yshare_speakers"] = speakers_under40.share.apply(f)

mps_education = getShare("education", metadata)
mps_education["hshare_mps"] = mps_education.share.apply(f)
speakers_education = getShare("education", speakers)
speakers_education["hshare_speakers"] = speakers_education.share.apply(f)

mps_whitecollar = getShare("whitecollar", metadata)
mps_whitecollar["wshare_mps"] = mps_whitecollar.share.apply(f)
speakers_whitecollar = getShare("whitecollar", speakers)
speakers_whitecollar["wshare_speakers"] = speakers_whitecollar.share.apply(f)

mps_firstterm = getShare("firstterm", metadata)
mps_firstterm["ftshare_mps"] = mps_whitecollar.share.apply(f)
speakers_whitecollar = getShare("firstterm", speakers)
speakers_whitecollar["ftshare_speakers"] = speakers_whitecollar.share.apply(f)



# Joins:
female = fspeech.merge(mps_female, on = "year").merge(speakers_female, on = "year")
uusimaa = uspeech.merge(mps_uusimaa, on = "year").merge(speakers_uusimaa, on = "year")
under40 = yspeech.merge(mps_under40, on = "year").merge(speakers_under40, on = "year")
education = hspeech.merge(mps_education, on = "year").merge(speakers_education, on = "year")
whitecollar = wspeech.merge(mps_whitecollar, on = "year").merge(speakers_whitecollar, on = "year")
firstterm = ftspeech.merge(mps_firstterm, on = "year").merge(speakers_firstterm, on = "year")

all = female.merge(uusimaa, how = "left", on = "year").merge(under40,
                                                             how = "left", on = "year").merge(education, how = "left", on = "year").merge(whitecollar,
                                                                                              how = "left", on = "year").wspeech.merge(mps_whitecollar, on = "year").merge(speakers_whitecollar,
                                                                                                                                                             on = "year").fillna("-")
all = all[["year", "fshare_speech", "fshare_mps", "fshare_speakers", "ushare_speech", "ushare_mps", "ushare_speakers", "yshare_speech",
           "yshare_mps", "yshare_speakers", "hshare_speech", "hshare_mps", "hshare_speakers", "wshare_speech", "wshare_mps", "wshare_speakers",
           "ftshare_speech", "ftshare_mps", "ftshare_speakers"]]
print(all.head())
# other descriptives
all.to_csv(outputpath + 'descriptives-speakers.csv', index = False, encoding = 'utf-8')
