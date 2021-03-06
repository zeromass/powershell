$Current_Location = (Get-Location).Path

$shell_app=new-object -com shell.application
$destination = $shell_app.namespace($Current_Location)



$log_file_archives = Get-ChildItem -Path $Current_Location.Path -Filter "*.zip"

foreach ($archive in $log_file_archives) {
    $log_file_name = $archive.Name.Replace(".zip", ".log")
    
    Write-Host "Unzipping "$archive.Name
    $zip_file = $shell_app.namespace($Current_Location + "\" + $archive.Name)
    $destination.Copyhere($zip_file.items())
    
    Write-Host "Scanning "$log_file_name
    
    Echo $log_file_name | Out-File -FilePath "error.txt" -Encoding "UTF8" -Append
    Get-Content $log_file_name | Select-String "CashDepositBimbo" | Select-String "<ErrorCode>1000</ErrorCode>" | Out-File -FilePath "error.txt" -Encoding "UTF8" -Append -Width 1000
    
    Write-Host "Deleting "$log_file_name    
    Remove-Item $log_file_name
}
    


