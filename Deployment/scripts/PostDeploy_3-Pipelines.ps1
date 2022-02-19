$newstopic = "News"
$news_query ="Ukraine"


$tweetstopic1 = "News"
$tweets_queries1 = "Ukraine"

$tweetstopic2 = "News"
$tweets_queries2 = "Russia"


############# NEWS ARTICLES

$n1="News Orchestrator - $newstopic 1"
$body = @"
{
    "name": "$n1",
    "properties": {
        "activities": [
            {
                "name": "$newstopic EN",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "Ingest-NewsArticles",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "$news_query",
                            "type": "string"
                        },
                        "topic": {
                            "value": "$newstopic",
                            "type": "string"
                        },
                        "language": {
                            "value": "English",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "French,English",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    }
                }
            },
            {
                "name": "CosmosToSynapse-News Articles",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Cleanup",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "CosmosToSynapse-NewsArticles",
                        "type": "NotebookReference"
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    }
                }
            },
            {
                "name": "Cleanup",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "$newstopic EN",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    },
                    {
                        "activity": "$newstopic FR",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "sqlPool": {
                    "referenceName": "$sqlpoolName",
                    "type": "SqlPoolReference"
                },
                "typeProperties": {
                    "storedProcedureName": "[dbo].[FromStgToMain_NewsArticles_Cleanup]"
                }
            },
            {
                "name": "STG to Main",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "CosmosToSynapse-News Articles",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "sqlPool": {
                    "referenceName": "$sqlpoolName",
                    "type": "SqlPoolReference"
                },
                "typeProperties": {
                    "storedProcedureName": "[dbo].[FromStgToMain_NewsArticles]"
                }
            },
            {
                "name": "$newstopic FR",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "Ingest-NewsArticles",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "$news_query",
                            "type": "string"
                        },
                        "topic": {
                            "value": "$newstopic",
                            "type": "string"
                        },
                        "language": {
                            "value": "French",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "French,English",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    }
                }
            }
        ],
        "concurrency": 1,
        
        "annotations": [],
        "lastPublishTime": "2021-12-04T08:06:06Z"
    },
    "type": "Microsoft.Synapse/workspaces/pipelines"
}
"@ 

$uri = "https://$workspaceName.dev.azuresynapse.net/pipelines/$n1`?api-version=2020-12-01"
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"




############# TWEETS


$n2="Tweets Orchestrator - $newstopic 1"
$body = @"
{
    "name": "$n2",
    "properties": {
        "activities": [
            {
                "name": "$tweetstopic1",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "$tweets_queries1",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "$tweetstopic1",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "French,English",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    }
                }
            },
            {
                "name": "$tweetstopic2",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "$tweets_queries2",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "$tweetstopic2",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "French,English",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    }
                }
            },
	    {
                "name": "CosmosToSynapse-Tweets",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Cleanup",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "CosmosToSynapse-Tweets",
                        "type": "NotebookReference"
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    }
                }
            },
            {
                "name": "From STG to Main",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "CosmosToSynapse-Tweets",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "sqlPool": {
                    "referenceName": "$sqlpoolName",
                    "type": "SqlPoolReference"
                },
                "typeProperties": {
                    "storedProcedureName": "[dbo].[FromStgToMain_Tweets]"
                }
            },
            {
                "name": "Cleanup",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "$tweetstopic1",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    },
                    {
                        "activity": "$tweetstopic2",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "sqlPool": {
                    "referenceName": "$sqlpoolName",
                    "type": "SqlPoolReference"
                },
                "typeProperties": {
                    "storedProcedureName": "[dbo].[FromStgToMain_Tweets_Cleanup]"
                }
            },
            {
                "name": "CosmosToSynapse-Users",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Cleanup_copy1",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "CosmosToSynapse-Users",
                        "type": "NotebookReference"
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    }
                }
            },
            {
                "name": "From STG to Main_copy1",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "CosmosToSynapse-Users",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "sqlPool": {
                    "referenceName": "$sqlpoolName",
                    "type": "SqlPoolReference"
                },
                "typeProperties": {
                    "storedProcedureName": "[dbo].[FromStgToMain_Users]"
                }
            },
            {
                "name": "Cleanup_copy1",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "From STG to Main",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 1,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "sqlPool": {
                    "referenceName": "$sqlpoolName",
                    "type": "SqlPoolReference"
                },
                "typeProperties": {
                    "storedProcedureName": "[dbo].[FromStgToMain_Users_Cleanup]"
                }
            }
        ],
        "concurrency": 1,
        
        "annotations": [],
        "lastPublishTime": "2021-12-04T08:06:33Z"
    },
    "type": "Microsoft.Synapse/workspaces/pipelines"
}
"@ 

$uri = "https://$workspaceName.dev.azuresynapse.net/pipelines/$n2`?api-version=2020-12-01"
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"

######### Triggers

$t1="Trigger_2h_1"
$body = @"
{
    "name": "$t2",
    "properties": {
        "annotations": [],
        "runtimeState": "Started",
        "pipelines": [
            {
                "pipelineReference": {
                    "referenceName": "$n1",
                    "type": "PipelineReference"
                }
            }
        ],
        "type": "ScheduleTrigger",
        "typeProperties": {
            "recurrence": {
                "frequency": "Hour",
                "interval": 2,
                "startTime": "2021-12-02T18:00:00Z",
                "timeZone": "UTC"
            }
        }
    }
}
"@
$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t1`?api-version=2020-12-01"
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"

$t2="Trigger_30min_1"
$body = @"
{
    "name": "$t2",
    "properties": {
        "annotations": [],
        "runtimeState": "Started",
        "pipelines": [
            {
                "pipelineReference": {
                    "referenceName": "$n2",
                    "type": "PipelineReference"
                }
            }
        ],
        "type": "ScheduleTrigger",
        "typeProperties": {
            "recurrence": {
                "frequency": "Minute",
                "interval": 30,
                "startTime": "2021-12-02T18:00:00Z",
                "timeZone": "UTC"
            }
        }
    }
}
"@
$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t2`?api-version=2020-12-01" 
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"
