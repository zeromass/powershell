#[parameter(mandatory=$True, posistion=0)][string]$file
param(
    [string]$file
)

#2013-03-20 05:48:59,356
$reg_date_pattern = [Regex]"^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3})"

# 2013-03-20 05:48:59,356 - [WARN ] [MessageFactory      ] [1218292791] 
$reg_sysid_pattern = [Regex]"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3} - \[.+?\] \[.+?\] \[(\d+)\]"

# {"Req":"Balance","Dev":"25078","Serial":"2A019238","User":"011234"}
$reg_req_pattern = [Regex]"`"Dev`":`"(\d+)`",`"Serial`":`"(\d\w\d{6})`",`"User`":`"(\d{6})`""

# <message>("Cmd":"Display","Header":"Error","Msg":"AEON Connection Error.")</message>
$reg_resp_pattern = [Regex]"<message>(.+)</message>"

# ("Bal":1201.00)
$reg_succ_pattern = [Regex]"`"Bal`":(.+)\)"

# ("Cmd":"Display","Header":"Error","Msg":"AEON Connection Error.")
$reg_err_pattern = [Regex]"`"Msg`":`"(.+)`"\)"

$log_entries = Get-Content $file | Select-String -Pattern $reg_date_pattern.ToString() | Select-String -Pattern "(Request|Response):"| Sort-Object -property @{Expression={$reg_sysid_pattern.Match($_).Groups[1].Value}}, @{Expression={$reg_date_pattern.Match($_).Groups[1].Value}}, @{Expression={$_}} 

$log_balance_entries = @()

$i = 0
$sys_id = 0


# get only the balance related entries
while ($i -lt $log_entries.Length) {
   
    # check if the current entry is a request entry for a balance enquiry
    if ($log_entries[$i] -match "Request:  {`"Req`":`"Balance`"") {
                                
        # if it is then add it to the balance entry list
        $log_balance_entries += $log_entries[$i]
        
        $sys_id = $reg_sysid_pattern.Match($log_entries[$i]).Groups[1].Value
        
        $i++
        
        # add all corresponding entries to the balance entry list
        while ($reg_sysid_pattern.Match($log_entries[$i]).Groups[1].Value -eq $sys_id) {
        
            $log_balance_entries += $log_entries[$i]
            
            $i++
        }
            
    }
    else {  
      
        $i++
    }
}


# reset the counter
$i = 0
$str_p = "INSERT INTO ##USSDBalanceReq (SysId, DeviceId, RequestTime, ResponseMsg) VALUES ("

# produce output in SQL script format
while ($i -lt $log_balance_entries.Length) {
    
    #get the sysId
    $sys_id = $reg_sysid_pattern.Match($log_entries[$i]).Groups[1].Value
    
    $s = $str_p + $sys_id + ", "
    
    # get the device id
    $s = $s + $reg_req_pattern.Match($log_balance_entries[$i]).Groups[1].Value + ", "
    
    $i++
    
    # add all corresponding entries to the balance entry list
    while ($reg_sysid_pattern.Match($log_entries[$i]).Groups[1].Value -eq $sys_id) {
        
        $stmt = $s + "'" + $reg_date_pattern.Match($log_entries[$i]).Groups[0].Value.Replace(",", ".") + "', "
        
        $msg = $reg_resp_pattern.Match($log_balance_entries[$i]).Groups[1].Value
        
        # if the response message has is balance response
        if ($msg -match "`"Bal`":") {
            $stmt = $stmt + "'" + $reg_succ_pattern.Match($msg).Groups[1].Value + "')"
        }
        # otherwise it must be an error response
        else {
            $stmt = $stmt + "'" + $reg_err_pattern.Match($msg).Groups[1].Value + "')"
        }                                          
        
        Write-Output $stmt
                
        $i++
    }
    
}