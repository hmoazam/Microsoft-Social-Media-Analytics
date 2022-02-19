$params=gc ..\main.parameters.json | ConvertFrom-Json
$company=$params.parameters.company.value
$deploymentType=$params.parameters.deploymentType.value
$workspaceName = "syn-ws-$company-sma-$deploymentType-01"
$d="synsqlpool$($company)sma$($deploymentType)01"
$user = $params.parameters.sqlAdministratorLogin.value
$password = $params.parameters.sqlAdministratorLoginPassword.value

#$cred = Get-credential -Message "SQL Account with admin permissions on Synapse"
#$cred.Password.MakeReadOnly()
 
#$sqlCred = New-Object System.Data.SqlClient.SqlCredential($cred.username,$cred.password)
$c = "Server=$($workspaceName).sql.azuresynapse.net,1433;Database=$($d);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;User ID = $user;Password=$password"

function Invoke-SQLDestination {
param([string] $sqlCommand = "")
    $commandTxt = @(Get-Content -Path $sqlCommand)
    Write-Host
    foreach($txt in $commandTxt)
    {
    if($txt -ne "Go")
    {
    $SQLPacket += $txt +"`n"
    }
    else
    {
    $connectionStringDestination = $c
    $connection = new-object system.data.SqlClient.SQLConnection($connectionStringDestination)
    $connection.Credential = $sqlCred

    $command = new-object system.data.sqlclient.sqlcommand($SQLPacket,$connection)
    $connection.Open()
    $r=$command.ExecuteNonQuery()
    $connection.Close()
    
    $SQLPacket =""

    }
    }
}
$sqlscript = "..\SQLPool\DatabaseObjects.sql"
Invoke-SQLDestination $sqlscript
$sqlscript = "..\SQLPool\DatabaseData.sql"
Invoke-SQLDestination $sqlscript
