pip install xlrd
pip install openpyxl
import pandas as pd
import numpy as np
# from os import chdir, getcwd
# wd=getcwd
path = "/users/raychandonnet/Dropbox (Personal)/Merrimack College - MS in Data Science/DSE5002/Python Project/"
cost_of_living=pd.read_csv(path + "cost_of_living.csv")
print(cost_of_living.head())
# Step 1 - Break the City up - requires a lot of cleaning because city and country are in the same field separated by
# a comma, and US cities also have the state in form city, st, country.  I want to break these up into separate columns
# to link to the country code data, then pull in job info for those city / country combos
# First, split the city into three separate fields
cost_of_living[['City','State','Country']]=cost_of_living['City'].str.split(pat=",",n=2,expand=True)
# This leaves the city state and country correct for US cities, but has the country in the city column for
# non-US cities and "None" for country, so we have to fix that  It's two steps:
# First, repalce all the "None" in Country column with the State value which is where the Country is
# Then eliminate the dups by putting "None" in the State field for alkl those.  So we basically just swapped values
# to get the country in the right place
cost_of_living['Country']=cost_of_living['Country'].fillna(cost_of_living['State']) # Puts the state value in country where NA
cost_of_living['State']=np.where(cost_of_living['State']==cost_of_living['Country'],None,cost_of_living['State'])
# It took me more time than I care to admit to realize that my states and countries had padded whitespace and so weren't 
# matching when I tried to merge in the country code data!!! Sigh....using the strip method fixes that
cost_of_living['Country']=cost_of_living['Country'].str.strip()
cost_of_living['State']=cost_of_living['State'].str.strip()
# This leaves us with City, State and Country, with country spelled out
print(cost_of_living.head())
# Now I can merge in the country codes from that file into my table.  This will let me connect to data in the salary
# and jobs files once I do some stuff with hat data
countrycodes=pd.read_excel(path+"country_codes.xlsx")
cost_of_living=pd.merge(left=cost_of_living,right=countrycodes,how='left',on='Country')
