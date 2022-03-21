# Ingest tweets - Queries in English

$n1="Tweets Orchestrator"
$body = @"
{
    "name": "$n1",
    "properties": {
        "activities": [
            {
                "name": "Children - Islamic Upbringing 1",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "upbringing islam",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Islamic Upbringing",
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
                    }
                }
            },
            {
                "name": "Cleanup Tweets",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "Children - Islamic Upbringing 1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Parenting",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Child Development 1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Child Development 2",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Screen Time 1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Screen Time 2",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Screen Time 3",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Children - Islamic Upbringing 2",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Child Development 3",
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
                    }
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
                    }
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
                "name": "Parenting",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "\"raising children\" OR \"raising kids\" OR parenting",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Parenting",
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
                    }
                }
            },
            {
                "name": "Child Development 1",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "childhood development",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Child Development",
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
                    }
                }
            },
            {
                "name": "Child Development 2",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "\"early childhood development\"",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Child Development",
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
                    }
                }
            },
            {
                "name": "Screen Time 1",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "\"screen time\" kids",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Screen Time",
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
                    }
                }
            },
            {
                "name": "Health - Childhood Obesity 1",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "childhood obesity",
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
                            "value": "Childhood Obesity",
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
                    }
                }
            },
            {
                "name": "Screen Time 2",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "\"screen time\" children",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Screen Time",
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
                    }
                }
            },
            {
                "name": "Screen Time 3",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "\"screen time\" children \"mental health\"",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Screen Time",
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
                    }
                }
            },
            {
                "name": "Health - Childhood Diabetes",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "childhood diabetes",
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
                            "value": "Childhood Diabetes",
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
                    }
                }
            },
            {
                "name": "Wait1",
                "type": "Wait",
                "dependsOn": [
                    {
                        "activity": "Health - Childhood Obesity 1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Childhood Diabetes",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
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
                        "activity": "Health - Obesity and Diabetes",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Obesity and Diabetes Qatar",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Diabetes Qatar 1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Diabetes Qatar 2",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Covid Qatar",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Childhood Obesity 2",
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
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                    }
                }
            },
            {
                "name": "Health - Diabetes Pregnancy",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                    }
                }
            },
            {
                "name": "Health - Obesity and Diabetes",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "obesity diabetes",
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
                            "value": "Obesity & Diabetes",
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
                    }
                }
            },
            {
                "name": "Health - Obesity and Diabetes Qatar",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "obesity diabetes qatar",
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
                            "value": "Obesity & Diabetes Qatar",
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
                    }
                }
            },
            {
                "name": "Health - Diabetes Qatar 1",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "(diabetes sidra qatar) OR (diabetes hmc qatar) OR #QatarDiabetesAssociation OR (Qatar Diabetes Association)",
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
                            "value": "Diabetes Qatar",
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
                    }
                }
            },
            {
                "name": "Health - Diabetes Qatar 2",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "",
                            "type": "string"
                        },
                        "users": {
                            "value": "QatarDiabetes",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Diabetes Qatar",
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
                    }
                }
            },
            {
                "name": "Health - Covid Qatar",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                        "referenceName": "Ingest-Tweets",
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "query": {
                            "value": "(covid OR \"covid vaccination\" OR coronavirus) qatar",
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
                            "value": "Covid Qatar",
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
                    }
                }
            },
            {
                "name": "Wait 2",
                "type": "Wait",
                "dependsOn": [
                    {
                        "activity": "Events in Qatar - Horse Racing",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Events in Qatar - All Events",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Environment",
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
                "name": "Health - Childhood Obesity 2",
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
                            "value": "",
                            "type": "string"
                        },
                        "users": {
                            "value": "ChildObesity_jn",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Childhood Obesity",
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
                    }
                }
            },
            {
                "name": "Events in Qatar - Horse Racing",
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
                            "value": "\"Amir Sword Festival in Qatar\" OR (Katara International Arabian Horse Festival) OR \"Chi Al Shaqab\" OR (Longines Al Shaqab)",
                            "type": "string"
                        },
                        "users": {
                            "value": "",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Events in Qatar",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Horse Racing",
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
                    }
                }
            },
            {
                "name": "Events in Qatar - All Events",
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
                            "value": "",
                            "type": "string"
                        },
                        "users": {
                            "value": "QatarCalendar",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Events in Qatar",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "All Events",
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
                    }
                }
            },
            {
                "name": "Environment",
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
                            "value": "",
                            "type": "string"
                        },
                        "users": {
                            "value": "QEERI_QA,AYCMQA",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Environment",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Qatar",
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
                    }
                }
            },
            {
                "name": "Children - Islamic Upbringing 2",
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
                            "value": "",
                            "type": "string"
                        },
                        "users": {
                            "value": "MuslimUpbring",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Islamic Upbringing",
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
                    }
                }
            },
            {
                "name": "Child Development 3",
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
                            "value": "",
                            "type": "string"
                        },
                        "users": {
                            "value": "ECDAction",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Child Development",
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
                    }
                }
            }
        ],
        "annotations": [],
        "lastPublishTime": "2022-03-04T16:14:09Z"
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
                "name": "Children - Islamic Upbringing 1",
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
                            "value": "upbringing AND islam",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Islamic Upbringing",
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
                    }
                }
            },
            {
                "name": "Cleanup Articles",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "Children - Islamic Upbringing 1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Parenting",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Child Development 1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Child Development 2",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Screen Time 1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Screen Time 2",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Screen Time 3",
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
                    }
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
                "name": "Parenting",
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
                            "value": "\"raising children\" OR \"raising kids\" OR parenting",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Parenting",
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
                    }
                }
            },
            {
                "name": "Child Development 1",
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
                            "value": "childhood AND development",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Child Development",
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
                    }
                }
            },
            {
                "name": "Child Development 2",
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
                            "value": "\"early childhood development\"",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Child Development",
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
                    }
                }
            },
            {
                "name": "Screen Time 1",
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
                            "value": "\"screen time\" AND kids",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Screen Time",
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
                    }
                }
            },
            {
                "name": "Health - Childhood Obesity 1",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                            "value": "childhood AND obesity",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Childhood Obesity",
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
                    }
                }
            },
            {
                "name": "Screen Time 2",
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
                            "value": "\"screen time\" AND children",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Screen Time",
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
                    }
                }
            },
            {
                "name": "Screen Time 3",
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
                            "value": "\"screen time\" AND children AND \"mental health\"",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Children",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Screen Time",
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
                    }
                }
            },
            {
                "name": "Health - Childhood Diabetes",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                            "value": "childhood AND diabetes",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Childhood Diabetes",
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
                    }
                }
            },
            {
                "name": "Wait1",
                "type": "Wait",
                "dependsOn": [
                    {
                        "activity": "Health - Childhood Obesity 1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Childhood Diabetes",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
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
                        "activity": "Health - Obesity and Diabetes",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Obesity and Diabetes Qatar",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Diabetes Qatar 1",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Covid Qatar",
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
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                    }
                }
            },
            {
                "name": "Health - Diabetes Pregnancy",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                            "value": "diabetes AND pregnancy",
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
                    }
                }
            },
            {
                "name": "Health - Obesity and Diabetes",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                            "value": "obesity AND diabetes",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Obesity & Diabetes",
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
                    }
                }
            },
            {
                "name": "Health - Obesity and Diabetes Qatar",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                            "value": "obesity AND diabetes AND qatar",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Obesity & Diabetes Qatar",
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
                    }
                }
            },
            {
                "name": "Health - Diabetes Qatar 1",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                            "value": "(diabetes AND sidra AND qatar) OR (diabetes AND hmc AND qatar) OR (Qatar AND Diabetes AND Association)",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Diabetes Qatar",
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
                    }
                }
            },
            {
                "name": "Health - Covid Qatar",
                "type": "SynapseNotebook",
                "dependsOn": [
                    {
                        "activity": "Wait 2",
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
                            "value": "(covid OR \"covid vaccination\" OR coronavirus) AND qatar",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Health",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Covid Qatar",
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
                    }
                }
            },
            {
                "name": "Wait 2",
                "type": "Wait",
                "dependsOn": [
                    {
                        "activity": "Events in Qatar - Horse Racing",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Environment Qatar",
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
                "name": "Events in Qatar - Horse Racing",
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
                            "value": "\"Amir Sword Festival in Qatar\" OR (Katara International Arabian Horse Festival) OR \"Chi Al Shaqab\" OR (Longines Al Shaqab)",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Events in Qatar",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Horse Racing",
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
                    }
                }
            },
            {
                "name": "Environment Qatar",
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
                            "value": "Qatar AND Environment AND climate AND NOT(football OR fifa OR world cup)",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Environment",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Qatar",
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
                    }
                }
            }
        ],
        "annotations": [],
        "lastPublishTime": "2022-03-07T09:16:39Z"
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
                "name": "Gulf Times - HMC",
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
                            "value": "https://www.gulf-times.com/Rss/Index",
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
                            "value": "hmc OR hamad hospital",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Hospitals",
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
                    }
                }
            },
            {
                "name": "Gulf Times - Sidra",
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
                            "value": "https://www.gulf-times.com/Rss/Index",
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
                            "value": "sidra",
                            "type": "string"
                        },
                        "topic": {
                            "value": "Hospitals",
                            "type": "string"
                        },
                        "subtopic": {
                            "value": "Sidra",
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
                "name": "Parenting - Psychology Today",
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
                            "value": "https://www.psychologytoday.com/us/blog/singletons/feed",
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
                            "value": "Parenting",
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
                    }
                }
            },
            {
                "name": "Parenting - Hand in Hand Parenting",
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
                            "value": "https://www.handinhandparenting.org/feed/",
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
                            "value": "Parenting",
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
                    }
                }
            },
            {
                "name": "Health - Health Magazine UAE",
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
                            "value": "http://www.healthmagazine.ae/blog/feed/",
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
                    }
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
                    }
                }
            },
            {
                "name": "Cleanup RSS",
                "type": "SqlPoolStoredProcedure",
                "dependsOn": [
                    {
                        "activity": "Gulf Times - HMC",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Gulf Times - Sidra",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Parenting - Psychology Today",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Parenting - Hand in Hand Parenting",
                        "dependencyConditions": [
                            "Completed"
                        ]
                    },
                    {
                        "activity": "Health - Health Magazine UAE",
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
                    }
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
        "lastPublishTime": "2022-03-06T12:08:49Z"
    },
    "type": "Microsoft.Synapse/workspaces/pipelines"
}

"@ 

$uri = "https://$workspaceName.dev.azuresynapse.net/pipelines/$n3`?api-version=2020-12-01"
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"

# Triggers
$t1="Trigger Once A Day - Tweets"
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