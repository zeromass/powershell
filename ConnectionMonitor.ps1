$total_down_count = 0
$total_downtime = 0
$smtp_server = "192.168.7.220"
$ping_server = "196.25.1.1"
$smtp = New-Object Net.Mail.SmtpClient($smtp_server)    
$file = "\Development\Didactic\PowerShell\ConnectionStats.csv"

while ($True) { #loop forever

    #if the connection drops
    if ($(Test-Connection -Count 1 -ComputerName $ping_server -Quiet) -eq $False) {
        
        $t1 = Get-Date
        
        #wait until it is up again
        while ($(Test-Connection -Count 1 -ComputerName $ping_server -Quiet) -eq $False) {
            Start-Sleep -Seconds 5
        }
        
        $t2 = Get-Date
        $downtime_duration = $t2.Subtract($t1).TotalSeconds
        
        if($downtime_duration -ge 30) {
            
            $($t1.ToString('yyyy-MM-dd HH:mm:ss') + "," + $downtime_duration) | Out-File -FilePath $file -Append -Encoding utf8 -Width 200
            
            $total_downtime = $total_downtime + $downtime_duration
            $total_down_count = $total_down_count + 1
            
            $msg = New-Object Net.Mail.MailMessage
            $msg.From = "connectionmonitor@dev.activi.co.za"
            $msg.To.Add("devinw@dev.activi.co.za")
            $msg.To.Add("joshua@dev.activi.co.za")
            $msg.Subject = "Our Internet connection has dropped again"
            $msg.Body = $("Date & Time: " + $t1.ToString('yyyy-MM-dd HH:mm:ss') + "`n`nDowntime duration: " + $downtime_duration + " seconds`n`nTotal downtime today: " + $total_downtime + " seconds`n`nAverage downtime duration: " + $total_downtime/$total_down_count + " seconds`n`nNumber of drops today: " + $total_down_count)

            $smtp.Send($msg)   
        }               
    }
    
    Start-Sleep -Seconds 5
} 