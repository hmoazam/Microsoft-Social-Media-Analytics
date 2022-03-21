param location string 
param subscriptionId string 
param ResourceGroup string 
param keyVaultAdministratorUserId string 
param company string 

@sys.allowed([
  'Small'
  'Medium'
  'Large'
])
param sparkNodeSize string
param myPublicIPAddress string

@sys.allowed([
  'devtest'
  'poc'
  'prod'
])
param deploymentType string

param sqlAdministratorLogin string

param sqlAdministratorLoginPassword string

@sys.allowed([
  'DW100c'
  'DW200c'
  'DW300c'
])
param SynapseSku string


param NEWS_API_KEY string
param TWITTER_API_KEY  string
param TWITTER_API_SECRET_KEY string
param TWITTER_ACCESS_TOKEN  string 
param TWITTER_ACCESS_TOKEN_SECRET string

param utcValue string = utcNow()
var identityName = 'KvAssignedUserIdentity'
var secretPerm =  [
  'get' 
  'set' 
  'list'
]

var bootstrapRoleAssignmentId = guid('${resourceGroup().id}contributor')
var contributorRoleDefinitionId = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

var keyVaultName=toLower('kv-${company}-sma-${deploymentType}-01')

var sqlPoolName = toLower('synsqlpool${company}sma${deploymentType}01')
var workspaceName = toLower('syn-ws-${company}-sma-${deploymentType}-01')
var SQL_ENDPOINT = '${workspaceName}.sql.azuresynapse.net'


var sparkPoolName = toLower('sparksma${deploymentType}01')
		
var translatorName = toLower('translator-${company}-sma-${deploymentType}-01')
var translatorResourceId = resourceId('Microsoft.CognitiveServices/accounts',translatorName)
var TRANSLATOR_KEY=listKeys(translatorResourceId,'2021-04-30').key1
var TRANSLATOR_ENDPOINT=Translator.properties.endpoint

var textAnalyticsName = toLower('textanalytics-${company}-sma-${deploymentType}-01')
var textAnalyticsResourceId = resourceId('Microsoft.CognitiveServices/accounts',textAnalyticsName)
var TEXT_ANALYTICS_KEY=listKeys(textAnalyticsResourceId,'2021-04-30').key1
var TEXT_ANALYTICS_ENDPOINT=CogSvc.properties.endpoint


var azureMapsName = toLower('maps-${company}-sma-${deploymentType}-01')
var azureMapsResourceId = resourceId('Microsoft.Maps/accounts',azureMapsName)
var azureMapsApiVersion = providers('Microsoft.Maps','accounts').apiVersions[0]
var AZURE_MAPS_KEY=listKeys(azureMapsResourceId,azureMapsApiVersion).primaryKey

var tenantId = subscription().tenantId
		
var cosmosDbName = toLower('cosmosdb-${company}-sma-${deploymentType}-01')
var cosmosDbDatabaseName = 'cosmosdbdatabasesma01'
var COSMOS_URL = 'https://${cosmosDbName}.documents.azure.com:443/'
var cosmosResourceId = resourceId('Microsoft.DocumentDB/databaseAccounts',cosmosDbName)
var cosmosApiVersion = providers('Microsoft.DocumentDB','databaseAccounts').apiVersions[0]
var COSMOS_KEY=listKeys(cosmosResourceId, cosmosApiVersion).primaryMasterKey

var dlsName = toLower('adls${company}sma${deploymentType}01')
var dlsFsName = toLower('${dlsName}c01')
var dlsResourceId = resourceId('Microsoft.Storage/storageAccounts',dlsName)
var dlsApiVersion = providers('Microsoft.Storage','storageAccounts').apiVersions[0]
var STORAGE_KEY=listKeys(dlsResourceId,dlsApiVersion).keys[0].value
var azureRBACStorageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Storage Blob Data Contributor Role


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
}

resource roleAssignment1 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: bootstrapRoleAssignmentId
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: reference(managedIdentity.id,'2018-11-30').principalId
    scope: resourceGroup().id
    principalType: 'ServicePrincipal'
  }
}



resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: [
      
      {
        objectId: reference(managedIdentity.id,'2018-11-30').principalId
        tenantId: tenantId
        permissions: {
          secrets: secretPerm
        }
      }
      {
        objectId: keyVaultAdministratorUserId
        tenantId: tenantId
        permissions: {
          secrets: secretPerm
        }
      }
      
      {
        objectId: reference('Microsoft.Synapse/workspaces/${workspaceName}', '2021-06-01','Full').identity.principalId
        tenantId: tenantId
        permissions: {
          secrets: secretPerm
        }
      }
      
    ]
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
  dependsOn: [
    sqlpool
  ]
}


