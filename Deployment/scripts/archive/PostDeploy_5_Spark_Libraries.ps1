$token = (Get-AzAccessToken -Resource "https://management.azure.com").Token
$headers = @{ Authorization = "Bearer $token" }
$params=gc ..\main.parameters.json | ConvertFrom-Json
$company=$params.parameters.company.value.ToLower()
$location=$params.parameters.location.value
$deploymentType=$params.parameters.deploymentType.value

$global:results = @()
$workspaceName = "syn-ws-$company-sma-$deploymentType-01"
$sparkName = "sparksma$($deploymentType)01"
$sparkNodeSize=$params.parameters.sparkNodeSize.value
$subscriptionId=$params.parameters.subscriptionId.value
$rg=$params.parameters.resourceGroup.value
$uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rg/providers/Microsoft.Synapse/workspaces/$workspaceName/bigDataPools/$sparkName`?api-version=2021-06-01-preview"

$body =@"
{

  "location": "$location",
  "properties":{
  
      "nodeCount": "0",
      "nodeSizeFamily": "MemoryOptimized",
      "nodeSize": "$sparkNodeSize",
      "autoScale": {
          "enabled": "true",
          "minNodeCount": "2",
          "maxNodeCount": "6"
        },
      "autoPause": {
        "enabled": "true",
      "delayInMinutes": "60"
        },
      "sparkVersion": "3.1",

      "libraryRequirements": {
                    "filename": "requirements.txt",
                    "content": "
azure-cosmos==4.2
tweepy==3.10.0
azure-ai-textanalytics==5.1.0
family
"
                },
    "isComputeIsolationEnabled": "false",
  "sessionLevelPackagesEnabled": "true",
  "cacheSize": "0",
  "dynamicExecutorAllocation": {
      "enabled": "false"
  }

  }
}
"@
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headers -ContentType "application/json"
