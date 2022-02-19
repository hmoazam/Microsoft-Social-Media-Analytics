#!/usr/bin/env python
# coding: utf-8

# # Libraries

# In[1]:


import os
from dateutil.parser import parse
from datetime import datetime, timedelta 
from pyspark.sql.types import StructType, StructField, IntegerType,StringType,DateType, LongType, DecimalType,TimestampType, BooleanType,FloatType
from urllib.parse import urlparse
from azure.cosmos import CosmosClient


# In[2]:


%run "config"


# In[3]:


# Connect to Cosmos
client = CosmosClient(COSMOS_URL, {'masterKey': COSMOS_KEY})
database = client.get_database_client(COSMOS_DATABASE_NAME)
tweet_container_client = database.get_container_client(container=COSMOS_ARTICLE_CONTAINER_NAME)


# In[4]:


%%spark
val dfLastInsertedInDW = spark.read.synapsesql(DB_NAME+".dbo.Articles")
dfLastInsertedInDW.createOrReplaceTempView("dfLastInsertedInDW")


# In[5]:


last_inserted_ts=0
try:
   last_inserted_ts=dfLastInsertedInDW.agg(max("inserted_to_CosmosDB_ts"))
except:
    last_inserted_ts=0
print(last_inserted_ts)
LANGUAGE_CODES={"All":"","Afrikaans":"af","Arabic":"ar","Assamese":"as","Bangla":"bn","Bosnian(Latin)":"bs","Bulgarian":"bg","Cantonese(Traditional)":"yue","Catalan":"ca","Chinese Simplified":"zh-Hans","Chinese Traditional":"zh-Hant","Croatian":"hr","Czech":"cs","Dari":"prs","Danish":"da","Dutch":"nl","English":"en","Estonian":"et","Fijian":"fj","Filipino":"fil","Finnish":"fi","French":"fr","German":"de","Greek":"el","Gujarati":"gu","Haitian Creole":"ht","Hebrew":"he","Hindi":"hi","Hmong Daw":"mww","Hungarian":"hu","Icelandic":"is","Indonesian":"id","Irish":"ga","Italian":"it","Japanese":"ja","Kannada":"kn","Kazakh":"kk","Klingon":"tlh-Latn","Klingon(plqaD)":"tlh-Piqd","Korean":"ko","Kurdish(Central)":"ku","Kurdish(Northern)":"kmr","Latvian":"lv","Lithuanian":"lt","Malagasy":"mg","Malay":"ms","Malayalam":"ml","Maltese":"mt","Maori":"mi","Marathi":"mr","Norwegian":"nb","Odia":"or","Pashto":"ps","Persian":"fa","Polish":"pl","Portuguese(Brazil)":"pt-br","Portuguese(Portugal)":"pt-pt","Punjabi":"pa","Queretaro Otomi":"otq","Romanian":"ro","Russian":"ru","Samoan":"sm","Serbian(Cyrillic)":"sr-Cyrl","Serbian(Latin)":"sr-Latn","Slovak":"sk","Slovenian":"sl","Spanish":"es","Swahili":"sw","Swedish":"sv","Tahitian":"ty","Tamil":"ta","Telugu":"te","Thai":"th","Tongan":"to","Turkish":"tr","Ukrainian":"uk","Urdu":"ur","Vietnamese":"vi","Welsh":"cy","Yucatec Maya":"yua"}
LANGUAGE_CODES = {v: k for (k, v) in LANGUAGE_CODES.items()}



# # News Articles

# In[6]:

