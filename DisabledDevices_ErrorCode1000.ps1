$report_file = "Disabled_Devices_ErrorCode1000.txt"
#$report_file = "test.txt"

$contents = Get-Content $report_file

$devid_regex = [regex]'.{11}Dev: (\d+)'

$devices = @()    

foreach ($line in $contents) {
    
    
    if (-not ($line.Trim().Equals(""))) {
    
    
        if ($line -match ".log") {
        
            if ($devices.Count -ne 0) {
                
                
                #Write-Output $log_date | Out-File -FilePath "devices.txt" -Encoding "UTF8" -Append
                
                foreach ($dev in $devices) {
                    Write-Output $log_date"`t"$dev | Out-File -FilePath "devices.txt" -Encoding "UTF8" -Append
                }
                
                #Write-Output "" | Out-File -FilePath "devices.txt" -Encoding "UTF8" -Append
            }
        
            $log_date = $line.Replace(".log", "")
            $devices = @()                     
                        
        }
        else {
            $devid = $devid_regex.Match($line).Groups[1].Value.Trim()
            
            if ((-not ($devid.Equals(""))) -and ($devices -notcontains $devid)) {
                $devices += $devid
            }
        }                
    }     
}