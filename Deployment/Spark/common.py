#!/usr/bin/env python
# coding: utf-8


# In[5]:


%run "config"


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
# TODO: Add opinion mining
def get_sentiment(inp_text):
    #Parameters: 
    #  inp_text: text to analyze
    #Returns:
    #  sentiment, sentiment score
    documents = [inp_text]
    response = text_analytics_client.analyze_sentiment(documents = documents)[0]  
    try:
        overallscore = response.confidence_scores.positive + (0.5*response.confidence_scores.neutral) # check logic of this
        return response.sentiment, overallscore
    except Exception as err:
        print("Encountered Sentiment exception. {}".format(err))
        return "Neutral",0.5
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
        print("Encountered NER exception. {}".format(err))
    return []
def get_key_phrases(inp_text):
    #Parameters: 
    #  inp_text: text to analyze
    #Returns:
    #  List of key phrases
    try:
      documents = [inp_text]
      response = text_analytics_client.extract_key_phrases(documents = documents)[0] 
      if not response.is_error:
          return response.key_phrases
      else:
          print(response.id, response.error)
    except Exception as err:
      print("Encountered Translation exception. {}".format(err))
    return []


# In[ ]:


def update_cosmos(objects, container): # insert tweets/users to cosmos
    for obj in objects:
        if obj:
            response = container.upsert_item(body=obj) # use upsert so that insert or update
    print("Inserted data to cosmos")


# In[ ]:


# Tweet Entities processing
import requests
import aiohttp
import asyncio
import json

def get_maps_response(inp):
    url = "https://atlas.microsoft.com/search/fuzzy/json?&subscription-key="+MAPS_KEY+"&api-version=1.0&language=en-US&query="+inp
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()


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
        #res[from_language] = inp_text # also include the original text and language in translations - overkill?
        return res, from_language # return the translated text, as well as the language it was translated from
    except Exception as err:
        print("Encountered an exception. {}".format(err))
        return None, None

