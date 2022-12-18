#!/usr/bin/env python
# coding: utf-8

# In[ ]:


#News API
NEWS_API_KEY = TokenLibrary.getSecret("###KeyVaultName###","NEWSAPIKEY","KeyVaultLinkedService")
# Cosmos
COSMOS_URL = TokenLibrary.getSecret("###KeyVaultName###","COSMOSURL","KeyVaultLinkedService")
COSMOS_KEY = TokenLibrary.getSecret("###KeyVaultName###","COSMOSKEY","KeyVaultLinkedService")
COSMOS_DATABASE_NAME = TokenLibrary.getSecret("###KeyVaultName###","COSMOSDATABASENAME","KeyVaultLinkedService")
COSMOS_CONTAINER_NAME = "tweets_and_users"
COSMOS_ARTICLE_CONTAINER_NAME = "articles"
COSMOS_RSS_FEEDS_CONTAINER_NAME = "rss_articles"

# Text analytics
TEXT_ANALYTICS_KEY = TokenLibrary.getSecret("###KeyVaultName###","TEXTANALYTICSKEY","KeyVaultLinkedService")
TEXT_ANALYTICS_ENDPOINT = TokenLibrary.getSecret("###KeyVaultName###","TEXTANALYTICSENDPOINT","KeyVaultLinkedService")
TEXT_ANALYTICS_REGION = "###location###"
# Translator
TRANSLATOR_KEY = TokenLibrary.getSecret("###KeyVaultName###","TRANSLATORKEY","KeyVaultLinkedService")
TRANSLATOR_ENDPOINT = TokenLibrary.getSecret("###KeyVaultName###","TRANSLATORENDPOINT","KeyVaultLinkedService")
TRANSLATOR_REGION = "###location###"
# Twitter
TWITTER_API_KEY = TokenLibrary.getSecret("###KeyVaultName###","TWITTERAPIKEY","KeyVaultLinkedService")
TWITTER_API_SECRET_KEY = TokenLibrary.getSecret("###KeyVaultName###","TWITTERAPISECRETKEY","KeyVaultLinkedService")
TWITTER_ACCESS_TOKEN = TokenLibrary.getSecret("###KeyVaultName###","TWITTERACCESSTOKEN","KeyVaultLinkedService")
TWITTER_ACCESS_TOKEN_SECRET = TokenLibrary.getSecret("###KeyVaultName###","TWITTERACCESSTOKENSECRET","KeyVaultLinkedService")
TWITTER_API_AUTH = {
  'consumer_key': TWITTER_API_KEY,
  'consumer_secret': TWITTER_API_SECRET_KEY,
  'access_token': TWITTER_ACCESS_TOKEN,
  'access_token_secret': TWITTER_ACCESS_TOKEN_SECRET,
}
# Synapse
SQL_ENDPOINT = TokenLibrary.getSecret("###KeyVaultName###","SQLENDPOINT","KeyVaultLinkedService")
SQL_USERNAME = TokenLibrary.getSecret("###KeyVaultName###","SQLUSERNAME","KeyVaultLinkedService")
SQL_PASSWORD = TokenLibrary.getSecret("###KeyVaultName###","SQLPASSWORD","KeyVaultLinkedService")
DB_NAME = TokenLibrary.getSecret("###KeyVaultName###","DBNAME","KeyVaultLinkedService")
# Storage Account
STORAGE_ACCOUNT_NAME = TokenLibrary.getSecret("###KeyVaultName###","STORAGEACCOUNTNAME","KeyVaultLinkedService")
STORAGE_CONTAINER_NAME = TokenLibrary.getSecret("###KeyVaultName###","STORAGECONTAINERNAME","KeyVaultLinkedService")
STORAGE_DIRECTORY_NAME = "synapse"
STORAGE_KEY = TokenLibrary.getSecret("###KeyVaultName###","STORAGEKEY","KeyVaultLinkedService")
# Azure Maps
MAPS_KEY = TokenLibrary.getSecret("###KeyVaultName###","MAPSKEY","KeyVaultLinkedService")


# Synapse workspace name - used in jdbc connection string parameter
SYNAPSE_WORKSPACE_NAME = TokenLibrary.getSecret("###KeyVaultName###","SYNWORKSPACENAME","KeyVaultLinkedService")



# In[ ]:

%%spark
val DB_NAME = TokenLibrary.getSecret("###KeyVaultName###","DBNAME","KeyVaultLinkedService")
