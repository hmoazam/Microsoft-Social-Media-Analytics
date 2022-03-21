IF NOT EXISTS(SELECT 1 FROM sys.schemas where name = 'stg')
EXEC ('CREATE SCHEMA stg')

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='Articles')
CREATE TABLE [dbo].[Articles]
( 
	[id] [nvarchar](500)  NOT NULL,
	[topic] [nvarchar](200)  NULL,
	[subtopic] [nvarchar](200)  NULL,
	[title] [nvarchar](4000)  NULL,
	[author] [varchar](4000)  NULL,
	[description] [nvarchar](4000)  NULL,
	[urlToImage] [nvarchar](4000)  NULL,
	[url] [nvarchar](4000)  NULL,
	[content] [nvarchar](4000)  NULL,
	[publishedAt] [datetime2](7)  NULL,
	[inserted_datetime] [datetime2](7)  NULL,
	[inserted_to_CosmosDB_datetime] [datetime2](7)  NULL,
	[inserted_to_CosmosDB_ts] [bigint]  NULL,
	[Type] [nvarchar](200)  NULL,
	[domainname] [nvarchar](500)  NULL,
	[sourceName] [nvarchar](500)  NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='ArticlesEntities')
CREATE TABLE [dbo].[ArticlesEntities]
( 
	[id] [nvarchar](500)  NOT NULL,
	[language] [nvarchar](500)  NULL,
	[category] [nvarchar](500)  NOT NULL,
	[subcategory] [nvarchar](500)  NULL,
	[value] [nvarchar](2000)  NOT NULL,
	[confidence_score] [float]  NOT NULL,
	[created_datetime] [datetime2](7)  NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='ArticlesSentiments')
CREATE TABLE [dbo].[ArticlesSentiments]
( 
	[id] [nvarchar](500)  NOT NULL,
	[sentiment] [nvarchar](300)  NOT NULL,
	[overallscore] [decimal](12,2)  NOT NULL,
	[created_datetime] [datetime2](7)  NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='ArticlesTranslations')
CREATE TABLE [dbo].[ArticlesTranslations]
( 
	[id] [nvarchar](500)  NOT NULL,
	[Language] [nvarchar](50)  NOT NULL,
	[Title] [nvarchar](4000)  NOT NULL,
	[Description] [nvarchar](4000)  NOT NULL,
	[Content] [nvarchar](4000)  NOT NULL,
	[created_datetime] [datetime2](7)  NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='CountryCoordinates')
