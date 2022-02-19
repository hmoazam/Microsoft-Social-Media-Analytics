$template = @"
{
    "name": "AzureKeyVaultLinkedService",
    "properties": {
    "type": "AzureKeyVault",
    "typeProperties": {
        "baseUrl": "https://###KeyVaultName###.vault.azure.net"
        }
    }
}
"@ 
$token = (Get-AzAccessToken -Resource "https://dev.azuresynapse.net").Token
$headers = @{ Authorization = "Bearer $token" }
$params=gc .\main.parameters.json | ConvertFrom-Json
$company=$params.parameters.company.value
$deploymentType=$params.parameters.deploymentType.value

$results = @()
$kvName = "kv-$company-sma-$deploymentType-01"
$workspaceName = "syn-ws-$company-sma-$deploymentType-01"
$kvLinkedServiceName = "KeyVaultLinkedService"
$body = $template -replace "###KeyVaultName###" , $kvName

$uri = "https://$workspaceName.dev.azuresynapse.net/linkedservices/$kvLinkedServiceName`?api-version=2020-12-01"
$results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headers -ContentType "application/json"
