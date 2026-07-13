<#
  Elevated helper for uninstall: removes Open-Shell (Program Files)
  and the PersonalizationCSP lock screen override.
  Launched with -Verb RunAs by Remove-Win98-Shell.ps1.
#>
$ErrorActionPreference = 'SilentlyContinue'

$u = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' |
    Where-Object { $_.DisplayName -like 'Open-Shell*' } | Select-Object -First 1
if ($u -and $u.PSChildName -like '{*}') {
    Write-Host 'Uninstalling Open-Shell...'
    Start-Process msiexec.exe -ArgumentList "/x $($u.PSChildName) /qn /norestart" -Wait
} else {
    Write-Host 'Open-Shell not found - nothing to remove.'
}

Write-Host 'Removing the lock screen override...'
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP' -Recurse