CREATE TABLE [dbo].[CountryCoordinates]
( 
	[COUNTRY_CODE] [nvarchar](50)  NULL,
	[COUNTRY_NAME] [nvarchar](200)  NULL,
	[Latitude] [nvarchar](50)  NULL,
	[Longitude] [nvarchar](50)  NULL
)
WITH
(
	DISTRIBUTION = HASH ( [COUNTRY_CODE] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='Handles')
CREATE TABLE [dbo].[Handles]
( 
	[id] [nvarchar](200)  NOT NULL,
	[handles] [nvarchar](200)  NOT NULL,
	[created_datetime] [datetime2](7)  NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='Hashtags')
CREATE TABLE [dbo].[Hashtags]
( 
	[id] [nvarchar](200)  NOT NULL,
	[hashtags] [nvarchar](200)  NOT NULL,
	[created_datetime] [datetime2](7)  NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='RSSArticles')
CREATE TABLE [dbo].[RSSArticles]
( 
	[id] [nvarchar](500)  NOT NULL,
	[source] [nvarchar](200)  NULL,
	[title] [nvarchar](4000)  NULL,
	[summary] [nvarchar](4000)  NULL,
	[url] [nvarchar](4000)  NULL,
	[img_url] [nvarchar](4000)  NULL,
	[published_at] [datetime2](7)  NULL,
	[inserted_datetime] [datetime2](7)  NULL,
	[inserted_to_CosmosDB_datetime] [datetime2](7)  NULL,
	[inserted_to_CosmosDB_ts] [bigint]  NULL,
	[topic] [nvarchar](200)  NULL,
	[subtopic] [nvarchar](200)  NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='RSSArticlesEntities')
CREATE TABLE [dbo].[RSSArticlesEntities]
( 
	[id] [nvarchar](500)  NOT NULL,
	[language] [nvarchar](500)  NULL,
	[category] [nvarchar](500)  NOT NULL,
	[subcategory] [nvarchar](500)  NULL,
	[value] [nvarchar](2000)  NOT NULL,
	[confidence_score] [float]  NOT NULL,
	[created_datetime] [datetime2](7)  NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='RSSArticlesSentiments')
CREATE TABLE [dbo].[RSSArticlesSentiments]
( 
	[id] [nvarchar](500)  NOT NULL,
	[sentiment] [nvarchar](300)  NOT NULL,
	[overallscore] [decimal](12,2)  NOT NULL,
	[created_datetime] [datetime2](7)  NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='RSSArticlesTranslations')
CREATE TABLE [dbo].[RSSArticlesTranslations]
( 
	[id] [nvarchar](500)  NOT NULL,
	[Language] [nvarchar](50)  NOT NULL,
	[Title] [nvarchar](4000)  NOT NULL,
	[Summary] [nvarchar](4000)  NOT NULL,
	[created_datetime] [datetime2](7)  NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='Sentiments')
CREATE TABLE [dbo].[Sentiments]
( 
	[id] [nvarchar](200)  NOT NULL,
	[sentiment] [nvarchar](300)  NOT NULL,
	[overallscore] [decimal](12,2)  NOT NULL,
	[created_datetime] [datetime2](7)  NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='Translations')
CREATE TABLE [dbo].[Translations]
( 
	[id] [nvarchar](200)  NOT NULL,
	[Language] [nvarchar](50)  NOT NULL,
	[Text] [nvarchar](4000)  NOT NULL,
	[created_datetime] [datetime2](7)  NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='TweetMedia')
CREATE TABLE [dbo].[TweetMedia]
( 
	[id] [nvarchar](200)  NOT NULL,
	[media] [nvarchar](1000)  NOT NULL,
	[created_datetime] [datetime2](7)  NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='Tweets')
CREATE TABLE [dbo].[Tweets]
( 
	[id] [nvarchar](200)  NOT NULL,
	[text] [nvarchar](4000)  NULL,
	[userid] [nvarchar](200)  NULL,
	[topic] [nvarchar](200)  NULL,
	[subtopic] [nvarchar](200)  NULL,
	[city] [nvarchar](1000)  NULL,
	[country] [nvarchar](1000)  NULL,
	[retweets] [bigint]  NOT NULL,
	[likes] [bigint]  NULL,
	[lang] [nvarchar](50)  NULL,
	[worthinessScore] [bigint]  NULL,
	[fullSource] [nvarchar](4000)  NULL,
	[Source] [nvarchar](4000)  NULL,
	[factCheckURL] [nvarchar](4000)  NULL,
	[tweetURL] [nvarchar](2000)  NULL,
	[isRetweet] [nvarchar](100)  NULL,
	[possibleNews] [nvarchar](100)  NULL,
	[replyToStatus] [bigint]  NULL,
	[replyToUser] [bigint]  NULL,
	[created_date] [date]  NULL,
	[created_datetime] [datetime2](7)  NULL,
	[inserted_to_CosmosDB_datetime] [datetime2](7)  NULL,
	[inserted_to_CosmosDB_ts] [bigint]  NULL,
	[inserted_datetime] [datetime2](7)  NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='TweetsEntities')
CREATE TABLE [dbo].[TweetsEntities]
( 
	[id] [nvarchar](200)  NOT NULL,
	[category] [nvarchar](100)  NOT NULL,
	[subcategory] [nvarchar](100)  NULL,
	[value] [nvarchar](2000)  NOT NULL,
	[Language] [nvarchar](500)  NULL,
	[confidence_score] [float]  NOT NULL,
	[created_datetime] [datetime2](7)  NOT NULL,
	[country_azuremaps] [nvarchar](50)  NULL,
	[country_code_azuremaps] [nvarchar](200)  NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='TweetURLs')
CREATE TABLE [dbo].[TweetURLs]
( 
	[id] [nvarchar](200)  NOT NULL,
	[URL] [nvarchar](2000)  NOT NULL,
	[Expanded_URL] [nvarchar](2000)  NOT NULL,
	[display_URL] [nvarchar](2000)  NOT NULL,
	[created_datetime] [datetime2](7)  NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name ='Users')
CREATE TABLE [dbo].[Users]
( 
	[id] [nvarchar](200)  NOT NULL,
	[name] [nvarchar](1000)  NULL,
	[screen_name] [nvarchar](1000)  NULL,
	[location] [nvarchar](1000)  NULL,
	[description] [nvarchar](1000)  NULL,
	[followers_count] [bigint]  NULL,
	[friends_count] [bigint]  NULL,
	[favourites_count] [bigint]  NULL,
	[listed_count] [bigint]  NULL,
	[statuses_count] [bigint]  NULL,
	[isFollowing] [bit]  NULL,
	[verified] [bit]  NULL,
	[geoEnabled] [bit]  NULL,
	[language] [nvarchar](50)  NULL,
	[url] [nvarchar](1000)  NULL,
	[profile_image_url] [nvarchar](1000)  NULL,
	[background_image_url] [nvarchar](1000)  NULL,
	[profile_banner_url] [nvarchar](1000)  NULL,
	[created_date] [date]  NULL,
	[created_datetime] [datetime2](7)  NULL,
	[inserted_datetime] [datetime2](7)  NULL,
	[inserted_to_CosmosDB_datetime] [datetime2](7)  NULL,
	[inserted_to_CosmosDB_ts] [bigint]  NULL,
	[last_updated_datetime] [datetime2](7)  NULL,
	[last_updated_ts] [bigint]  NULL,
	[country_azuremaps] [nvarchar](50)  NULL,
	[country_code_azuremaps] [nvarchar](200)  NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.procedures where name = 'FromStgToMain_NewsArticles')
DROP PROC [dbo].[FromStgToMain_NewsArticles] 
GO

CREATE PROC [dbo].[FromStgToMain_NewsArticles] AS
BEGIN 
	INSERT [dbo].[Articles]([id],[topic],[subtopic], [sourceName], [author], [title], [description], [url], [urlToImage], [content], [publishedAt], [inserted_to_CosmosDB_datetime], [inserted_to_CosmosDB_ts],[domainname],[type])
	SELECT [id],[topic],[subtopic], [sourceName], [author], [title], [description], [url], [urlToImage], [content], [publishedAt], [inserted_to_CosmosDB_datetime], [inserted_to_CosmosDB_ts],[domainname],[type] 
	FROM [stg].[Articles]
	WHERE id not in (SELECT id FROM [dbo].[Articles]);
	DROP TABLE [stg].[Articles];

	INSERT [dbo].[ArticlesEntities]([id], [category], [subcategory], [value], [language], [confidence_score], [created_datetime])
	SELECT [id], [category], [subcategory], [value], [language], [confidence_score], [created_datetime] 
	FROM [stg].[ArticlesEntities]
	WHERE id not in (SELECT id FROM [dbo].[ArticlesEntities]);
	DROP TABLE [stg].[ArticlesEntities];

	INSERT [dbo].[ArticlesSentiments]  ([id],[sentiment],[overallscore], [created_datetime])
	select [id],[sentiment],[overallscore], [created_datetime]
	from [stg].[ArticlesSentiments] WHERE id not in (SELECT id FROM [dbo].[ArticlesSentiments]);
	DROP TABLE [stg].[ArticlesSentiments];

	INSERT [dbo].[ArticlesTranslations]  ([id], [Language],[Title], [Description], [Content], [created_datetime])
	select [id], [Language],[Title], [Description], [Content], [created_datetime]
	from [stg].[ArticlesTranslations] WHERE id not in (SELECT id FROM [dbo].[ArticlesTranslations]);
	DROP TABLE [stg].[ArticlesTranslations];

END;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.procedures where name = 'FromStgToMain_NewsArticles_Cleanup')
DROP PROC [dbo].[FromStgToMain_NewsArticles_Cleanup] 
GO

