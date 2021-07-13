'''
Create speaker key to build/output
Created August 1, 2019 - Salla Simola
'''
import pandas as pd

csc = 1

if csc == 1:
    pathroot = '/scratch/project_2001488/simolasa/remote/'
else:
    pathroot = '/Users/Salla/Dropbox (Aalto)/speech-polatization/code/remote/parliamentary-speech/'

path = pathroot + 'build/output/'
df = pd.read_csv(path + 'mps-ministers.csv', sep='|', lineterminator = '\n', encoding='utf-8')
df = df[["full_name", "speaker_id"]]
key = df.drop_duplicates()
key.to_csv(path + 'key-speaker-id.csv', sep='|', line_terminator = '\n', encoding='utf-8', index = False)
