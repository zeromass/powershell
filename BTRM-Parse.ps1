param(
    [String]$InputFile
)

if ($InputFile.Trim() -eq "") {
    Write-Host "Please specify the log file"
}
else {
    if (Test-Path $InputFile) {
        $MerchantUpdatesList = Get-Content $InputFile | Select-String -Pattern "Affliated Merchant update request for BimboMerhantId" |  %{$a = $_.ToString(); $a.SubString($a.LastIndexOf(']') + 2)} | sort {[String][Regex]::Match($_, "([0-9]+)").Groups[0].Value}
                                    
        $MultiplyUpdatedMerchantList = @()
        $prev = ""
        
        for ($i = 1; $i -lt $MerchantUpdatesList.Length; $i++){
            
            if (($MerchantUpdatesList[$i] -eq $MerchantUpdatesList[$i - 1]) -and ($MerchantUpdatesList[$i] -ne $prev)) {
                $MultiplyUpdatedMerchantList += $MerchantUpdatesList[$i]
            }
            else {
                $prev = $MerchantUpdatesList[$i]
            }
        }
        
        $MultiplyUpdatedMerchantList |  Set-Content .\out.txt
        
    }
    else {
        Write-Host $InputFile "does not exist"
    }
       
}