CREATE PROC [dbo].[FromStgToMain_NewsArticles_Cleanup] AS
BEGIN
BEGIN TRY
    SELECT TOP 1 * FROM [stg].[Articles]
    DROP TABLE [stg].[Articles];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[ArticlesEntities]
    DROP TABLE [stg].[ArticlesEntities];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[ArticlesSentiments]
    DROP TABLE [stg].[ArticlesSentiments];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[ArticlesTranslations]
    DROP TABLE [stg].[ArticlesTranslations];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF EXISTS(SELECT 1 FROM sys.procedures where name = 'FromStgToMain_RSSArticles')
DROP PROC [dbo].[FromStgToMain_RSSArticles] 
GO

CREATE PROC [dbo].[FromStgToMain_RSSArticles] AS
BEGIN 
	INSERT [dbo].[RSSArticles]([id],[source],[title], [summary], [url], [img_url], [published_at], [inserted_datetime], [inserted_to_CosmosDB_datetime], [inserted_to_CosmosDB_ts], [topic], [subtopic])
	SELECT [id],[source],[title], [summary], [url], [img_url], [published_at], [inserted_datetime], [inserted_to_CosmosDB_datetime], [inserted_to_CosmosDB_ts], [topic], [subtopic] 
	FROM [stg].[RSSArticles]
	WHERE id not in (SELECT id FROM [dbo].[RSSArticles]);
	DROP TABLE [stg].[RSSArticles];

	INSERT [dbo].[RSSArticlesEntities]([id], [language], [category], [subcategory], [value], [confidence_score], [created_datetime])
	SELECT [id], [language], [category], [subcategory], [value], [confidence_score], [created_datetime] 
	FROM [stg].[RSSArticlesEntities]
	WHERE id not in (SELECT id FROM [dbo].[RSSArticlesEntities]);
	DROP TABLE [stg].[RSSArticlesEntities];

	INSERT [dbo].[RSSArticlesSentiments]  ([id],[sentiment],[overallscore], [created_datetime])
	select [id],[sentiment],[overallscore], [created_datetime]
	from [stg].[RSSArticlesSentiments] WHERE id not in (SELECT id FROM [dbo].[ArticlesSentiments]);
	DROP TABLE [stg].[RSSArticlesSentiments];

	INSERT [dbo].[RSSArticlesTranslations]  ([id], [Language], [Title], [Summary], [created_datetime])
	select [id], [Language], [Title], [Summary], [created_datetime]
	from [stg].[RSSArticlesTranslations] WHERE id not in (SELECT id FROM [dbo].[ArticlesTranslations]);
	DROP TABLE [stg].[RSSArticlesTranslations];

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.procedures where name = 'FromStgToMain_RSSArticles_Cleanup')
DROP PROC [dbo].[FromStgToMain_RSSArticles_Cleanup] 
GO

