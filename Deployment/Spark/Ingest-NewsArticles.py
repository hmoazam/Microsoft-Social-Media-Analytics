#!/usr/bin/env python
# coding: utf-8

# In[2]:


import urllib.parse
import sys, time, json, requests, uuid
from azure.cosmos import CosmosClient
from datetime import datetime, date, timedelta # don't import time here. It messes with the default library
from dateutil.parser import parse
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential


# In[3]:


%run "config"


# In[4]:


%run "common"


# In[13]:



COUNTRIES = ["ae", "ar", "at", "au", "be", "bg", "br", "ca", "ch", "cn", "co", "cu", "cz", "de", "eg", "fr", "gb", "gr", "hk", "hu", "id", "ie", "il", "in", "it", "jp", "kr", "lt", "lv", "ma", "mx", "my", "ng", "nl", "no", "nz", "ph", "pl", "pt", "ro", "rs", "ru", "sa", "se", "sg", "si", "sk", "th", "tr", "tw", "ua", "us", "ve", "za"]
LANGUAGE_CODES = {
  "All": "",
  "Afrikaans":"af",
  "Arabic":"ar",
  "Assamese":"as",
  "Bangla":"bn",
  "Bosnian(Latin)":"bs",
  "Bulgarian":"bg",
  "Cantonese(Traditional)":"yue",
  "Catalan":"ca",
  "Chinese Simplified":"zh-Hans",
  "Chinese Traditional":"zh-Hant",
  "Croatian":"hr",
  "Czech":"cs",
  "Dari":"prs",
  "Danish":"da",
  "Dutch":"nl",
  "English":"en",
  "Estonian":"et",
  "Fijian":"fj",
  "Filipino":"fil",
  "Finnish":"fi",
  "French":"fr",
  "German":"de",
  "Greek":"el",
  "Gujarati":"gu",
  "Haitian Creole":"ht",
  "Hebrew":"he",
  "Hindi":"hi",
  "Hmong Daw":"mww",
  "Hungarian":"hu",
  "Icelandic":"is",
  "Indonesian":"id",
  "Irish":"ga",
  "Italian":"it",
  "Japanese":"ja",
  "Kannada":"kn",
  "Kazakh":"kk",
  "Klingon":"tlh-Latn",
  "Klingon(plqaD)":"tlh-Piqd",
  "Korean":"ko",
  "Kurdish(Central)":"ku",
  "Kurdish(Northern)":"kmr",
  "Latvian":"lv",
  "Lithuanian":"lt",
  "Malagasy":"mg",
  "Malay":"ms",
  "Malayalam":"ml",
  "Maltese":"mt",
  "Maori":"mi",
  "Marathi":"mr",
  "Norwegian":"nb",
  "Odia":"or",
  "Pashto":"ps",
  "Persian":"fa",
  "Polish":"pl",
  "Portuguese(Brazil)":"pt-br",
  "Portuguese(Portugal)":"pt-pt",
  "Punjabi":"pa",
  "Queretaro Otomi":"otq",
  "Romanian":"ro",
  "Russian":"ru",
  "Samoan":"sm",
  "Serbian(Cyrillic)":"sr-Cyrl",
  "Serbian(Latin)":"sr-Latn",
  "Slovak":"sk",
  "Slovenian":"sl",
  "Spanish":"es",
  "Swahili":"sw",
  "Swedish":"sv",
  "Tahitian":"ty",
  "Tamil":"ta",
  "Telugu":"te",
  "Thai":"th",
  "Tongan":"to",
  "Turkish":"tr",
  "Ukrainian":"uk",
  "Urdu":"ur",
  "Vietnamese":"vi",
  "Welsh":"cy",
  "Yucatec Maya":"yua"
}


# ### Parameters

# In[14]: Parameters

query = "Ukraine"
topic = "News"
subtopic = ""
language = "All"
target_languages = "English,French"
from_date = ""
to_date = ""
sort_by = "popularity" # popularity, relevancy, publishedAt
qInTitle = "" #?
page_size = "20"



# In[15]:

config = {}
#config["topic"] = topic
config["q"] = query
# languages = dbutils.widgets.get("languages")
language_codes = [LANGUAGE_CODES.get(key) for key in language.split(",") if key != "All"]
if language_codes:
    if language_codes[0] in ["ar","de","en","es","fr","he","it","nl","no","pt","ru","se","ud","zh"]:
        config["language"] = language_codes[0]# ','.join(language_codes) # take the first language only as the API does not support multiple values
