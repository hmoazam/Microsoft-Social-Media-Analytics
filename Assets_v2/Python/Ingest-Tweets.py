#!/usr/bin/env python
# coding: utf-8

# In[ ]:


query = ""
# https://developer.twitter.com/en/docs/twitter-api/v1/rules-and-filtering/search-operators - query reference
users = ""
topic = ""
subtopic = ""
query_language = "All"
target_languages = "English,Arabic"
num_tweets = 100
days = 7


# In[ ]:


LANGUAGE_CODES={"All":"","Afrikaans":"af","Arabic":"ar","Assamese":"as","Bangla":"bn","Bosnian(Latin)":"bs","Bulgarian":"bg","Cantonese(Traditional)":"yue","Catalan":"ca","Chinese Simplified":"zh-Hans","Chinese Traditional":"zh-Hant","Croatian":"hr","Czech":"cs","Dari":"prs","Danish":"da","Dutch":"nl","English":"en","Estonian":"et","Fijian":"fj","Filipino":"fil","Finnish":"fi","French":"fr","German":"de","Greek":"el","Gujarati":"gu","Haitian Creole":"ht","Hebrew":"he","Hindi":"hi","Hmong Daw":"mww","Hungarian":"hu","Icelandic":"is","Indonesian":"id","Irish":"ga","Italian":"it","Japanese":"ja","Kannada":"kn","Kazakh":"kk","Klingon":"tlh-Latn","Klingon(plqaD)":"tlh-Piqd","Korean":"ko","Kurdish(Central)":"ku","Kurdish(Northern)":"kmr","Latvian":"lv","Lithuanian":"lt","Malagasy":"mg","Malay":"ms","Malayalam":"ml","Maltese":"mt","Maori":"mi","Marathi":"mr","Norwegian":"nb","Odia":"or","Pashto":"ps","Persian":"fa","Polish":"pl","Portuguese(Brazil)":"pt-br","Portuguese(Portugal)":"pt-pt","Punjabi":"pa","Queretaro Otomi":"otq","Romanian":"ro","Russian":"ru","Samoan":"sm","Serbian(Cyrillic)":"sr-Cyrl","Serbian(Latin)":"sr-Latn","Slovak":"sk","Slovenian":"sl","Spanish":"es","Swahili":"sw","Swedish":"sv","Tahitian":"ty","Tamil":"ta","Telugu":"te","Thai":"th","Tongan":"to","Turkish":"tr","Ukrainian":"uk","Urdu":"ur","Vietnamese":"vi","Welsh":"cy","Yucatec Maya":"yua"}
topic = topic.lower()
# username = user
userslist = users.split(',')
query_language = LANGUAGE_CODES.get(query_language, "")
target_languages = [LANGUAGE_CODES.get(lang, "") for lang in target_languages.split(",")]
if "en" not in target_languages:
  target_languages.append("en") # we always include english in target languages
num_tweets = int(num_tweets)
max_days = int(days)


# In[ ]:


assert (query == "") or (users == "") # Can either search by query or by user, not both


# In[ ]:


%run "config"


# In[ ]:


%run "common"


# In[ ]:


import re
import sys
import copy
import tweepy
import urllib.parse
import sys, time, json, requests, uuid

from tweepy import API
from tweepy import Cursor
from tweepy import OAuthHandler

from dateutil.parser import parse
from datetime import datetime, date, timedelta # don't import time here. It messes with the default library

from azure.cosmos import CosmosClient
from azure.core.credentials import AzureKeyCredential
from azure.ai.textanalytics import TextAnalyticsClient


# In[ ]:


client = CosmosClient(COSMOS_URL, {'masterKey': COSMOS_KEY})
database = client.get_database_client(COSMOS_DATABASE_NAME)

tweet_container_client = database.get_container_client(container=COSMOS_CONTAINER_NAME)


# In[ ]:


auth = tweepy.OAuthHandler(TWITTER_API_KEY, TWITTER_API_SECRET_KEY)
auth.set_access_token(TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_TOKEN_SECRET)
auth_api = API(auth, wait_on_rate_limit=True, wait_on_rate_limit_notify=True)


# In[ ]:


regions = ["Africa","Arabian Gulf","Asia","Central America","Europe","Middle East","North America","Oceania","South America"]


# In[ ]:


def remove_emojis(data):
    emoji = re.compile("["
        u"\U0001F600-\U0001F64F"  # emoticons
        u"\U0001F300-\U0001F5FF"  # symbols & pictographs
        u"\U0001F680-\U0001F6FF"  # transport & map symbols
        u"\U0001F1E0-\U0001F1FF"  # flags (iOS)
        u"\U00002500-\U00002BEF"  # chinese char
        u"\U00002702-\U000027B0"
        u"\U00002702-\U000027B0"
        u"\U000024C2-\U0001F251"
        u"\U0001f926-\U0001f937"
        u"\U00010000-\U0010ffff"
        u"\u2640-\u2642" 
        u"\u2600-\u2B55"
        u"\u200d"
        u"\u23cf"
        u"\u23e9"
        u"\u231a"
        u"\ufe0f"  # dingbats
        u"\u3030"
        "]+", re.UNICODE)
    return re.sub(emoji, '', data)


# In[ ]:



def build_entry(topic, status, query_search, container, query_language=None, target_languages=[], username=""):
    tweet = status._json
    id_str = str(int(tweet["id_str"])+abs(hash(topic)))
    # Check for tweets which have already been added
    search_query = 'select * from items where items.id="{0}"'.format(id_str)
    items = list(container.query_items(search_query,enable_cross_partition_query=True))

    dt2 = datetime.now()
    ts = int(time.mktime(dt2.timetuple()))
    at = dt2.strftime("%m/%d/%Y, %H:%M:%S %Z")
    tweet['inserted_to_CosmosDB_at'] = at
    tweet['inserted_to_CosmosDB_ts'] = ts

    new_tweet = True
    if len(items) > 0:
        # For existing tweets, assuming tweet text the same, so don't re-process
        # Update only the retweet and favorite counts 
        print("Old Tweet")
        updatedtweet = items[0]
        updatedtweet["retweet_count"] = tweet["retweet_count"]
        updatedtweet["favorite_count"] = tweet["favorite_count"]
        tweet = updatedtweet
        user_obj = None # don't need to re-insert the user if already seen before
        new_tweet = False
    elif not(tweet["full_text"].lower().startswith("rt ")):
        print("New Tweet")
        new_tweet = True
        tweet["originalid"] = tweet["id"]
        tweet["id"] = str(int(tweet["id_str"])+abs(hash(topic))) # artifically creating our own ID
        tweet["topickey"] = topic
        tweet["subtopic"] = subtopic
        tweet["month_year"] = str(str(parse(tweet["created_at"]).month) + "_"+str(parse(tweet["created_at"]).year))
        tweet["replies"]=[] # check if we want to keep this like this
        tmp_text = tweet["full_text"].replace('\n','. ').replace('\r','.').replace('..','. ').replace(',.','. ').replace(';.','. ').replace('?.','. ').replace('!.','. ').replace(':.','. ').lstrip('.').lstrip(' ')
        tmp_text = remove_emojis(tmp_text)
        tweet["text"]= tmp_text
        tweet["document_type"] = "tweet"
        if query_search:
            tweet["search_type"]='Topic Search'  
            tweet["query"] = query
        else:
            tweet["search_type"]='User Search'
            tweet["searched_username"]=username
        tweet_text = tweet["text"]
        # get translation
        if not(query_language):
            # will depend on language detection from the translator call
            translations, query_language = get_translation(tweet_text, target_languages)
        else:
            translations, _ = get_translation(tweet_text, target_languages)
        tweet["translations"] = translations
        # get named entities. Arabic only supports Person, Location and Organization entities, and seems to be poor, so doing NER on English text
        named_entity_obj = {}
        if query_language != "en":
            named_entities = get_ner(translations["en"])
            org_language_entities = []
            for ent in named_entities:
                org_language_ent = copy.deepcopy(ent)
                org_language_ent["text"] = get_translation(ent["text"], query_language)[0][query_language] # replace with original language text
                org_language_entities.append(org_language_ent)
            named_entity_obj[query_language] = org_language_entities
        else:
            named_entities = get_ner(tweet_text) # list of objects where each object corresponds to an entity
                 
        # add location information from azure maps
        named_entities_with_location = []
        for ent in named_entities:
            new_ent = copy.deepcopy(ent)
            if ent["category"] == "Location" and ent["subcategory"] == "GPE":
                ent_text = ent["text"]
                if ent_text not in regions:
                    # pass to Azure Maps to get country
                    r_json = get_maps_response(ent_text)
                    if r_json: # i.e. got a response
                        if r_json["summary"]["numResults"] > 0:
                            if "address" in r_json['results'][0].keys():
                                top_match = r_json['results'][0]["address"]
                                if "country" in top_match.keys() and "countryCode" in top_match.keys() :
                                    # there is a location detected, so get the country
                                    country = top_match["country"]
                                    country_code = top_match["countryCode"]
                                    new_ent["country_azuremaps"] = country
                                    new_ent["country_code_azuremaps"] = country_code
            named_entities_with_location.append(new_ent)
        named_entity_obj["en"] = named_entities_with_location
        for language in target_languages:
            if language != "en":
                tmp_entities = []
                for ent in named_entities:
                    tmp_ = copy.deepcopy(ent)
                    tmp_["text"] = get_translation(ent["text"],language)[0][language]
                    tmp_entities.append(tmp_)
                named_entity_obj[language]=tmp_entities
        tweet["named_entities"] = named_entity_obj
        # get sentiment. Not supported for arabic, so do on english. No need to translate back
        if query_language != "en":
            sentiment, sentiment_score = get_sentiment(translations["en"])
        else:
            sentiment, sentiment_score = get_sentiment(tweet_text)
        tweet["sentiment"] = {"sentiment": sentiment, "score": sentiment_score}
        user_obj = tweet["user"]
        user_obj["topickey"] = topic
        user_obj["id"] = user_obj["id_str"]
        user_obj["document_type"] = "user"
        user_obj['inserted_to_CosmosDB_at'] = at
        user_obj['inserted_to_CosmosDB_ts'] = ts
        user_obj["month_year"] = str(str(parse(user_obj["created_at"]).month) + "_"+str(parse(user_obj["created_at"]).year))
        user_location = tweet["user"]["location"]
        if user_location != "" and user_location not in regions:
            r_json = get_maps_response(user_location)
            if r_json: # i.e. got a response
                if r_json["summary"]["numResults"] > 0:
                    # there is a location detected, so get the country
                    if "address" in r_json['results'][0].keys():
                        top_match = r_json['results'][0]["address"]
                        if "country" in top_match.keys() and "countryCode" in top_match.keys():
                            country = top_match["country"]
                            country_code = top_match["countryCode"]
                            user_obj["country_azuremaps"] = country
                            user_obj["country_code_azuremaps"] = country_code
        tweet["userid"]=user_obj["id"]
    else:
        return None, None, False
    return tweet, user_obj, new_tweet