resource postDeploy 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'postDeploy'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  kind: 'AzureCLI'
  
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.28.0'
    timeout: 'PT30M'
    //arguments: '${keyVaultName} ${NEWS_API_KEY} ${COSMOS_URL} ${COSMOS_KEY} ${cosmosDbDatabaseName} ${TEXT_ANALYTICS_KEY} ${TEXT_ANALYTICS_ENDPOINT} ${location} ${TRANSLATOR_KEY} ${TRANSLATOR_ENDPOINT} ${TWITTER_API_KEY} ${TWITTER_API_SECRET_KEY} ${TWITTER_ACCESS_TOKEN} ${TWITTER_ACCESS_TOKEN_SECRET} ${SQL_ENDPOINT} ${sqlAdministratorLogin} ${sqlAdministratorLoginPassword} ${sqlPoolName} ${dlsName} ${dlsFsName} ${STORAGE_KEY} ${AZURE_MAPS_KEY} '
    environmentVariables:[
        {
          name: 'keyVaultName'
          value: keyVaultName
        }
        {
          name: 'NEWSAPIKEY'
          value: NEWS_API_KEY
        }
        {
          name: 'COSMOSURL'
          value: COSMOS_URL
        }
        {
          name: 'COSMOSKEY'
          value: COSMOS_KEY
        }
        {
          name: 'COSMOSDATABASENAME'
          value: cosmosDbDatabaseName
        }
        {
          name: 'TEXTANALYTICSKEY'
          value: TEXT_ANALYTICS_KEY
        }
        {
          name: 'TEXTANALYTICSENDPOINT'
          value: TEXT_ANALYTICS_ENDPOINT
        }
        {
          name: 'location'
          value: location
        }
        {
          name: 'TRANSLATORKEY'
          value: TRANSLATOR_KEY
        }
        {
          name: 'TRANSLATORENDPOINT'
          value: TRANSLATOR_ENDPOINT
        }
        {
          name: 'TWITTERAPIKEY'
          value: TWITTER_API_KEY
        }
        {
          name: 'TWITTERAPISECRETKEY'
          value: TWITTER_API_SECRET_KEY
        }
        {
          name: 'TWITTERACCESSTOKEN'
          value: TWITTER_ACCESS_TOKEN
        }
        {
          name: 'TWITTERACCESSTOKENSECRET'
          value: TWITTER_ACCESS_TOKEN_SECRET
        }
        {
          name: 'SQLENDPOINT'
          value: SQL_ENDPOINT
        }
        {
          name: 'SQLUSERNAME'
          value: sqlAdministratorLogin
        }
        {
          name: 'SQLPASSWORD'
          value: sqlAdministratorLoginPassword
        }
        {
          name: 'DBNAME'
          value: sqlPoolName
        }
        {
          name: 'STORAGEACCOUNTNAME'
          value: dlsName
        }
        {
          name: 'STORAGECONTAINERNAME'
          value: dlsFsName
        }
        {
          name: 'STORAGEKEY'
          value: STORAGE_KEY
        }
        {
          name: 'MAPSKEY'
          value: AZURE_MAPS_KEY
        }
        {
          name: 'SYNWORKSPACENAME'
          value: workspaceName
        }
        
  
    ]
    scriptContent: '''
    az keyvault secret set --vault-name $keyVaultName  --name NEWSAPIKEY  --value  $NEWSAPIKEY
    az keyvault secret set --vault-name $keyVaultName  --name COSMOSURL --value $COSMOSURL
    az keyvault secret set --vault-name $keyVaultName  --name COSMOSKEY  --value  $COSMOSKEY
    az keyvault secret set --vault-name $keyVaultName  --name COSMOSDATABASENAME  --value  $COSMOSDATABASENAME
    az keyvault secret set --vault-name $keyVaultName  --name TEXTANALYTICSKEY  --value  $TEXTANALYTICSKEY
    az keyvault secret set --vault-name $keyVaultName  --name TEXTANALYTICSENDPOINT  --value  $TEXTANALYTICSENDPOINT
    az keyvault secret set --vault-name $keyVaultName  --name TEXTANALYTICSREGION  --value  $location
    az keyvault secret set --vault-name $keyVaultName  --name TRANSLATORKEY  --value  $TRANSLATORKEY
    az keyvault secret set --vault-name $keyVaultName  --name TRANSLATORENDPOINT  --value  $TRANSLATORENDPOINT
    az keyvault secret set --vault-name $keyVaultName  --name TRANSLATORREGION  --value  $location
    az keyvault secret set --vault-name $keyVaultName  --name TWITTERAPIKEY  --value  $TWITTERAPIKEY
    az keyvault secret set --vault-name $keyVaultName  --name TWITTERAPISECRETKEY  --value  $TWITTERAPISECRETKEY
    az keyvault secret set --vault-name $keyVaultName  --name TWITTERACCESSTOKEN  --value  $TWITTERACCESSTOKEN
    az keyvault secret set --vault-name $keyVaultName  --name TWITTERACCESSTOKENSECRET  --value  $TWITTERACCESSTOKENSECRET
    az keyvault secret set --vault-name $keyVaultName  --name SQLENDPOINT  --value  $SQLENDPOINT
    az keyvault secret set --vault-name $keyVaultName  --name SQLUSERNAME  --value  $SQLUSERNAME
    az keyvault secret set --vault-name $keyVaultName  --name SQLPASSWORD  --value  $SQLPASSWORD
    az keyvault secret set --vault-name $keyVaultName  --name DBNAME  --value  $DBNAME
    az keyvault secret set --vault-name $keyVaultName  --name STORAGEACCOUNTNAME  --value  $STORAGEACCOUNTNAME
    az keyvault secret set --vault-name $keyVaultName  --name STORAGECONTAINERNAME  --value  $STORAGECONTAINERNAME
    az keyvault secret set --vault-name $keyVaultName  --name STORAGEKEY  --value  $STORAGEKEY
    az keyvault secret set --vault-name $keyVaultName  --name MAPSKEY  --value  $MAPSKEY
    az keyvault secret set --vault-name $keyVaultName  --name SYNWORKSPACENAME --value $SYNWORKSPACENAME
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
  dependsOn: [
    kv
    roleAssignment1
    storagecontainer
    cosmosdatabase
  ]
}
resource maps 'Microsoft.Maps/accounts@2021-02-01' = {
    
  name: azureMapsName
  location: 'global'
  sku: {
      name: 'G2'
  }
  kind: 'Gen2'
}
resource CogSvc 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: textAnalyticsName
  location:location
  sku: {
    name: 'S'
  }
  kind: 'TextAnalytics'
  properties: {
    apiProperties: {}
    customSubDomainName: textAnalyticsName
    publicNetworkAccess: 'Enabled'
  }
}
resource Translator 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: translatorName
  location:location
  sku: {
    name: 'S1'
  }
  kind: 'TextTranslation'
  identity: {
    type: 'None'
    userAssignedIdentities: {}
  }
  properties: {
    customSubDomainName: translatorName
    publicNetworkAccess: 'Enabled'
  }
}
resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: dlsName
  location: location
  sku: {
  name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
  accessTier: 'Hot'
  supportsHttpsTrafficOnly: true
  isHnsEnabled: true
  }
}
resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid(synapsews.name, storage.name)
  scope: storage
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', azureRBACStorageBlobDataContributorRoleID)
    principalId: synapsews.identity.principalId
    principalType:'ServicePrincipal'
  }
}
resource storage_Accounts_name_default 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storage
  name: 'default'
  properties: {
    changeFeed: {
      enabled: false
    }
    restorePolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 30
    }
    isVersioningEnabled: false
  }
}
resource storagecontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01'={
    name: '${dlsName}/default/${dlsFsName}'
    
    dependsOn: [
      storage_Accounts_name_default
    ]
}
resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  
  name: cosmosDbName
  location: location
  tags: {
    defaultExperience: 'Core (SQL)'
    'hidden-cosmos-mmspecial': ''
  }
  kind: 'GlobalDocumentDB'
  identity: {
    type: 'None'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    disableKeyBasedMetadataWriteAccess: false
    enableFreeTier: false
    enableAnalyticalStorage: false
    analyticalStorageConfiguration: {
      schemaType: 'WellDefined'
    }
    databaseAccountOfferType: 'Standard'
    defaultIdentity: 'FirstPartyIdentity'
    networkAclBypass: 'None'
    disableLocalAuth: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    cors: []
    capabilities: []
    ipRules: []
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Geo'
      }
    }
    networkAclBypassResourceIds: []
  }
}

resource cosmoscontainer1 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-10-15' = {

    name: '${cosmosDbName}/${cosmosDbDatabaseName}/articles'
    dependsOn: [
        cosmos
        cosmosdatabase
    ]
    properties: {
        resource: {
            id: 'articles'
            indexingPolicy: {
                indexingMode: 'consistent'
                automatic: true
                includedPaths: [
                    {
                        path: '/*'
                    }
                ]
                excludedPaths: [
                    {
                        path: '/\'_etag\'/?'
                    }
                ]
            }
            partitionKey: {
                paths: [
                    '/month_year'
                ]
                kind: 'Hash'
            }
            uniqueKeyPolicy: {
                uniqueKeys: []
            }
            conflictResolutionPolicy: {
                mode: 'LastWriterWins'
                conflictResolutionPath: '/_ts'
            }
        }
    }
}
resource cosmoscontainer2 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-10-15' = {
      name: '${cosmosDbName}/${cosmosDbDatabaseName}/tweets_and_users'
      dependsOn: [
        cosmos
        cosmosdatabase
      ]
      properties: {
          resource: {
              id: 'tweets_and_users'
              indexingPolicy: {
                  indexingMode: 'consistent'
                  automatic: true
                  includedPaths: [
                      {
                          path: '/*'
                      }
                  ]
                  excludedPaths: [
                      {
                          path: '/\'_etag\'/?'
                      }
                  ]
              }
              partitionKey: {
                  paths: [
                      '/month_year'
                  ]
                  kind: 'Hash'
              }
              uniqueKeyPolicy: {
                  uniqueKeys: []
              }
              conflictResolutionPolicy: {
                  mode: 'LastWriterWins'
                  conflictResolutionPath: '/_ts'
              }
          }
      }
  }


  resource cosmoscontainer3 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-10-15' = {
    name: '${cosmosDbName}/${cosmosDbDatabaseName}/rss_articles'
    dependsOn: [
      cosmos
      cosmosdatabase
    ]
    properties: {
        resource: {
            id: 'rss_articles'
            indexingPolicy: {
                indexingMode: 'consistent'
                automatic: true
                includedPaths: [
                    {
                        path: '/*'
                    }
                ]
                excludedPaths: [
                    {
                        path: '/\'_etag\'/?'
                    }
                ]
            }
            partitionKey: {
                paths: [
                    '/month_year'
                ]
                kind: 'Hash'
            }
            uniqueKeyPolicy: {
                uniqueKeys: []
            }
            conflictResolutionPolicy: {
                mode: 'LastWriterWins'
                conflictResolutionPath: '/_ts'
            }
        }
    }
}


  resource cosmosdatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-10-15' = {
    name: '${cosmosDbName}/${cosmosDbDatabaseName}'
    dependsOn: [
        cosmos
    ]
    properties: {
        resource: {
            id: cosmosDbDatabaseName
        }
    }
}

resource synapsews 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  identity: {
  type: 'SystemAssigned'
  }
  dependsOn: [
    storagecontainer
  ]
  properties: {
  defaultDataLakeStorage: {
    accountUrl: reference(dlsName).primaryEndpoints.dfs
    filesystem: dlsFsName
  }
  sqlAdministratorLogin: sqlAdministratorLogin
  sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
  managedVirtualNetwork: 'default'
  }
}
resource symbolicname 'Microsoft.Synapse/workspaces/managedIdentitySqlControlSettings@2021-06-01' = {
  name: 'default'
  parent: synapsews
  properties: {
    grantSqlControlToManagedIdentity: {
      desiredState: 'Enabled'
    }
  }
}

resource sqlpool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01-preview' = {
name: '${workspaceName}/${sqlPoolName}'
location: location
sku: {
name: SynapseSku
}
dependsOn: [
  synapsews
]
properties: {
createMode: 'Default'
collation: 'SQL_Latin1_General_CP1_CI_AS'
}
}


resource spark 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01-preview' = {
name: '${workspaceName}/${sparkPoolName}'
location: location
dependsOn: [
  synapsews
]

properties: {
nodeCount: 5
nodeSizeFamily: 'MemoryOptimized'
nodeSize: sparkNodeSize
autoScale: {
  'enabled': true
  minNodeCount: 2
  maxNodeCount: 6
}
autoPause: {
  'enabled': true
  delayInMinutes: 60
}
sparkVersion: '3.1'
}
}

resource synapseFirewall 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  name: 'allowLocalIP'
  parent: synapsews
  properties: {
    startIpAddress: myPublicIPAddress
    endIpAddress: myPublicIPAddress
  }
}