CREATE PROC [dbo].[FromStgToMain_RSSArticles_Cleanup] AS
BEGIN
BEGIN TRY
    SELECT TOP 1 * FROM [stg].[RSSArticles]
    DROP TABLE [stg].[RSSArticles];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[RSSArticlesEntities]
    DROP TABLE [stg].[RSSArticlesEntities];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[RSSArticlesSentiments]
    DROP TABLE [stg].[RSSArticlesSentiments];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[RSSArticlesTranslations]
    DROP TABLE [stg].[RSSArticlesTranslations];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH


END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.procedures where name = 'FromStgToMain_Tweets')
DROP PROC [dbo].[FromStgToMain_Tweets] 
GO

CREATE PROC [dbo].[FromStgToMain_Tweets] AS
BEGIN

INSERT [dbo].[Tweets]  ([id],[text],[userid],[topic],[subtopic],[city],[country],[retweets],[likes],[lang],[worthinessScore],[fullSource],[Source],[factCheckURL],[tweetURL],[isRetweet],[possibleNews],[replyToStatus],[replyToUser],[created_date],[created_datetime],[inserted_to_CosmosDB_datetime],[inserted_to_CosmosDB_ts],[inserted_datetime])
SELECT [id],[text],[userid],[topic],[subtopic],[city],[country],[retweets],[likes],[lang],[worthinessScore],[fullSource],[Source],[factCheckURL],[tweetURL],[isRetweet],[possibleNews],[replyToStatus],[replyToUser],[created_date],[created_datetime],[inserted_to_CosmosDB_datetime],[inserted_to_CosmosDB_ts],[inserted_datetime] 
FROM [stg].[Tweets] WHERE id not in (SELECT id FROM [dbo].[Tweets]);
UPDATE [dbo].[Tweets] SET [retweets] = stg.[retweets],[likes] = stg.[likes],
 [worthinessScore] = stg.[worthinessScore], [fullSource] = stg.[fullSource], [Source] = stg.[Source], [possibleNews] = stg.[possibleNews], [inserted_to_CosmosDB_datetime] = stg.[inserted_to_CosmosDB_datetime], [inserted_to_CosmosDB_ts] = stg.[inserted_to_CosmosDB_ts], [inserted_datetime] = stg.[inserted_datetime]
