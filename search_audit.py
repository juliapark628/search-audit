import csv
from collections import Counter
import numpy as np
import os
import pandas as pd
import random
import re
import time
import tldextract
import WebSearcher as ws


locs = {
		'Pensacola': 'Pensacola,Florida,United States',
        'Tallahassee': 'Tallahassee,Florida,United States',
        'Jacksonville' : 'Jacksonville,Florida,United States',
        'Honolulu' : '96813,Hawaii,United States', # honolulu
        'Oahu' : '96792,Hawaii,United States', # rural Oahu
		}

'''
locs = {
	'Bronx': '10456,New York,United States',
	'Poughkeepsie': '12601,New York,United States',
	'Elmira': '14901,New York,United States',
	'Catskill': '12414,New York,United States',
	'Mount Vernon': '10550,New York,United States'
		}

locs = {
	'Sandpoint': '83864,Idaho,United States',
	'Saint Maries': '83861,Idaho,United States',
	'Deary': '83823,Idaho,United States',
	'Council': '83612,Idaho,United States',
	'Emmett': '83617,Idaho,United States',
	'Challis': '83226,Idaho,United States',
	'Stanley': '83278,Idaho,United States',
	'Saint Anthony': '83445,Idaho,United States',
	'Rupert': '83350,Idaho,United States',
	'Preston': '83263,Idaho,United States',
	'Buffalo': '14215,New York,United States',
	'Albany': '12203,New York,United States',
	'Rochester': '14621,New York,United States',
	'Brentwood': '11717,New York,United States',
	'Queens': '11368,New York,United States'
	}


'''

# csv_files = ['eviction.csv', 'domestic_violence.csv', 'flood_contractor.csv', 'debt_collection.csv']
csv_files = ['eviction.csv', 'domestic_violence.csv']


for csv_file in csv_files:
	with open(csv_file) as f:
		reader = csv.reader(f)
		queries = list(reader)

	for city, loc in locs.items():

		state = loc.split(',')[1]
		df = pd.DataFrame()

		for idx, q in enumerate(queries):
			q[0] = re.sub(r"\[state\]", state, q[0])
			q[0] = re.sub(r"\[city\]", city, q[0])

			# continue to run query until successful
			while(True):
				se = ws.SearchEngine()
				se.search(q[0], location=loc)
				if (vars(se)['response'].status_code == 200):
					break
				else:
					time.sleep(200)


			se.parse_results()
			q_df = pd.DataFrame(se.results)
			# extract suffix and domain name
			
			try:
				q_df['url'] = q_df['url'].replace(np.nan, '', regex=True)
			except KeyError:
				continue

			try:
				q_df['location'] = loc
			except KeyError:
				continue

			try:
				q_df['urlsuffix'] = q_df.apply(lambda x: tldextract.extract(x['url']).suffix, axis = 1)
			except KeyError:
				continue

			try:
				q_df['urldomain'] = q_df.apply(lambda x: tldextract.extract(x['url']).domain, axis = 1)
			except KeyError:
				continue

			df = df.append(q_df)

			# t = random.randrange(60, 150)
			# time.sleep(t)
			# sleep ~ 60 seconds between each query to prevent time out
			time.sleep(60)
			q[0] = re.sub(state, r"[state]", q[0])
			q[0] = re.sub(city, r"[city]", q[0])

		df_location = 'data/' + city + '_result_' + csv_file.split('.')[0]
		export_csv = df.to_csv(df_location, index = None, header=True) 

