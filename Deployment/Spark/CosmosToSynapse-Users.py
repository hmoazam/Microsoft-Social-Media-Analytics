#!/usr/bin/env python
# coding: utf-8

# # Libraries

# In[1]:


import os
from azure.cosmos import CosmosClient
from azure.core.credentials import AzureKeyCredential
from azure.ai.textanalytics import TextAnalyticsClient
from pyspark.sql.types import StructType, StructField, LongType, StringType, DateType, TimestampType,FloatType,IntegerType,BooleanType
from notebookutils import mssparkutils

from azure.cosmos import CosmosClient, PartitionKey
import family
import json
import pandas as pd
from datetime import date, timedelta 
from datetime import datetime as _datetime 

import numpy as np
import datetime, time
from dateutil.parser import parse
import re,string
#import pyodbc


# In[2]:

%run "config"


# In[3]:


# Connect to Cosmos
client = CosmosClient(COSMOS_URL, {'masterKey': COSMOS_KEY})
database = client.get_database_client(COSMOS_DATABASE_NAME)
tweet_container_client = database.get_container_client(container=COSMOS_CONTAINER_NAME)


# In[4]:


%%spark
val dfLastInsertedInDW = spark.read.synapsesql(DB_NAME+".dbo.[Users]")
dfLastInsertedInDW.createOrReplaceTempView("dfLastInsertedInDW")


# In[5]:


last_inserted_ts=0
dfLastInsertedInDW = spark.sql("select * from dfLastInsertedInDW")
try:
   last_inserted_ts=dfLastInsertedInDW.agg(max("inserted_to_CosmosDB_ts"))
except:
    last_inserted_ts=0


# # Tweets Querying + Modeling

# In[6]:


#query = "SELECT items.latest_version, items.inserted_to_CosmosDB_ts from items where items.document_type = 'user'" # and items.inserted_to_CosmosDB_ts >= "  + str(last_inserted_ts) 
query = "SELECT * from items WHERE items.document_type = 'user' and items.inserted_to_CosmosDB_ts >= " + str(last_inserted_ts) 

lstuser = []
cols = ['id', 'name','screen_name','location','description', 'followers_count', 'friends_count','favourites_count', 'listed_count', 'statuses_count', 'isFollowing',
        'verified',
        'geoEnabled',
        'language',
        'url', 
        'profile_image_url',
        'background_image_url',
        'profile_banner_url', 
        'created_date',
        'created_datetime',
        'inserted_datetime',
        'inserted_to_CosmosDB_datetime',
        'inserted_to_CosmosDB_ts'
       ]  
for posts in tweet_container_client.query_items(query,enable_cross_partition_query=True ):
#   id = posts['latest_version']['id_str']
  id = posts['id']
#   name = posts['latest_version']['name']
  name = posts["name"]
  screen_name = posts['screen_name']
  location = posts['location']
  
  description = posts['description']
  followers_count = posts['followers_count']
  friends_count = posts['friends_count']
  favourites_count = posts['favourites_count']
  
  listed_count = posts['listed_count']
  statuses_count = posts['statuses_count']
  isFollowing = posts['following']
  verified = posts['verified']
  
  geoEnabled = posts['geo_enabled']
  language = '' 
  url = 'https://twitter.com/' + posts['screen_name'] 
  profile_image_url = posts['profile_image_url_https']
  
  background_image_url = posts['profile_background_image_url_https']
  profile_banner_url = "" #posts['latest_version']['profile_banner_url']
  adjustedCreatedDateTime = parse(posts['created_at'])+ timedelta(hours=3) 
  
  if 'country_code_azuremaps' in posts.keys() and 'country_azuremaps' in posts.keys() :
    country_azuremaps=posts['country_azuremaps']
    country_code_azuremaps=posts['country_code_azuremaps']
  else:
    country_azuremaps=None
    country_code_azuremaps=None

  #append tweet
  lstuser.append([id, 
              name,
              screen_name, 
              location,               
              description, 
              int(followers_count), int(friends_count), int(favourites_count), int(listed_count), int(statuses_count),
              isFollowing, verified, geoEnabled, language, 
              url, profile_image_url, background_image_url, profile_banner_url,
              adjustedCreatedDateTime,
              adjustedCreatedDateTime,
              _datetime.fromtimestamp(posts["inserted_to_CosmosDB_ts"]),
              _datetime.fromtimestamp(posts["inserted_to_CosmosDB_ts"]),
              posts["inserted_to_CosmosDB_ts"],
              country_azuremaps,
              country_code_azuremaps,
             ])


# In[7]:


schema = StructType([StructField("id",StringType(),True),     StructField("name",StringType(),True),     StructField("screen_name",StringType(),True),     StructField("location", StringType(), True),     StructField("description", StringType(), True),     StructField("followers_count", IntegerType(), True),     StructField("friends_count", IntegerType(), True),     StructField("favourites_count", StringType(), True),     StructField("listed_count", IntegerType(), True),     StructField("statuses_count", IntegerType(), True),     StructField("isFollowing", BooleanType(), True),     StructField("verified", BooleanType(), True),     StructField("geoEnabled", BooleanType(), True),     StructField("language", StringType(), True),     StructField("url", StringType(), True),     StructField("profile_image_url", StringType(), True),     StructField("background_image_url", StringType(), True),     StructField("profile_banner_url", StringType(), True),     StructField("created_date", DateType(), True),     StructField("created_datetime", TimestampType(), True),     StructField("inserted_datetime", TimestampType(), True),     StructField("inserted_to_CosmosDB_datetime", TimestampType(), True),     StructField("inserted_to_CosmosDB_ts", LongType(), True),     StructField("country_azuremaps", StringType(), True),     StructField("country_code_azuremaps", StringType(), True),   ])
dfUsers = sqlContext.createDataFrame(lstuser,schema)
dfUsers.createOrReplaceTempView("dfUsers")


# In[8]:


if dfUsers.count() == 0:
  print("Didn't capture new users.")
  #dbutils.notebook.exit(0)
  #mssparkutils.notebook.exit("no more users")
else:
  print(str(dfUsers.count()) + " users to process.")
  


# # Synapse Data Ingestion

# In[9]:


%%spark
val scala_dfUsers = spark.sqlContext.sql ("select * from dfUsers")
scala_dfUsers.write.synapsesql(DB_NAME+".stg.[Users]", Constants.INTERNAL)

