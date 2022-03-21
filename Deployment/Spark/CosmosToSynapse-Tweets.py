#!/usr/bin/env python
# coding: utf-8



# In[ ]:


import os
from azure.cosmos import CosmosClient, PartitionKey
from pyspark.sql.types import StructType, StructField, LongType, StringType, DateType, TimestampType,FloatType
from notebookutils import mssparkutils

import family
import json
import pandas as pd
from pandas import DataFrame

from datetime import date, timedelta 
from datetime import datetime as _datetime 

import numpy as np
import datetime, time
from dateutil.parser import parse
import re,string


# In[ ]:


%run "config"


# In[ ]:


# Connect to Cosmos
client = CosmosClient(COSMOS_URL, {'masterKey': COSMOS_KEY})
database = client.get_database_client(COSMOS_DATABASE_NAME)

tweet_container_client = database.get_container_client(container=COSMOS_CONTAINER_NAME)


# In[ ]:


last_inserted_ts = 0

jdbc_url = "jdbc:sqlserver://" + SYNAPSE_WORKSPACE_NAME + ".sql.azuresynapse.net:1433;database=" + DB_NAME + ";encrypt=true;trustServerCertificate=true;hostNameInCertificate=*.sql.azuresynapse.net;loginTimeout=30;"

jdbcDF = spark.read.format("jdbc").option("url", jdbc_url).option("query", "SELECT MAX(inserted_to_CosmosDB_ts) AS outp FROM dbo.Tweets").option("user", SQL_USERNAME).option("password", SQL_PASSWORD).load()

try:
    last_inserted_ts = jdbcDF.first()[0]
except: 
    last_inserted_ts = 0

if not(last_inserted_ts): # if the table is empty get back None
    last_inserted_ts = 0


# In[ ]:


now = datetime.datetime.now()
then = now - datetime.timedelta(days=2)
#span_ms = int(time.mktime(then.timetuple())) # only for testing. Disregard
dt_string = now.strftime("%Y-%m-%d %H:%M:%S")
LANGUAGE_CODES={"All":"","Afrikaans":"af","Arabic":"ar","Assamese":"as","Bangla":"bn","Bosnian(Latin)":"bs","Bulgarian":"bg","Cantonese(Traditional)":"yue","Catalan":"ca","Chinese Simplified":"zh-Hans","Chinese Traditional":"zh-Hant","Croatian":"hr","Czech":"cs","Dari":"prs","Danish":"da","Dutch":"nl","English":"en","Estonian":"et","Fijian":"fj","Filipino":"fil","Finnish":"fi","French":"fr","German":"de","Greek":"el","Gujarati":"gu","Haitian Creole":"ht","Hebrew":"he","Hindi":"hi","Hmong Daw":"mww","Hungarian":"hu","Icelandic":"is","Indonesian":"id","Irish":"ga","Italian":"it","Japanese":"ja","Kannada":"kn","Kazakh":"kk","Klingon":"tlh-Latn","Klingon(plqaD)":"tlh-Piqd","Korean":"ko","Kurdish(Central)":"ku","Kurdish(Northern)":"kmr","Latvian":"lv","Lithuanian":"lt","Malagasy":"mg","Malay":"ms","Malayalam":"ml","Maltese":"mt","Maori":"mi","Marathi":"mr","Norwegian":"nb","Odia":"or","Pashto":"ps","Persian":"fa","Polish":"pl","Portuguese(Brazil)":"pt-br","Portuguese(Portugal)":"pt-pt","Punjabi":"pa","Queretaro Otomi":"otq","Romanian":"ro","Russian":"ru","Samoan":"sm","Serbian(Cyrillic)":"sr-Cyrl","Serbian(Latin)":"sr-Latn","Slovak":"sk","Slovenian":"sl","Spanish":"es","Swahili":"sw","Swedish":"sv","Tahitian":"ty","Tamil":"ta","Telugu":"te","Thai":"th","Tongan":"to","Turkish":"tr","Ukrainian":"uk","Urdu":"ur","Vietnamese":"vi","Welsh":"cy","Yucatec Maya":"yua"}
LANGUAGE_CODES = {v: k for (k, v) in LANGUAGE_CODES.items()}


# In[ ]:


# TODO: This cell needs cleaning - lots of repeated accesses etc. Even datetime.now
query = "SELECT items.id,items.subtopic, items.full_text, items.user, items.userid, items.lang, items.place, items.retweet_count, items.favorite_count, items.entities, items.topics, items.translations, items.key_phrases, items.named_entities, items.sentiment, items.topickey, items.created_at, items.query, items.inserted_to_CosmosDB_ts, items.in_reply_to_status_id, items.in_reply_to_user_id, items.source from items where items.document_type = 'tweet' and items.inserted_to_CosmosDB_ts >= "  + str(last_inserted_ts) # Need to see which fields we want from cosmos. items.inserted_to_CosmosDB_ts used to be _ts - check the same?
lst, lstsearches, lsthashtags, lsthandles, lstmedia, lstKeyPhrases, lstEntities, lstSentiment,  lstTranslations, lstURLs = ([] for i in range(10))
lstEntityAnalysis=[]
for posts in tweet_container_client.query_items(query,enable_cross_partition_query=True ): # loop over list of json documents from cosmos, and fill in the lists - translations/keyphrases etc. Using lists to build data model
  # using conditionals as not every object has all the fields below.
  city = ''
  country = ''
  Language = ''
  id_str = posts["id"]

  for l in posts['translations']:
    lstTranslations.append([id_str, l, posts['translations'][l], _datetime.now()])
  for l in posts['named_entities']:
    for entity in posts['named_entities'][l]:
      if 'country_azuremaps' in entity.keys() and 'country_code_azuremaps' in entity.keys():
        lstEntities.append([id_str, entity['category'], entity['subcategory'], entity['text'],  LANGUAGE_CODES.get(l, "unknown"), float(entity['confidence_score']),entity["country_azuremaps"],entity["country_code_azuremaps"], _datetime.now() ])
      else:
        lstEntities.append([id_str, entity['category'], entity['subcategory'], entity['text'],  LANGUAGE_CODES.get(l, "unknown"), float(entity['confidence_score']),None,None, _datetime.now() ])
  Language = LANGUAGE_CODES.get(posts['lang'], 'Unknown')

  if posts['place'] is None:
    city = 'NA'
    country = 'NA'  
  else:
      city = posts["place"]['name']
      country = posts["place"]['country']
  for hashtag in posts['entities']['hashtags']:
    lsthashtags.append([id_str, hashtag['text'], _datetime.now()])
  for user_mention in posts['entities']['user_mentions']:
    lsthandles.append([id_str, user_mention['screen_name'], _datetime.now()])
  for urls in posts['entities']['urls']:
    lstURLs.append([id_str, urls['url'], urls['expanded_url'], urls['display_url'],  _datetime.now()])
  if 'media' in posts['entities']:
    for media in posts['entities']['media']:
      lstmedia.append([id_str, media['media_url'], _datetime.now()])
  if "sentiment" in posts.keys():
    lstSentiment.append([id_str, posts["sentiment"]["sentiment"], posts["sentiment"]["score"], _datetime.now()])
  adjustedCreatedDateTime = parse(posts["created_at"])+ timedelta(hours=3) 
  if "originalid" in posts.keys():
    idforlink=posts["originalid"]
  else:
    idforlink=id_str
  #append tweet
  lst.append([id_str, 
              posts["full_text"],
              posts["userid"],
	      posts["topickey"],
	      posts["subtopic"],
              city, country,               
              posts["retweet_count"], 
              posts["favorite_count"], Language,  
              0,
              posts["source"], posts["source"], 
              '', #factcheckURL, - for al jazeera, don't need
              'https://twitter.com/' + posts['user']['screen_name'] + '/status/' +idforlink,
              True if 'RT' in posts["full_text"] else False, #retweets
              "",#posts["possible_news"],
              posts["in_reply_to_status_id"] if posts["in_reply_to_status_id"] is not None else -1 ,
              posts["in_reply_to_user_id"] if posts["in_reply_to_user_id"] is not None else -1,
              adjustedCreatedDateTime,
              adjustedCreatedDateTime,
              _datetime.fromtimestamp(posts["inserted_to_CosmosDB_ts"]),
              posts["inserted_to_CosmosDB_ts"],
              _datetime.now(),
             ])


# In[ ]:


# Create Spark Dataframes
schema = StructType([StructField("id",StringType(),False),
  StructField("text",StringType(),True),
  StructField("userid",StringType(),True),
  StructField("topic",StringType(),True),
  StructField("subtopic",StringType(),True),
  StructField("city",StringType(),True),
  StructField("country",StringType(),True),
  StructField("retweets",LongType(),False),
  StructField("likes",LongType(),True),
  StructField("lang",StringType(),True),
  StructField("worthinessScore",LongType(),True),
  StructField("fullSource",StringType(),True),
  StructField("Source",StringType(),True),
  StructField("factCheckURL",StringType(),True),
  StructField("tweetURL",StringType(),True),
  StructField("isRetweet",StringType(),True),
  StructField("possibleNews",StringType(),True),
  StructField("replyToStatus",LongType(),True),
  StructField("replyToUser",LongType(),True),
  StructField("created_date",DateType(),True),
  StructField("created_datetime",TimestampType(),True),
  StructField("inserted_to_CosmosDB_datetime",TimestampType(),True),
  StructField("inserted_to_CosmosDB_ts",LongType(),True),
  StructField("inserted_datetime", TimestampType(), True)])
