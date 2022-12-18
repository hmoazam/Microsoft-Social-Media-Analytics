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