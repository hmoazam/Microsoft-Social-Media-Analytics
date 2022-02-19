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
$kvLinkedServiceName = "KeyVaultLinkedService"
$body = $template -replace "###KeyVaultName###" , $kvName

$uri = "https://$workspaceName.dev.azuresynapse.net/linkedservices/$kvLinkedServiceName`?api-version=2020-12-01"
$global:results += Invoke-WebRequest -Uri $uri -Method Put -Body $body  -TimeoutSec 90 -Headers $headersSynapse -ContentType "application/json"
