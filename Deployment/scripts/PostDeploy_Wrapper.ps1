$params=gc .\SMAv2Template.parameters.json | ConvertFrom-Json
$subscriptionId = $params.parameters.subscriptionId.value
$rg=$params.parameters.resourceGroup.value
$company=$params.parameters.company.value
$deploymentType=$params.parameters.deploymentType.value
$location=$params.parameters.location.value
$workspaceName = "syn-ws-$company-sma-$deploymentType-01"
$sparkNodeSize=$params.parameters.sparkNodeSize.value
$sparkName = "sparksma$($deploymentType)01"
$sqlpoolName="synsqlpool$($company)sma$($deploymentType)01"
$d="synsqlpool$($company)sma$($deploymentType)01"



$kvName = "kv-$company-sma-$deploymentType-01"
$user = $params.parameters.sqlAdministratorLogin.value
$password = $params.parameters.sqlAdministratorLoginPassword.value

Login-AzAccount -WarningAction SilentlyContinue | out-null
Set-AzContext $subscriptionId -WarningAction SilentlyContinue | out-null
$tokenSynapse = (Get-AzAccessToken -Resource "https://dev.azuresynapse.net").Token
$headersSynapse = @{ Authorization = "Bearer $tokenSynapse" }

$tokenAzure = (Get-AzAccessToken -Resource "https://management.azure.com").Token
$headersAzure = @{ Authorization = "Bearer $tokenAzure" }

$global:results = @()
write-host "Post deployment scripts for Social Media Analytics (v2)"
write-host "Deploying Notebooks"
& .\scripts\PostDeploy_1-Notebooks.ps1
write-host "Deploying Tables and Stored Procedures"
& .\scripts\PostDeploy_2-TablesAndProcs.ps1
write-host "Deploying Pipelines and Triggers"
& .\scripts\PostDeploy_3-Pipelines.ps1
write-host "Adding required libraries to Spark pool"
& .\scripts\PostDeploy_4-Spark_Libraries.ps1
write-host "Creating Key Vault linked service"
& .\scripts\PostDeploy_5-LinkedServices.ps1
write-host "Post-deployment completed"








