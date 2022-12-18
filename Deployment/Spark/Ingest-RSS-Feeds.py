#!/usr/bin/env python
# coding: utf-8



# In[ ]: Parameters


# Pipeline params 
# feed_source = "https://full.gulf-times.com/Rss/Index"
feed_source = "https://www.psychologytoday.com/us/blog/singletons/feed"
target_languages = "English,Arabic"
query_optional = "" # split with OR
query_required = "" # split with AND
topic = "Parenting"
subtopic = ""


# In[ ]:


from azure.cosmos import CosmosClient
from azure.core.credentials import AzureKeyCredential
from azure.ai.textanalytics import TextAnalyticsClient

import copy
import feedparser
import sys, time, json, requests, uuid
from datetime import datetime, date, timedelta # don't import time here. It messes with the default library


# In[ ]:


LANGUAGE_CODES={"All":"","Afrikaans":"af","Arabic":"ar","Assamese":"as","Bangla":"bn","Bosnian(Latin)":"bs","Bulgarian":"bg","Cantonese(Traditional)":"yue","Catalan":"ca","Chinese Simplified":"zh-Hans","Chinese Traditional":"zh-Hant","Croatian":"hr","Czech":"cs","Dari":"prs","Danish":"da","Dutch":"nl","English":"en","Estonian":"et","Fijian":"fj","Filipino":"fil","Finnish":"fi","French":"fr","German":"de","Greek":"el","Gujarati":"gu","Haitian Creole":"ht","Hebrew":"he","Hindi":"hi","Hmong Daw":"mww","Hungarian":"hu","Icelandic":"is","Indonesian":"id","Irish":"ga","Italian":"it","Japanese":"ja","Kannada":"kn","Kazakh":"kk","Klingon":"tlh-Latn","Klingon(plqaD)":"tlh-Piqd","Korean":"ko","Kurdish(Central)":"ku","Kurdish(Northern)":"kmr","Latvian":"lv","Lithuanian":"lt","Malagasy":"mg","Malay":"ms","Malayalam":"ml","Maltese":"mt","Maori":"mi","Marathi":"mr","Norwegian":"nb","Odia":"or","Pashto":"ps","Persian":"fa","Polish":"pl","Portuguese(Brazil)":"pt-br","Portuguese(Portugal)":"pt-pt","Punjabi":"pa","Queretaro Otomi":"otq","Romanian":"ro","Russian":"ru","Samoan":"sm","Serbian(Cyrillic)":"sr-Cyrl","Serbian(Latin)":"sr-Latn","Slovak":"sk","Slovenian":"sl","Spanish":"es","Swahili":"sw","Swedish":"sv","Tahitian":"ty","Tamil":"ta","Telugu":"te","Thai":"th","Tongan":"to","Turkish":"tr","Ukrainian":"uk","Urdu":"ur","Vietnamese":"vi","Welsh":"cy","Yucatec Maya":"yua"}

target_languages = [LANGUAGE_CODES.get(lang, "") for lang in target_languages.split(",")]
if "en" not in target_languages:
  target_languages.append("en")


# In[ ]:


%run "config"


# In[ ]:


%run "common"


# In[ ]:


client = CosmosClient(COSMOS_URL, {'masterKey': COSMOS_KEY})
database = client.get_database_client(COSMOS_DATABASE_NAME)
rss_container_client = database.get_container_client(container=COSMOS_RSS_FEEDS_CONTAINER_NAME)


# In[ ]:


