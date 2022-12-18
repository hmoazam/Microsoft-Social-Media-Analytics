$t1="Trigger Once A Day - Tweets"
$t2="Trigger Once A Day - News"
$t3="Trigger Once A Day - RSS"

$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t1/start`?api-version=2020-12-01" 
$global:results += Invoke-WebRequest -Uri $uri -Method Post -TimeoutSec 90 -Headers $headersSynapse 

$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t2/start`?api-version=2020-12-01" 
$global:results += Invoke-WebRequest -Uri $uri -Method Post -TimeoutSec 90 -Headers $headersSynapse 

$uri = "https://$workspaceName.dev.azuresynapse.net/triggers/$t3/start`?api-version=2020-12-01" 
$global:results += Invoke-WebRequest -Uri $uri -Method Post -TimeoutSec 90 -Headers $headersSynapse
