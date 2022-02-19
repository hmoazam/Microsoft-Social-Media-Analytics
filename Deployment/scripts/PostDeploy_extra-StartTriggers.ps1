$t1="Trigger_2h_1"
$t2="Trigger_30min_1"

$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t1/start`?api-version=2020-12-01" 
$global:results += Invoke-WebRequest -Uri $uri -Method Post -TimeoutSec 90 -Headers $headersSynapse 

$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t2/start`?api-version=2020-12-01" 
$global:results += Invoke-WebRequest -Uri $uri -Method Post -TimeoutSec 90 -Headers $headersSynapse 