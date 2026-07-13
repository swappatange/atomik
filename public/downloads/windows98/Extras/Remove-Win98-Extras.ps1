<#
  Removes everything Enable-Win98-Extras.ps1 configured and returns the
  affected settings to Windows 11 defaults. Safe to run multiple times.
#>
$ErrorActionPreference = 'SilentlyContinue'

Write-Host '[1/5] Restoring default title bar / taskbar accent behaviour...'
$dwm = 'HKCU:\SOFTWARE\Microsoft\Windows\DWM'
Set-ItemProperty -Path $dwm -Name ColorPrevalence -Value 0 -Type DWord
Remove-ItemProperty -Path $dwm -Name AccentColor
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' `
    -Name ColorPrevalence -Value 0 -Type DWord

Write-Host '[2/5] Restoring default folder icons...'
$si = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons'
Remove-ItemProperty -Path $si -Name '3'
Remove-ItemProperty -Path $si -Name '4'

Write-Host '[3/5] Removing startup music...'
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Win98StartupSound'

Write-Host '[4/5] Removing shutdown music task...'
schtasks /Delete /TN 'Win98ShutdownSound' /F | Out-Null

Write-Host '[5/5] Restoring lock screen (needs Administrator)...'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP' -Recurse
} else {
    Write-Host '      skipped - run as Administrator if you had set the lock screen' -ForegroundColor Yellow
}

Write-Host 'Restarting Explorer...'
Stop-Process -Name explorer -Force

Write-Host ''
Write-Host 'Windows 98 extras removed. The theme itself can be switched or deleted in Settings > Personalization > Themes.' -ForegroundColor Green
