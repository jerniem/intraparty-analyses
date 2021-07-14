import pandas as pd

csc = 1

if csc == 1:
    pathroot = '/scratch/project_2001488/simolasa/remote/'
else:
    pathroot = '/Users/Salla/Dropbox (Aalto)/speech-polatization/code/remote/parliamentary-speech/'

input = pathroot + 'build/input/'
output = input
file1 = 'ministers.csv'
file2 =	'minister-gender.csv'

ministers = pd.read_csv(input+file1, delimiter = '|', lineterminator = "\n", encoding = "utf-8")
gender = pd.read_csv(input+file2, delimiter = '|', lineterminator = "\n", encoding = "utf-8")

mingen = pd.merge(ministers, gender, how = 'outer', on = ['name'])
mingen.to_csv(output + 'ministers-with-genders.csv', sep = "|", line_terminator = "\n", encoding = "utf-8", index = False)

