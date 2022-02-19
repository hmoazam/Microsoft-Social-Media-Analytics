$c = "Server=$($workspaceName).sql.azuresynapse.net,1433;Database=$($d);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;User ID = $user;Password=$password"

function Invoke-SQLDestination {
param([string] $sqlCommand = "")
    $commandTxt = @(Get-Content -Path $sqlCommand)
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
$sqlscript = ".\SQLPool\DatabaseObjects.sql"
Invoke-SQLDestination $sqlscript
$sqlscript = ".\SQLPool\DatabaseData.sql"
Invoke-SQLDestination $sqlscript
