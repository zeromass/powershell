#[parameter(mandatory=$True, posistion=0)][string]$val1
#[parameter(mandatory=$True, posistion=1)][string]$val2
param(
    [string]$val1,
    [string]$val2
)

Write-Host $val1, $val2