dftweets = sqlContext.createDataFrame(lst,schema)
dftweets.createOrReplaceTempView("dftweets")
schema = StructType([StructField("id",StringType(),False),
StructField("hashtags",StringType(),False),
StructField("created_datetime", TimestampType(), False)])
dfhashtags = spark.createDataFrame(lsthashtags, schema)
dfhashtags.createOrReplaceTempView("dfhashtags")
schema = StructType([StructField("id",StringType(),False),
StructField("handles",StringType(),False),
StructField("created_datetime", TimestampType(), False)])
dfhandles = spark.createDataFrame(lsthandles,schema)
dfhandles.createOrReplaceTempView("dfhandles")
schema = StructType([StructField("id",StringType(),False),
StructField("media",StringType(),False),
StructField("created_datetime", TimestampType(), False)])
dfmedia = spark.createDataFrame(lstmedia,schema)
dfmedia.createOrReplaceTempView("dfmedia")

schema = StructType([StructField("id",StringType(),False),
StructField("URL",StringType(),True),
StructField("Expanded_URL",StringType(),True),
StructField("display_URL",StringType(),True),
StructField("created_datetime", TimestampType(), True)])
dfURLs = spark.createDataFrame(lstURLs,schema)
dfURLs.createOrReplaceTempView("dfURLs")
schema = StructType([StructField("id",StringType(),False),
StructField("Language",StringType(),False),
StructField("Text",StringType(),False),
StructField("created_datetime", TimestampType(), True)])
dfTranslations = spark.createDataFrame(lstTranslations,schema)
dfTranslations.createOrReplaceTempView("dfTranslations")
schema = StructType([StructField("id",StringType(),False),
StructField("category",StringType(),False),
StructField("subcategory",StringType(),True),
StructField("value",StringType(),True),
StructField("Language",StringType(),True),
StructField("confidence_score",FloatType(),True),
StructField("country_azuremaps",StringType(),True),
StructField("country_code_azuremaps",StringType(),True),
StructField("created_datetime", TimestampType(), True)])
dfEntities = spark.createDataFrame(lstEntities,schema)
dfEntities.createOrReplaceTempView("dfEntities")
schema = StructType([StructField("id", StringType(), False),
StructField("sentiment", StringType(), True),
StructField("overallscore", FloatType(), True),
StructField("created_datetime", TimestampType(), True)])
dfSentiment = spark.createDataFrame(lstSentiment, schema)
dfSentiment.createOrReplaceTempView("dfSentiment")


# In[ ]:


if dftweets.count() == 0:
  print("Didn't capture new tweets.")
else:
  print(str(dftweets.count() ) + " tweets to process.")


# # Synapse Data Ingestion

# In[ ]:

%%spark
val scala_dftweets = spark.sqlContext.sql ("select * from dftweets")
scala_dftweets.write.synapsesql(DB_NAME+".stg.[Tweets]", Constants.INTERNAL)


# In[ ]:

%%spark
val scala_dfhashtags = spark.sqlContext.sql ("select * from dfhashtags")
scala_dfhashtags.write.synapsesql(DB_NAME+".stg.[Hashtags]", Constants.INTERNAL)


# In[ ]:

%%spark
val scala_dfhandles = spark.sqlContext.sql ("select * from dfhandles")
scala_dfhandles.write.synapsesql(DB_NAME+".stg.[Handles]", Constants.INTERNAL)


# In[ ]:

%%spark
val scala_dfmedia = spark.sqlContext.sql ("select * from dfmedia")
scala_dfmedia.write.synapsesql(DB_NAME+".stg.[TweetMedia]", Constants.INTERNAL)


# In[ ]:

%%spark
val scala_dfSentiment = spark.sqlContext.sql ("select * from dfSentiment")
scala_dfSentiment.write.synapsesql(DB_NAME+".stg.[Sentiments]", Constants.INTERNAL)


# In[ ]:

%%spark
val scala_dfURLs = spark.sqlContext.sql ("select * from dfURLs")
scala_dfURLs.write.synapsesql(DB_NAME+".stg.[TweetURLs]", Constants.INTERNAL)


# In[ ]:

%%spark
val scala_dfTranslations = spark.sqlContext.sql ("select * from dfTranslations")
scala_dfTranslations.write.synapsesql(DB_NAME+".stg.[Translations]", Constants.INTERNAL)


# In[ ]:

%%spark
val scala_dfEntities = spark.sqlContext.sql ("select * from dfEntities")
scala_dfEntities.write.synapsesql(DB_NAME+".stg.[TweetsEntities]", Constants.INTERNAL)

