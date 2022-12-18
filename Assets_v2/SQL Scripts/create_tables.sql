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