def process_tweets(topic="", query="", language="en", maxdays=365, maxtweets_persearch=1, user="", query_search=True, container=None, target_languages=[], username=""):
    print("Working on topic: " + topic)
    end_date = datetime.utcnow() - timedelta(days=maxdays)
    all_tweets = []
    all_users = []
    count = 0
    # Reference: https://docs.tweepy.org/en/stable/api.html#API.search
    if query_search:
    # searching based on the query string
        if language:
            for status in Cursor(auth_api.search, q=query, lang=language, result='recent', tweet_mode = "extended", include_rts='False').items(maxtweets_persearch):
                count += 1
                tweet_obj, user_obj, new_tweet = build_entry(topic, status, query_search, container, language, target_languages)
                print(new_tweet)
                all_tweets.append(tweet_obj)
                if new_tweet:
                    all_users.append(user_obj)
                if status.created_at < end_date:
                    break
            print("Found "+str(count) +" tweets for query: "+ query)
            return all_tweets, all_users
        else: # search for tweets regardless of tweet language
            for status in Cursor(auth_api.search, q=query, result='recent', tweet_mode='extended').items(maxtweets_persearch):
                count += 1
                tweet_obj, user_obj, new_tweet = build_entry(topic, status, query_search, container, query_language=None, target_languages=target_languages)
                all_tweets.append(tweet_obj)
                all_users.append(user_obj)
                if status.created_at < end_date:
                    break 
            print("Found "+str(count) +" tweets for query: "+ query)
            return all_tweets, all_users
    else:
    # getting tweets by user
        for status in Cursor(auth_api.user_timeline, id=user, result='recent', tweet_mode = "extended").items(maxtweets_persearch): # this actually only returns the last 20 tweets by the user
            count += 1
            tweet_obj, user_obj, new_tweet = build_entry(topic, status, query_search, container, query_language=None, target_languages=target_languages, username=username)
            all_tweets.append(tweet_obj)
            print(new_tweet)
            if new_tweet:
                all_users.append(user_obj) # todo: optimize so not re-inserting the same user
            if status.created_at < end_date:
                break
        print("Found "+str(count) +" tweets for user: "+ user)
        return all_tweets, all_users


# In[ ]:


if users == "": # query search
    all_tweets, all_users = process_tweets(topic, query, query_language, maxdays=max_days, maxtweets_persearch=num_tweets, user="", query_search=True, container=tweet_container_client, target_languages=target_languages)
    update_cosmos(all_tweets, tweet_container_client) # insert tweets
    update_cosmos(all_users, tweet_container_client) # insert users
else: # user search
    for usr in userslist:
        all_tweets, all_users = process_tweets(topic, user=usr, maxdays=max_days, maxtweets_persearch=num_tweets, query_search=False, container=tweet_container_client, target_languages=target_languages, username=usr)
        update_cosmos(all_tweets, tweet_container_client) # insert tweets
        update_cosmos(all_users, tweet_container_client) # insert users