config["from"] = from_date
config["to"] = to_date
config["sortBy"] = sort_by
config["qInTitle"] = qInTitle
config["pageSize"] = page_size
config["apiKey"] = NEWS_API_KEY
# dbutils.widgets.multiselect("target_languages", "English", list(LANGUAGE_CODES.keys()), "04.Target Languages")
target_languages = [LANGUAGE_CODES.get(lang, "") for lang in target_languages.split(",")]
if "en" not in target_languages:
    target_languages.append("en") # always include english in target languages



# In[19]:


client = CosmosClient(COSMOS_URL, {'masterKey': COSMOS_KEY})
database = client.get_database_client(COSMOS_DATABASE_NAME)

article_container_client = database.get_container_client(container=COSMOS_ARTICLE_CONTAINER_NAME)


# In[20]:
def build_query(config, page=1):
    query = "http://newsapi.org/v2/everything?"
    for k,v in config.items():
        if v is None or v == "":
            continue
        query += f"{k}={v}&"
    query += f"page={page}"
    return query
query = build_query(config)
page = 1
all_articles = []
while True:
    url = build_query(config, page)
    print(f"Getting page {page}...")
    response = requests.get(url).json()
    if response["status"] == "error":
        break
    articles = response.get("articles")
    if not articles:
        break
    for article in articles:
        article["id"] = str(abs(hash(article["url"])))
        search_query = 'select * from items where items.id="{0}"'.format(article["id"])
        items = list(article_container_client.query_items(search_query,enable_cross_partition_query=True))
        if len(items)>0:
            print("Old Article")
        else:
            print("New Article")
            dt2 = datetime.now()
            ts= int(time.mktime(dt2.timetuple()))
            at=dt2.strftime("%m/%d/%Y, %H:%M:%S %Z")
            article['inserted_to_CosmosDB_at'] = at
            article['inserted_to_CosmosDB_ts'] = ts
            article['topickey'] = topic
            article['subtopic'] = subtopic
            article["month_year"] = str(parse(article["publishedAt"]).month) + "_"+str(parse(article["publishedAt"]).year)
            article["document_type"] = "news_article"
            titleLength = len(article["content"])
            if titleLength>80:
                titleLength=79
            if article["title"] is None:
                article["title"]=article["content"][0:titleLength]
            article["title"]=article["title"][0].upper()+article["title"][1:]
            
            i=article["title"].find(' ', titleLength)
            article["translations_title"], query_language = get_translation(article["title"], target_languages)
            article["translations_description"], _ = get_translation(article["description"], target_languages)
            article["translations_content"], _ = get_translation(article["content"], target_languages)
            if i==-1:
                article["title"]=article["title"]
            else:
                if query_language in ['ar','ar-EG']:
                    article["title"]=article["title"][0:i].replace(' ,',',').rstrip(' ').rstrip(',')
                else:
                    article["title"]=article["title"][0:i].replace(' ,',',').rstrip(' ').rstrip(',')+" ..."
            
        
            print("Working on named entities")
            named_entities = []
            if query_language != "en":
                if article["translations_content"]["en"]!='':
                    named_entities = get_ner(article["translations_content"]["en"])
                    named_entity_obj = {"en": named_entities}
                    org_language_entities = []
                    for ent in named_entities:
                        org_language_ent = ent.copy()
                        org_language_ent["text"] = get_translation(ent["text"], query_language)[0][query_language] # replace with original language text
                    org_language_entities.append(org_language_ent)
                    named_entity_obj[query_language] = org_language_entities
                else:
                    named_entity_obj = {"en": named_entities}
            else:
                named_entities = get_ner(article["content"]) # list of objects where each object corresponds to an entity
                named_entity_obj = {"en": named_entities}
              # get translation to all target languages for all entities
            for language in target_languages:
                if language != "en":
                    tmp_entities = []
                    for ent in named_entities:
                        tmp_ = ent.copy()
                        tmp_["text"] = get_translation(ent["text"],  language)[0][language]
                        tmp_entities.append(tmp_)
                    named_entity_obj[language] = tmp_entities
            article["named_entities"] = named_entity_obj
              # get sentiment. Not supported for arabic, so do on english. No need to translate back
            print("Working on sentiment")
            if query_language != "en":
                sentiment, sentiment_score = get_sentiment(article["translations_title"]["en"])
            else:
                sentiment, sentiment_score = get_sentiment(article["title"])
            article["sentiment"] = {"sentiment": sentiment, "score": sentiment_score}
            article["lang"]=query_language
            all_articles.append(article)        
    page += 1
print("Done! Article: ",str(len(all_articles)))



# In[21]:


update_cosmos(all_articles, article_container_client) # insert tweets