FROM [stg].[Tweets] stg
JOIN [dbo].[Tweets] tst ON tst.id=stg.id;
DROP TABLE [stg].[Tweets];

INSERT [dbo].[Hashtags]  ([id],[hashtags],[created_datetime])
SELECT [id],[hashtags],[created_datetime] 
FROM [stg].[Hashtags] WHERE id not in (SELECT id FROM [dbo].[Hashtags]);
DROP TABLE [stg].[Hashtags];

INSERT [dbo].[Handles]  ([id],[handles],[created_datetime])
SELECT [id],[handles],[created_datetime]
FROM [stg].[Handles] WHERE id not in (SELECT id FROM [dbo].[Handles]);
DROP TABLE [stg].[Handles];

INSERT [dbo].[TweetMedia]  ([id],[media],[created_datetime])
select [id],[media],[created_datetime] 
from [stg].[TweetMedia] WHERE id not in (SELECT id FROM [dbo].[TweetMedia]);
DROP TABLE [stg].[TweetMedia];

INSERT [dbo].[Sentiments]  ([id],[sentiment],[overallscore], [created_datetime])
select [id],[sentiment],[overallscore], [created_datetime]
from [stg].[Sentiments] WHERE id not in (SELECT id FROM [dbo].[Sentiments]);
DROP TABLE [stg].[Sentiments];

INSERT [dbo].[TweetURLs]  ([id], [URL], [Expanded_URL], [display_URL], [created_datetime])
select [id], [URL], SUBSTRING([Expanded_URL], 0,500), [display_URL], [created_datetime] 
from [stg].[TweetURLs] WHERE id not in (SELECT id FROM [dbo].[TweetURLs]);
DROP TABLE [stg].[TweetURLs];

INSERT [dbo].[Translations]  ([id], [Language], [Text], [created_datetime])
select [id], [Language], [Text], [created_datetime]
from [stg].[Translations] WHERE id not in (SELECT id FROM [dbo].[Translations]);
DROP TABLE [stg].[Translations];

INSERT [dbo].[TweetsEntities]  ([id], [category], [subcategory], [value], [Language], [confidence_score],[country_azuremaps],[country_code_azuremaps], [created_datetime])
select [id], [category], [subcategory], [value], [Language], [confidence_score],[country_azuremaps],[country_code_azuremaps], [created_datetime]
from [stg].[TweetsEntities] WHERE id not in (SELECT id FROM [dbo].[TweetsEntities]);
DROP TABLE [stg].[TweetsEntities];


