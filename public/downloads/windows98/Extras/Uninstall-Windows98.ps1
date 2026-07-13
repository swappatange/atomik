<#
  Windows 98 for Windows 11 - master uninstaller.
  Runs as YOUR user; one Administrator prompt appears for removing
  Open-Shell and the lock screen override. Removes the shell layer and
  the extras, then switches back to the standard Windows (light) theme.
#>
$ErrorActionPreference = 'Continue'
Write-Host "Uninstalling for user: $env:USERNAME"

Write-Host '=== Removing the classic taskbar and Start menu ===' -ForegroundColor Cyan
& "$PSScriptRoot\Remove-Win98-Shell.ps1"

Write-Host ''
Write-Host '=== Removing extras (colors, icons, music, lock screen) ===' -ForegroundColor Cyan
& "$PSScriptRoot\Remove-Win98-Extras.ps1"

Write-Host ''
Write-Host '=== Switching back to the Windows (light) theme ===' -ForegroundColor Cyan
$aero = "$env:SystemRoot\Resources\Themes\aero.theme"
if (Test-Path $aero) {
    Start-Process $aero
    Start-Sleep -Seconds 6
    Stop-Process -Name SystemSettings -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host 'Done. To delete the theme itself: Settings > Personalization > Themes >' -ForegroundColor Green
Write-Host 'right-click the Windows 98 tile > Delete.' -ForegroundColor Green
