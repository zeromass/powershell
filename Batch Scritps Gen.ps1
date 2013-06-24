$lines = Get-Content .\Changes 

foreach ($line in $lines) {
    $app = $line.Split('>')
    
    $out = "cd " + $app[0] + "`n" + $app[1]
    Set-Content -Path $($app[0].Substring($app[0].LastIndexOf('\')+1).Replace(' ', '')+".bat") -value $out
}