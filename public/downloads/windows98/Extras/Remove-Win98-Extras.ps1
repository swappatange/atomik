<#
  Removes everything Enable-Win98-Extras.ps1 configured and returns the
  affected settings to Windows 11 defaults. Safe to run multiple times.
#>
$ErrorActionPreference = 'SilentlyContinue'

Write-Host '[1/4] Restoring default title bar / taskbar accent behaviour...'
$dwm = 'HKCU:\SOFTWARE\Microsoft\Windows\DWM'
Set-ItemProperty -Path $dwm -Name ColorPrevalence -Value 0 -Type DWord
Remove-ItemProperty -Path $dwm -Name AccentColor
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' `
    -Name ColorPrevalence -Value 0 -Type DWord
# drop the navy accent palette; Windows regenerates these when an accent
# color is picked in Settings > Personalization > Colors
$accent = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent'
Remove-ItemProperty -Path $accent -Name AccentPalette
Remove-ItemProperty -Path $accent -Name AccentColorMenu
Remove-ItemProperty -Path $accent -Name StartColorMenu

Write-Host '[2/4] Restoring default folder and drive icons...'
$si = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons'
Remove-ItemProperty -Path $si -Name '3', '4', '6', '8', '9', '11'

Write-Host '[3/4] Removing startup music...'
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Win98StartupSound'

Write-Host '[4/4] Removing shutdown music task...'
schtasks /Delete /TN 'Win98ShutdownSound' /F | Out-Null
# (the lock screen override is removed by Remove-Win98-Shell.ps1's elevated step)

Write-Host 'Restarting Explorer...'
Stop-Process -Name explorer -Force

Write-Host ''
Write-Host 'Windows 98 extras removed. The theme itself can be switched or deleted in Settings > Personalization > Themes.' -ForegroundColor Green
