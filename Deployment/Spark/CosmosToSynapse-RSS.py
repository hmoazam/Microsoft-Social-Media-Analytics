#!/usr/bin/env python
# coding: utf-8


# In[ ]:


import os
from dateutil.parser import parse
from datetime import datetime, timedelta 
from pyspark.sql.types import StructType, StructField, IntegerType,StringType,DateType, LongType, DecimalType,TimestampType, BooleanType,FloatType
from urllib.parse import urlparse
from azure.cosmos import CosmosClient


# In[ ]:


%run "config"


# In[ ]:


# Connect to Cosmos
client = CosmosClient(COSMOS_URL, {'masterKey': COSMOS_KEY})
database = client.get_database_client(COSMOS_DATABASE_NAME)
rss_container_client = database.get_container_client(container=COSMOS_RSS_FEEDS_CONTAINER_NAME)


# In[ ]:


last_inserted_ts = 0

jdbc_url = "jdbc:sqlserver://" + SYNAPSE_WORKSPACE_NAME + ".sql.azuresynapse.net:1433;database=" + DB_NAME + ";encrypt=true;trustServerCertificate=true;hostNameInCertificate=*.sql.azuresynapse.net;loginTimeout=30;"

jdbcDF = spark.read.format("jdbc").option("url", jdbc_url).option("query", "SELECT MAX(inserted_to_CosmosDB_ts) AS outp FROM dbo.RSSArticles").option("user", SQL_USERNAME).option("password", SQL_PASSWORD).load()

try:
    last_inserted_ts = jdbcDF.first()[0]
except: 
    last_inserted_ts = 0

if not(last_inserted_ts): # if the table is empty get back None
    last_inserted_ts = 0



# In[ ]:


LANGUAGE_CODES={"All":"","Afrikaans":"af","Arabic":"ar","Assamese":"as","Bangla":"bn","Bosnian(Latin)":"bs","Bulgarian":"bg","Cantonese(Traditional)":"yue","Catalan":"ca","Chinese Simplified":"zh-Hans","Chinese Traditional":"zh-Hant","Croatian":"hr","Czech":"cs","Dari":"prs","Danish":"da","Dutch":"nl","English":"en","Estonian":"et","Fijian":"fj","Filipino":"fil","Finnish":"fi","French":"fr","German":"de","Greek":"el","Gujarati":"gu","Haitian Creole":"ht","Hebrew":"he","Hindi":"hi","Hmong Daw":"mww","Hungarian":"hu","Icelandic":"is","Indonesian":"id","Irish":"ga","Italian":"it","Japanese":"ja","Kannada":"kn","Kazakh":"kk","Klingon":"tlh-Latn","Klingon(plqaD)":"tlh-Piqd","Korean":"ko","Kurdish(Central)":"ku","Kurdish(Northern)":"kmr","Latvian":"lv","Lithuanian":"lt","Malagasy":"mg","Malay":"ms","Malayalam":"ml","Maltese":"mt","Maori":"mi","Marathi":"mr","Norwegian":"nb","Odia":"or","Pashto":"ps","Persian":"fa","Polish":"pl","Portuguese(Brazil)":"pt-br","Portuguese(Portugal)":"pt-pt","Punjabi":"pa","Queretaro Otomi":"otq","Romanian":"ro","Russian":"ru","Samoan":"sm","Serbian(Cyrillic)":"sr-Cyrl","Serbian(Latin)":"sr-Latn","Slovak":"sk","Slovenian":"sl","Spanish":"es","Swahili":"sw","Swedish":"sv","Tahitian":"ty","Tamil":"ta","Telugu":"te","Thai":"th","Tongan":"to","Turkish":"tr","Ukrainian":"uk","Urdu":"ur","Vietnamese":"vi","Welsh":"cy","Yucatec Maya":"yua"}
LANGUAGE_CODES = {v: k for (k, v) in LANGUAGE_CODES.items()}


# In[ ]:


query = "SELECT * FROM items where items.inserted_to_CosmosDB_ts > " + str(last_inserted_ts)

lst_articles, lst_translations, lst_entities, lst_sentiment = ([] for i in range(4))


# In[ ]:


datetime_now = datetime.now() # UTC time


# In[ ]:


for article in rss_container_client.query_items(query, enable_cross_partition_query=True):
    
    published_at = parse(article["published_ts_str"]) # converts to datetime? # UTC +3 (local time)
    inserted_to_cosmos_ts = datetime.fromtimestamp(article['inserted_to_CosmosDB_ts']) # UTC
    inserted_to_cosmos_ts_int = article['inserted_to_CosmosDB_ts']

    # originals
    id_ = article["id"]
    title = article["title"] 
    summary = article["summary"]
    source = article["news_feed"]
    url = article["link"]
    img_url = article["img"]

    # processed objects
    title_translated = article["title_translated"]
    summary_translated = article["summary_translations"]
    summary_entities = article["summary_ner"]

    sentiment = article["sentiment"]
    sentiment_score = float(article["sentiment_score"])

    topic = article["topic"]
    subtopic = article["subtopic"]

    # populate RSSArticles
    lst_articles.append([id_, source, title, summary, url, img_url, published_at, datetime_now, inserted_to_cosmos_ts, inserted_to_cosmos_ts_int, topic, subtopic])

    # populate RSSArticlesEntities
    langs = summary_entities.keys()
    for lang in langs: 
        entities = summary_entities[lang]
        for ent in entities: 
            lst_entities.append([id_, lang, ent["category"], ent["subcategory"], ent["text"], ent["confidence_score"], published_at])
    
    # populate RSSArticlesSentiments
    lst_sentiment.append([id_, sentiment, sentiment_score, published_at])
   
    # populate RSSArticlesTranslations
    langs = title_translated.keys()
    for lang in langs: 
        title_ = title_translated[lang]
        summary_ = summary_translated[lang]
        lst_translations.append([id_, lang, title_, summary_, published_at])


# In[ ]:


# Create spark dataframes
schema_rss_articles = StructType([
    StructField("id", StringType(), False),
    StructField("source", StringType(), True),
    StructField("title", StringType(), True),
    StructField("summary", StringType(), True),
    StructField("url", StringType(), True),
    StructField("img_url", StringType(), True),
    StructField("published_at", TimestampType(), True),
    StructField("inserted_datetime", TimestampType(), True),
    StructField("inserted_to_CosmosDB_datetime", TimestampType(), True),
    StructField("inserted_to_CosmosDB_ts", LongType(), True),
    StructField("topic", StringType(), True),
    StructField("subtopic", StringType(), True)
])
df_rss_articles = spark.createDataFrame(lst_articles, schema_rss_articles)
df_rss_articles.createOrReplaceTempView("df_rss_articles")


# In[ ]:


schema_rss_articles_entities = StructType([
    StructField("id", StringType(), False),
    StructField("language", StringType(), True),
    StructField("category", StringType(), True),
    StructField("subcategory", StringType(), True),
    StructField("value", StringType(), True),
    StructField("confidence_score", FloatType(), True),
    StructField("created_datetime", TimestampType(), True)
])
df_rss_articles_entities = spark.createDataFrame(lst_entities, schema_rss_articles_entities)
df_rss_articles_entities.createOrReplaceTempView("df_rss_articles_entities")


# In[ ]:


schema_rss_articles_sentiments = StructType([
    StructField("id", StringType(), False),
    StructField("sentiment", StringType(), True),
    StructField("overallscore", FloatType(), True),
    StructField("created_datetime", TimestampType(), True)
])
df_rss_articles_sentiments = spark.createDataFrame(lst_sentiment, schema_rss_articles_sentiments)
df_rss_articles_sentiments.createOrReplaceTempView("df_rss_articles_sentiments")



# In[ ]:


schema_rss_articles_translations = StructType([
    StructField("id", StringType(), False),
    StructField("Language", StringType(), True),
    StructField("Title", StringType(), True),
    StructField("Summary", StringType(), True),
    StructField("created_datetime", TimestampType(), True)
])
df_rss_articles_translations = spark.createDataFrame(lst_translations, schema_rss_articles_translations)
df_rss_articles_translations.createOrReplaceTempView("df_rss_articles_translations")


# In[ ]:

%%spark
val scala_df_articles = spark.sqlContext.sql ("select * from df_rss_articles")
scala_df_articles.write.synapsesql(DB_NAME+".stg.RSSArticles", Constants.INTERNAL)


# In[ ]:

%%spark
val scala_df_entities = spark.sqlContext.sql ("select * from df_rss_articles_entities")
scala_df_entities.write.synapsesql(DB_NAME+".stg.RSSArticlesEntities", Constants.INTERNAL)


# In[ ]:

%%spark
val scala_df_sentiments = spark.sqlContext.sql ("select * from df_rss_articles_sentiments")
scala_df_sentiments.write.synapsesql(DB_NAME+".stg.RSSArticlesSentiments", Constants.INTERNAL)


# In[ ]:

%%spark
val scala_df_translations = spark.sqlContext.sql ("select * from df_rss_articles_translations")
scala_df_translations.write.synapsesql(DB_NAME+".stg.RSSArticlesTranslations", Constants.INTERNAL)