query = "SELECT * from items where items.document_type = 'news_article' and items._ts > "  + str(last_inserted_ts)
lstNewsArticles, lstEntities,lstKeyPhrases, lstSentiment, lstTranslations  = ([] for i in range(5))
for article in tweet_container_client.query_items(query,enable_cross_partition_query=True ):
  domain = urlparse(article["url"]).netloc
  publishedAt = parse(article['publishedAt']) + timedelta(hours=3) 
  inserted_to_CosmosDB_datetime = datetime.fromtimestamp(article['_ts'])
  inserted_to_CosmosDB_ts = int(article['_ts'])
  title=article['title']
  description=article['description']
  content = article['content']
  lstNewsArticles.append([article['id'], article['topickey'], article['subtopic'],article['source']['name'], article['author'],title, description , article['url'], article['urlToImage'], content, publishedAt, inserted_to_CosmosDB_datetime, inserted_to_CosmosDB_ts,domain, article['lang'], 'News Article'])
  
  for l in article['translations_title']:
     lstTranslations.append([article['id'], l,'title', article['translations_title'][l], datetime.now()])

  for l in article['translations_description']:
    lstTranslations.append([article['id'], l,'description', article['translations_description'][l], datetime.now()])

  for l in article['translations_content']:
    lstTranslations.append([article['id'], l,'content', article['translations_content'][l], datetime.now()])

  for l in article['named_entities']:
    for entity in article['named_entities'][l]:
      lstEntities.append([article['id'], entity['category'], entity['subcategory'], entity['text'], LANGUAGE_CODES.get(l, "unknown"), float(entity['confidence_score']), datetime.now() ])
  
  if "sentiment" in article.keys():
    lstSentiment.append([article['id'], article["sentiment"]["sentiment"], article["sentiment"]["score"], datetime.now()])  


# In[7]:

schema = StructType([StructField("id",StringType(),False),   StructField("Language",StringType(),False),   StructField("Field",StringType(),True),   StructField("Text",StringType(),True),   StructField("created_datetime", TimestampType(), True)])
dfTranslations = spark.createDataFrame(lstTranslations,schema)
dfTranslations.createOrReplaceTempView("dfTranslations")
schema = StructType([StructField("id",StringType(),False),   StructField("KeyPhrase",StringType(),False),   StructField("Language",StringType(),True),   StructField("created_datetime", TimestampType(), True)])
schema = StructType([StructField("id",StringType(),False),   StructField("category",StringType(),False),   StructField("subcategory",StringType(),True),   StructField("value",StringType(),True),   StructField("Language",StringType(),True),   StructField("confidence_score",FloatType(),True),   StructField("created_datetime", TimestampType(), True)])
dfEntities = spark.createDataFrame(lstEntities,schema)
dfEntities.createOrReplaceTempView("dfEntities")
schema = StructType([StructField("id", StringType(), False),  StructField("sentiment", StringType(), True),  StructField("overallscore", FloatType(), True),  StructField("created_datetime", TimestampType(), True)])
dfSentiment = spark.createDataFrame(lstSentiment, schema)
dfSentiment.createOrReplaceTempView("dfSentiment")
schema = StructType([StructField("id",StringType(),False),     StructField("topic",StringType(),True),     StructField("subtopic",StringType(),True),     StructField("sourceName",StringType(),True),     StructField("author",StringType(),True),     StructField("title", StringType(), True),     StructField("description", StringType(), True),     StructField("url", StringType(), True),     StructField("urlToImage",StringType(),True),     StructField("content",StringType(),True),     StructField("publishedAt", TimestampType(), True),     StructField("inserted_to_CosmosDB_datetime",TimestampType(),True),     StructField("inserted_to_CosmosDB_ts", LongType(), True),      StructField("domainname", StringType(), True),     StructField("language", StringType(), True),     StructField("Type", StringType(), True)])
dfNewsArticles = spark.createDataFrame(lstNewsArticles, schema)
dfNewsArticles.createOrReplaceTempView("dfNewsArticles")


# In[8]:


if dfNewsArticles.count() == 0 :
  print("Didn't capture news articles.")
  #dbutils.notebook.exit(0)
else:
  print(str(dfNewsArticles.count()) + " news articles to process.")


# # Synapse Data Ingestion

# In[9]:


%%spark
val scala_dfNewsArticles = spark.sqlContext.sql ("select * from dfNewsArticles")
scala_dfNewsArticles.write.synapsesql(DB_NAME+".stg.[Articles]", Constants.INTERNAL)


# In[10]:

%%spark
val scala_dfEntities = spark.sqlContext.sql ("select * from dfEntities")
scala_dfEntities.write.synapsesql(DB_NAME+".stg.[ArticlesEntities]", Constants.INTERNAL)


# In[11]:


%%spark
val scala_dfSentiment = spark.sqlContext.sql ("select * from dfSentiment")
scala_dfSentiment.write.synapsesql(DB_NAME+".stg.[ArticlesSentiments]", Constants.INTERNAL)


# In[12]:


%%spark
val scala_dfTranslations = spark.sqlContext.sql ("select * from dfTranslations")
scala_dfTranslations.write.synapsesql(DB_NAME+".stg.[ArticlesTranslations]", Constants.INTERNAL)



