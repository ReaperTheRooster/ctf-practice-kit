<#
.SYNOPSIS
  flaghunt.ps1 - find CTF flag files on a Windows box you already have a shell on.
.DESCRIPTION
  For CTFs, labs, and systems you are authorized to test. Read-only.
.PARAMETER Path     Search root (default C:\)
.PARAMETER Content  Also search file contents for flag-format strings (slower)
.PARAMETER Print    Print contents of readable flag files
#>
param(
    [string]$Path = 'C:\',
    [switch]$Content,
    [switch]$Print
)

$names   = 'user.txt','root.txt','proof.txt','local.txt','flag.txt','flag*.txt','*.flag','secret.txt'
$formats = '(HTB|THM|flag|FLAG|CTF|picoCTF|DUCTF|csaw)\{[^}]{4,}\}'
$skip    = '\\Windows\\|\\Program Files|\\ProgramData\\Microsoft'

Write-Host "[*] $env:USERDOMAIN\$env:USERNAME @ $env:COMPUTERNAME | search root: $Path"

Write-Host '[*] Flag-named files'
$hits = foreach ($n in $names) {
    Get-ChildItem -Path $Path -Recurse -Force -File -Filter $n -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch $skip }
}
$hits | Sort-Object FullName -Unique | ForEach-Object {
    try {
        $text = Get-Content -LiteralPath $_.FullName -TotalCount 5 -ErrorAction Stop
        Write-Host "[+] readable  $($_.FullName)" -ForegroundColor Green
        if ($Print) { $text | ForEach-Object { "      $_" } }
    } catch {
        Write-Host "[!] exists, not readable  $($_.FullName)  (needs privesc?)" -ForegroundColor Yellow
    }
}

Write-Host '[*] Usual hiding spots'
$spots = @("$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents", 'C:\Users\Public',
           'C:\Users\Administrator\Desktop', 'C:\inetpub', 'C:\Temp')
foreach ($s in $spots) {
    if (Test-Path $s) {
        Get-ChildItem $s -Recurse -Force -File -Depth 3 -ErrorAction SilentlyContinue |
            Where-Object { $_.Length -lt 4KB -and $_.Name -match 'flag|\.txt$' } |
            Select-Object -First 25 -ExpandProperty FullName
    }
}

if ($Content) {
    Write-Host '[*] Content search for flag formats'
    Get-ChildItem -Path $Path -Recurse -Force -File -Include *.txt,*.config,*.ini,*.xml,*.log -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch $skip -and $_.Length -lt 1MB } |
        Select-String -Pattern $formats -ErrorAction SilentlyContinue |
        Select-Object -First 50 | ForEach-Object { "$($_.Path):$($_.LineNumber): $($_.Matches[0].Value)" }
}
