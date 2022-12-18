# Ingest tweets - Queries in English

$n1="Tweets Orchestrator"
$body = @"
{
    "name": "$n1",
    "properties": {
        "activities": [
            {
                "name": "Cleanup Tweets",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "Football",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Football FIFA",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                "name": "Cosmos To Synapse - Tweets",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Cleanup Tweets",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Stg to Main - Tweets",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "Cosmos To Synapse - Tweets",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                "name": "Cleanup Users",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "Stg to Main - Tweets",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
            },
            {
                "name": "Cosmos To Synapse Users",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Cleanup Users",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Stg to Main Users",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "Cosmos To Synapse Users",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                "name": "Football",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                            "value": "football OR soccer",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Football",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "English,Arabic",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Wait1",
                "type": "Wait",
                "dependsOn": [
                    {
                        "activity": "Health - Diabetes",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Diabetes Pregnancy",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Covid",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    }
                ],
                "userProperties": [],
                "typeProperties": {
                    "waitTimeInSeconds": 1
                }
            },
            {
                "name": "Health - Diabetes",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                            "value": "#diabetes",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Diabetes",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "English,Arabic",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Health - Diabetes Pregnancy",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                            "value": "diabetes pregnancy",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Diabetes",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "English,Arabic",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Football FIFA",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                            "value": "fifa OR (world cup 2022) or qatar2022",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Football",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "FIFA",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "English,Arabic",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Health - Covid",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                            "value": "covid OR coronavirus OR covid19",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Covid",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "English,Arabic",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            }
        ],
        "annotations": [],
        "lastPublishTime": "2022-12-14T10:53:58Z"
    },
    "type": "Microsoft.Synapse/workspaces/pipelines"
}
"@

$uri = "https://$workspaceName.dev.azuresynapse.net/pipelines/$n1`?api-version=2020-12-01"
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"


# News articles
$n2="News Orchestrator"
$body = @"
{
    "name": "$n2",
    "properties": {
        "activities": [
            {
                "name": "Cleanup Articles",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "Football",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Football FIFA",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                "name": "Cosmos To Synapse - Articles",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Cleanup Articles",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Stg to Main - Articles",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "Cosmos To Synapse - Articles",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                "name": "Health - covid",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                            "value": "covid OR coronavirus or covid19 or covid-19",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Covid",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "English,Arabic",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Football",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait1",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                            "value": "football",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Football",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "English,Arabic",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Wait1",
                "type": "Wait",
                "dependsOn": [
                    {
                        "activity": "Health - covid",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Diabetes",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    }
                ],
                "userProperties": [],
                "typeProperties": {
                    "waitTimeInSeconds": 1
                }
            },
            {
                "name": "Health - Diabetes",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                            "value": "Diabetes",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Diabetes",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "English,Arabic",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Football FIFA",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait1",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                            "value": "FIFA",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Football",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "FIFA",
                            "type": "string"
                        },
                        "query_language": {
                            "value": "All",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "English,Arabic",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            }
        ],
        "annotations": [],
        "lastPublishTime": "2022-12-13T22:59:24Z"
    },
    "type": "Microsoft.Synapse/workspaces/pipelines"
}
"@

$uri = "https://$workspaceName.dev.azuresynapse.net/pipelines/$n2`?api-version=2020-12-01"
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"

# RSS Feeds

$n3="RSS Orchestrator"
$body = @"
{
    "name": "$n3",
    "properties": {
        "activities": [
            {
                "name": "Health - CDC",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "Ingest-RSS-Feeds",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "feed_source": {
                            "value": "https://tools.cdc.gov/podcasts/feed.asp?feedid=183",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "Arabic,English",
                            "type": "string"
                        },
                        "query_optional": {
                            "value": "",
                            "type": "string"
                        },
                        "query_required": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "US Gov",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "HMC",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "BBC Football",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "Ingest-RSS-Feeds",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "feed_source": {
                            "value": "https://feeds.bbci.co.uk/sport/football/rss.xml# ",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "Arabic,English",
                            "type": "string"
                        },
                        "query_optional": {
                            "value": "",
                            "type": "string"
                        },
                        "query_required": {
                            "value": "fifa",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Football",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "FIFA",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "The Independent Football",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "Ingest-RSS-Feeds",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "feed_source": {
                            "value": "https://www.independent.co.uk/sport/football/rss",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "Arabic,English",
                            "type": "string"
                        },
                        "query_optional": {
                            "value": "",
                            "type": "string"
                        },
                        "query_required": {
                            "value": "fifa",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Football",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "FIFA",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Health - Mind Body Green",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "Ingest-RSS-Feeds",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "feed_source": {
                            "value": "https://www.mindbodygreen.com/rss/feed.xml",
                            "type": "string"
                        },
                        "target_languages": {
                            "value": "Arabic,English",
                            "type": "string"
                        },
                        "query_optional": {
                            "value": "",
                            "type": "string"
                        },
                        "query_required": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "",
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "Cleanup RSS",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "Health - CDC",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "BBC Football",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "The Independent Football",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Mind Body Green",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                    "storedProcedureName": "[dbo].[FromStgToMain_RSSArticles_Cleanup]"
                }
            },
            {
                "name": "RSS Cosmos To Synapse",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Cleanup RSS",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": "CosmosToSynapse-RSS",
                        "type": "NotebookReference"
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": "$sparkName",
                        "type": "BigDataPoolReference"
                    },
                    "conf": {
                        "spark.dynamicAllocation.enabled": null,
                        "spark.dynamicAllocation.minExecutors": null,
                        "spark.dynamicAllocation.maxExecutors": null
                    },
                    "numExecutors": null
                }
            },
            {
                "name": "RSS Stg to Main",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "RSS Cosmos To Synapse",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
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
                    "storedProcedureName": "[dbo].[FromStgToMain_RSSArticles]"
                }
            }
        ],
        "annotations": [],
        "lastPublishTime": "2022-12-13T22:59:26Z"
    },
    "type": "Microsoft.Synapse/workspaces/pipelines"
}
"@ 

$uri = "https://$workspaceName.dev.azuresynapse.net/pipelines/$n3`?api-version=2020-12-01"
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"

# Triggers
$t1="Trigger x6 A Day - Tweets"
$body = @"
{
    "name": "$t1",
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
                "interval": 4,
                "startTime": "2022-12-17T13:22:00Z",
                "timeZone": "UTC"
                }
            }
        }
    }
}
"@

$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t1`?api-version=2020-12-01"
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"


$t2="Trigger Once A Day - News"
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
                "frequency": "Day",
                "interval": 1,
                "startTime": "2022-03-04T16:05:00",
                "timeZone": "Arab Standard Time",
                "schedule": {
                    "minutes": [
                        0
                    ],
                    "hours": [
                        20
                    ]
                }
            }
        }
    }
}
"@

$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t2`?api-version=2020-12-01"
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"


$t3="Trigger Once A Day - RSS"
$body = @"
{
    "name": "$t3",
    "properties": {
        "annotations": [],
        "runtimeState": "Started",
        "pipelines": [
            {
                "pipelineReference": {
                    "referenceName": "$n3,
                    "type": "PipelineReference"
                }
            }
        ],
        "type": "ScheduleTrigger",
        "typeProperties": {
            "recurrence": {
                "frequency": "Day",
                "interval": 1,
                "startTime": "2022-03-04T16:05:00",
                "timeZone": "Arab Standard Time",
                "schedule": {
                    "minutes": [
                        0
                    ],
                    "hours": [
                        20
                    ]
                }
            }
        }
    }
}
"@

$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t3`?api-version=2020-12-01"
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"