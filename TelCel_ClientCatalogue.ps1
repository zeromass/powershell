# generate the devices status script
$OutputPath = "C:\Users\joshua\Documents\Development\Operational\TelCel\Client Catalogue\Error Correction\Affiliated Merchants"

Set-Location $OutputPath


$file = Get-ChildItem -Path "C:\Development\Data\LIVE\TelCel\Client Catalog\*" -Include "*.txt" 
$reg = [Regex]"^(.)\|(.{5})"
$go = "GO`n`n"



Write-Host $file.Name
$reg_filenamedate = [regex]"tiendas_BLB(..)(..)(..)"
$m = $reg_filenamedate.Match($file.Name)

$daydir = $("20" + $m.Groups[1].Value + "-" + $m.Groups[2].Value + "-" + $("{0}" -f $([Convert]::ToInt32($m.Groups[3].Value, 10) + 1)).PadLeft(2, '0'))


mkdir $daydir
    
$cnt = 0
    
Get-Content $file | % { $m = $reg.Match($_); if ($cnt -ne 20000) { Write-Output $("INSERT INTO ##dev (DeviceId, Status) VALUES (" + [Convert]::ToInt32($m.Groups[2].Value, 16) + ", " + $m.Groups[1].Value + ")"); $cnt++ } else { Write-Output $($go + "INSERT INTO ##dev (DeviceId, Status) VALUES (" + [Convert]::ToInt32($m.Groups[2].Value, 16) + ", " + $m.Groups[1].Value + ")"); $cnt = 0 } } | out-file -filepath $($daydir + "\dev.sql") -width 1000


# generate the devices error script
$reg = [Regex]"^(.+?) - (.+?): (.{5})$"
Get-Content .\err.txt | %{$m = $reg.Match($_); Write-Output $("INSERT INTO ##err (DeviceId, Error, Msg) VALUES (" + [Convert]::Toint32($m.Groups[3].Value, 16) + ", '" + $m.Groups[1].Value + "', '" +$m.Groups[2].Value + "')" )} | out-file -FilePath $($daydir + "\err.sql") -width 1000