def get_translation(inp_text, to_languages):
    """
    Params:
    inp_text: text to be translated
    to_languages: list of languages to translate to
    Returns: {lang_code: translation}, language code of the original text
    Call to translator cognitive service detects language and translates to the target languages. 
    Result is a dictionary of language codes to translated text, along with the language detected.
    """
    # Translator setup
    translator_path = "/translate"
    translator_url = TRANSLATOR_ENDPOINT + translator_path
    params = {
    "api-version": "3.0",
    "to": to_languages
    }
    headers = {
    'Ocp-Apim-Subscription-Key': TRANSLATOR_KEY,
    'Ocp-Apim-Subscription-Region': TRANSLATOR_REGION,
    'Content-type': 'application/json',
    'X-ClientTraceId': str(uuid.uuid4())
    }
    # create and send request
    body = [{
    'text': inp_text
    }]
    request = requests.post(translator_url, params=params, headers=headers, json=body)
    response = request.json()
    # only ever one string sent for translation, so only list of length 1
    try:
        from_language = response[0]["detectedLanguage"]["language"]
        translations = response[0]["translations"]
        res = {} # dict with language as key and translated text as value e.g. {"ar": "arabic text"}
        for trans in translations:
            res[trans['to']] = trans['text']
        res[from_language] = inp_text # also include the original text and language in translations - overkill?
        return res, from_language # return the translated text, as well as the language it was translated from
    except Exception as err:
        print("Encountered an exception. {}".format(err))
        return err


# In[ ]:


def authenticate_client():
    """
    Returns: text analytics client
    """
    ta_credential = AzureKeyCredential(TEXT_ANALYTICS_KEY)
    text_analytics_client = TextAnalyticsClient(
            endpoint=TEXT_ANALYTICS_ENDPOINT, 
            credential=ta_credential)
    return text_analytics_client
text_analytics_client = authenticate_client()

def get_sentiment(inp_text):
    #Parameters: 
    #  inp_text: text to analyze
    #Returns:
    #  sentiment, sentiment score
    documents = [inp_text]
    response = text_analytics_client.analyze_sentiment(documents = documents)[0]  
    overallscore = response.confidence_scores.positive + (0.5*response.confidence_scores.neutral) # check logic of this
    return response.sentiment, overallscore

def get_ner(inp_text):
    #Parameters: 
    #  inp_text: text to analyze
    #Returns:
    #  NER Results as a list of dictionaries with keys: text, category, subcategory, length, offset, confidence
    try:
        documents = [inp_text]
        result = text_analytics_client.recognize_entities(documents = documents)[0]  
        return [{"text": x.text, "category": x.category, "subcategory": x.subcategory, "length": x.length, "offset": x.offset, "confidence_score": x.confidence_score} for x in result.entities]
    except Exception as err:
        print("Encountered exception. {}".format(err))
        return []


# In[ ]:


def is_new_entry(id_str, container):
    # check if this has already been added to cosmos - if yes don't re-process
    search_query = 'select * from items where items.id="{0}"'.format(id_str)
    items = list(container.query_items(search_query,enable_cross_partition_query=True))
    if len(items) > 0:
        return False
    return True


# In[ ]:


def process_title(title, target_languages):
    # translate
    translated, detected_lang = get_translation(title, target_languages)  
    return translated


# In[ ]:


def process_summary(summary, target_languages):
    # translate
    translated, detected_lang = get_translation(summary, target_languages)
    
    # ner
    if detected_lang != "en":
        named_entities = get_ner(translated["en"])
        named_entity_obj = {"en": named_entities}
        org_language_entities = []
        for ent in named_entities:
            org_language_ent = copy.deepcopy(ent)
            org_language_ent["text"] = get_translation(ent["text"], detected_lang)[0][detected_lang] # entity in the original language
            org_language_entities.append(org_language_ent)
        named_entity_obj[detected_lang] = org_language_entities
    else:
        named_entities = get_ner(summary) # list of objects where each object corresponds to an entity
        named_entity_obj = {"en": named_entities}
        
    for language in target_languages:
        if language != "en":
            tmp_entities = []
            for ent in named_entities:
                tmp_ = copy.deepcopy(ent)
                tmp_["text"] = get_translation(ent["text"],language)[0][language]
                tmp_entities.append(tmp_)
            named_entity_obj[language]=tmp_entities

    # sentiment
    sentiment, score = get_sentiment(summary)
    return translated, named_entity_obj, sentiment, score
    


# In[ ]:


def contains_keywords(text, query_optional, query_required):
    text = text.lower()

    required_keywords = query_required.split("AND")
    
    required_flag = True
    for keyword in required_keywords:
        if not(keyword.lower() in text):
            return False # no required words present

    # check optional words only if required ones present (or empty)
    optional_flag = False
    optional_keywords = query_optional.split("OR")
    for keyword in optional_keywords:
        if keyword.lower() in text: 
            return True # required words there (or empty) and some optional words
    
    # required words there but no optional words
    
    return (required_flag or optional_flag)


# In[ ]:


def process_feed(news_feed, container, target_languages, query_optional, query_required, topic, subtopic):
    rss_fields = ['link', 'title', 'summary', 'published_parsed', 'img']
    res = []
    feed_name = news_feed.feed.title

    for entry in news_feed.entries:
        
        id_str = str(hash(news_feed.feed.title + entry["title"])) # unique identifier for cosmos db
        
        if is_new_entry(id_str, container):
            # process this news feed only if not processed before

            article_json = {}
            article_json['news_feed'] = feed_name
            article_json['id'] = id_str

            current_timestamp = datetime.now() # time inserted to cosmos db, for change data capture 
            timestamp_int = int(time.mktime(current_timestamp.timetuple()))
            timestamp_string = current_timestamp.strftime("%m/%d/%Y, %H:%M:%S %Z")
            article_json['inserted_to_CosmosDB_at'] = timestamp_string
            article_json['inserted_to_CosmosDB_ts'] = timestamp_int
            article_json['month_year'] = str(current_timestamp.month) + "_" + str(current_timestamp.year)

            matched = False

            for field in rss_fields:
                value = entry.get(field, "")
                
                if field == 'title':
                    processed_title = process_title(value, target_languages) # title translated to target languages
                    article_json['title_translated'] = processed_title
                    article_json['title'] = value
                
                elif field == 'summary':
                    if value: 
                        if "img alt" in value: # elwatan summary seems to contain img tag in summary field 
                            value = value[value.find(">")+1:].lstrip("\n").lstrip() # extract summary
                            print(value)
                        processed_summary = process_summary(value, target_languages)                     
                        translations, ner, sentiment, score = processed_summary
                        article_json['summary'] = value
                        article_json['summary_translations'] = translations
                        article_json['summary_ner'] = ner
                        article_json['sentiment'] = sentiment
                        article_json['sentiment_score'] = score

                        # check if had query match
                        if contains_keywords(translations["en"], query_optional, query_required): # always need the english translation. Searching for keywords in english only for now
                            matched = True
                    else: # no summary found
                        article_json['summary'] = ""
                        article_json['summary_translations'] = {k:"" for k in target_languages}
                        article_json['summary_ner'] = {k:[] for k in target_languages}
                        article_json['sentiment'] = ""
                        article_json['sentiment_score'] = 0 
                        matched = True
                        
                elif field == "published_parsed" and value:
                    published_ts = int(time.mktime(value))
                    article_json['published_ts'] = published_ts
                    article_json['published_ts_str'] = (datetime.fromtimestamp(published_ts)).strftime("%m/%d/%Y, %H:%M:%S %Z")
                
                elif field == "img":
                    if value != "":
                        article_json["img"] = value["src"] # the dict also contains the alt text - ideally should store that too, in all the target languages
                        print(value["src"])
                    else:
                        article_json["img"] = ""
                else:
                    article_json[field] = value

            if matched:
                # assign topic/subtopic
                article_json["topic"] = topic
                article_json["subtopic"] = subtopic    
                
                res.append(article_json)
        
    return res


# In[ ]:


def update_cosmos(objects, container): # insert to cosmos
    for obj in objects:
        try:
            response = container.upsert_item(body=obj) # use upsert so that insert or update
            print("Inserted to cosmos")
        except: 
            print("Unable to insert")


# In[ ]:


news_feed = feedparser.parse(feed_source)
res = process_feed(news_feed, rss_container_client, target_languages, query_optional, query_required, topic, subtopic)



# In[ ]:


update_cosmos(res, rss_container_client)

