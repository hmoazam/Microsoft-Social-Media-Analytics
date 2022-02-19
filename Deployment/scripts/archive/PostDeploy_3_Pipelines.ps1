$newstopic = "Arab Cup"
$news_query_ar ="كأس العرب"
$news_query_en ="arab cup"

$tweetstopic1 = "Qatar"
$tweets_queries1 = "Qatar Arab Cup"

$tweetstopic2 = "Tunisia"
$tweets_queries2 = "Tunisia Arab Cup"

$tweetstopic3 = "Algeria"
$tweets_queries3 = "Algeria Arab Cup"

$tweetstopic4 = "Egypt"
$tweets_queries4 = "Egypt Arab Cup"


$token = (Get-AzAccessToken -Resource "https://dev.azuresynapse.net").Token
$headers = @{ Authorization = "Bearer $token" }
$params=gc ..\main.parameters.json | ConvertFrom-Json
$company=$params.parameters.company.value
$deploymentType=$params.parameters.deploymentType.value

$workspaceName = "syn-ws-$company-sma-$deploymentType-01"
$sparkName = "sparksma$($deploymentType)01"
$sqlpoolName="synsqlpool$($company)sma$($deploymentType)01"
$results=@()

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
                            "value": "$news_query_en",
                            "type": "string"
                        },
                        "topic": {
                            "value": "$newstopic",
                            "type": "string"
                        },
                        "languages": {
                            "value": "English",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "Arabic,English",
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
                        "activity": "$newstopic AR",
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
                "name": "$newstopic AR",
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
                            "value": "$news_query_ar",
                            "type": "string"
                        },
                        "topic": {
                            "value": "$sqlpoolName",
                            "type": "string"
                        },
                        "languages": {
                            "value": "Arabic",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "Arabic,English",
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
$results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headers -ContentType "application/json"




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
                            "value": "Arabic,English",
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
                            "value": "Arabic,English",
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
                "name": "$tweetstopic3",
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
                            "value": "$tweets_queries3",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "$tweetstopic3",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "Arabic,English",
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
                "name": "$tweetstopic4",
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
                            "value": "$tweets_queries4",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "$tweetstopic4",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "Arabic,English",
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
                    },
                    {
                        "activity": "$tweetstopic3",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    },
                    {
                        "activity": "$tweetstopic4",
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
$results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headers -ContentType "application/json"

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
$results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headers -ContentType "application/json"
$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t1/start`?api-version=2020-12-01" 
$results += Invoke-WebRequest -Uri $uri -Method Post -TimeoutSec 90 -Headers $headers 

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
$results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headers -ContentType "application/json"
