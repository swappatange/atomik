<#
  Windows 98 for Windows 11 - master installer
  =============================================
  One run does everything:
    step 1  applies Windows98.themepack (wallpaper, colors, window style,
            desktop icons, cursors, screensaver, event sounds)
    step 2  Enable-Win98-Extras.ps1 (navy title bars, folder/drive icons,
            startup & shutdown music, lock screen)
    step 3  Install-Win98-Shell.ps1 (RetroBar taskbar + Open-Shell
            classic Start menu, Windows 11 taskbar auto-hidden)

  Administrator rights are requested so the Start menu installer and the
  lock screen work; if you decline, those two pieces are skipped and
  everything else still applies.
#>
$ErrorActionPreference = 'Continue'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host 'Requesting Administrator rights (for the Start menu installer and lock screen)...'
    Write-Host 'If you decline, everything else still installs.'
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList `
            "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    } catch {
        Write-Host 'Continuing without Administrator rights.' -ForegroundColor Yellow
    }
}

$root = Split-Path $PSScriptRoot -Parent
$pack = Join-Path $root 'Windows98.themepack'
$themeDir = "$env:LOCALAPPDATA\Microsoft\Windows\Themes\Windows98"

Write-Host ''
Write-Host '=== STEP 1/3: applying the Windows 98 theme ===' -ForegroundColor Cyan
if (Test-Path "$themeDir\Windows98.theme") {
    Write-Host 'Theme already installed - re-applying.'
}
if (Test-Path $pack) {
    Start-Process $pack
    Start-Sleep -Seconds 8
    Stop-Process -Name SystemSettings -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Windows98.themepack not found next to the Extras folder ($pack)." -ForegroundColor Red
    Write-Host 'Unzip the whole archive before running this script.'
    exit 1
}
if (-not (Test-Path "$themeDir\Windows98.theme")) {
    Start-Sleep -Seconds 4   # slower machines
}
if (-not (Test-Path "$themeDir\Windows98.theme")) {
    Write-Host 'The theme did not finish installing - double-click Windows98.themepack yourself, then re-run this script.' -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host '=== STEP 2/3: colors, icons, startup & shutdown music, lock screen ===' -ForegroundColor Cyan
& "$PSScriptRoot\Enable-Win98-Extras.ps1"

Write-Host ''
Write-Host '=== STEP 3/3: classic taskbar and Start menu ===' -ForegroundColor Cyan
& "$PSScriptRoot\Install-Win98-Shell.ps1"

Write-Host ''
Write-Host '=====================================================' -ForegroundColor Green
Write-Host ' Windows 98 experience installed. Enjoy the nostalgia!' -ForegroundColor Green
Write-Host ' Sign out and back in to hear the startup music.' -ForegroundColor Green
Write-Host ' Undo everything with UNINSTALL.bat.' -ForegroundColor Green
Write-Host '=====================================================' -ForegroundColor Green
