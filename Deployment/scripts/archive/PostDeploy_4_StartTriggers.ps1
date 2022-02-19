
$token = (Get-AzAccessToken -Resource “https://dev.azuresynapse.net“).Token
$headers = @{ Authorization = "Bearer $token" }
$params=gc ..\main.parameters.json | ConvertFrom-Json
$company=$params.parameters.company.value
$deploymentType=$params.parameters.deploymentType.value

$workspaceName = "syn-ws-$company-sma-$deploymentType-01"
$t1="Trigger_2h_1"
$t2="Trigger_30min_1"

$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t1/start`?api-version=2020-12-01" 
$results += Invoke-WebRequest -Uri $uri -Method Post -TimeoutSec 90 -Headers $headers 

$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t2/start`?api-version=2020-12-01" 
$results += Invoke-WebRequest -Uri $uri -Method Post -TimeoutSec 90 -Headers $headers 