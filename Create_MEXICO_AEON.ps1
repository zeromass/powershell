$SQLServer = "localhost\SQLEXPRESS"
$SQLUser = "sa"
$SQLPassword = "$dm!n"

$SQLCreateScriptsLocation = 
$SQLDeployScriptsLocation = Get-Location
$SQLTableList = "1 - Structural.sql"
$SQLProcedureList = "2 - USPs and UFNs.sql"
$SQLDataChanges = "3 - Data Changes.sql"


$Tables = Get-Content $TableList

foreach ($Table in $Tables) {
    sqlcmd -S $SQLServer -U $SQLUser -P $SQLPassword -i $Table.FullName
}