END

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.procedures where name = 'FromStgToMain_Tweets_Cleanup')
DROP PROC [dbo].[FromStgToMain_Tweets_Cleanup] 
GO

CREATE PROC [dbo].[FromStgToMain_Tweets_Cleanup] AS
BEGIN
BEGIN TRY
    SELECT TOP 1 * FROM [stg].[Tweets]
    DROP TABLE [stg].[Tweets];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[Hashtags]
    DROP TABLE [stg].[Hashtags];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[Handles]
    DROP TABLE [stg].[Handles];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[TweetMedia]
    DROP TABLE [stg].[TweetMedia];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[Sentiments]
    DROP TABLE [stg].[Sentiments];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[TweetURLs]
    DROP TABLE [stg].[TweetURLs];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[Translations]
    DROP TABLE [stg].[Translations];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH

BEGIN TRY
    SELECT TOP 1 * FROM [stg].[TweetsEntities]
    DROP TABLE [stg].[TweetsEntities];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.procedures where name = 'FromStgToMain_Users')
DROP PROC [dbo].[FromStgToMain_Users] 
GO

CREATE PROC [dbo].[FromStgToMain_Users] AS
BEGIN
INSERT [dbo].[Users]  ([id], [name], [screen_name], [location], [description], [followers_count], [friends_count], [favourites_count], [listed_count], [statuses_count], 
[isFollowing], [verified], [geoEnabled], [language], [url], [profile_image_url], [background_image_url], [profile_banner_url], [created_date], [created_datetime], [inserted_datetime], 
[inserted_to_CosmosDB_datetime], [inserted_to_CosmosDB_ts], [last_updated_datetime], [last_updated_ts],[country_azuremaps],[country_code_azuremaps])
select [id], [name], [screen_name], [location], [description], [followers_count], [friends_count], [favourites_count], [listed_count], [statuses_count], [isFollowing], [verified], [geoEnabled], [language], [url], [profile_image_url], [background_image_url], [profile_banner_url], [created_date], [created_datetime], [inserted_datetime], [inserted_to_CosmosDB_datetime], [inserted_to_CosmosDB_ts], null,null
,[country_azuremaps],[country_code_azuremaps]
from [stg].[Users] WHERE id not in (SELECT id FROM [dbo].[Users]);
UPDATE [dbo].[Users] SET [location] = stg.[location],[description] = stg.[description], [followers_count] = stg.[followers_count], [friends_count] = stg.[friends_count], 
[favourites_count] = stg.[favourites_count], [listed_count] = stg.[listed_count], [statuses_count] = stg.[statuses_count], [isFollowing] = stg.[isFollowing], 
[verified] = stg.[verified],[geoEnabled] = stg.[geoEnabled], [language] = stg.[language], [url] = stg.[url], [profile_image_url] = stg.[profile_image_url], 
[background_image_url] = stg.[background_image_url], [profile_banner_url] = stg.[profile_banner_url], [created_date] = stg.[created_date], 
[inserted_datetime] = stg.[inserted_datetime], [inserted_to_CosmosDB_datetime] = stg.[inserted_to_CosmosDB_datetime], 
[inserted_to_CosmosDB_ts] = stg.[inserted_to_CosmosDB_ts]
FROM [stg].[Users] stg
JOIN [dbo].[Users] tst ON tst.id=stg.id;
DROP TABLE [stg].[Users];

END

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.procedures where name = 'FromStgToMain_Users_Cleanup')
DROP PROC [dbo].[FromStgToMain_Users_Cleanup] 
GO

CREATE PROC [dbo].[FromStgToMain_Users_Cleanup] AS
BEGIN
BEGIN TRY
    SELECT TOP 1 * FROM [stg].[Users]
    DROP TABLE [stg].[Users];
END TRY
BEGIN CATCH
    SELECT NULL
END CATCH
END


GO