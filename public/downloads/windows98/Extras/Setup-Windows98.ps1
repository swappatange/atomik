<#
  Windows 98 for Windows 11 - master installer
  =============================================
  Runs as YOUR user (no elevation needed to start):
    step 1  installs the theme files directly and applies the theme
    step 2  Enable-Win98-Extras.ps1 (navy title bars, folder/drive
            icons, startup & shutdown music)
    step 3  Install-Win98-Shell.ps1 (RetroBar taskbar; Open-Shell
            Start menu + lock screen via one Administrator prompt)

  Approve the single UAC prompt in step 3 for the Start menu and lock
  screen; declining it still installs everything else.
#>
$ErrorActionPreference = 'Continue'

$root = Split-Path $PSScriptRoot -Parent
$themeDir = "$env:LOCALAPPDATA\Microsoft\Windows\Themes\Windows98"
# full log on the desktop - if anything misbehaves, this file shows exactly what happened
try { Start-Transcript -Path "$env:USERPROFILE\Desktop\Win98-Install-Log.txt" -Append | Out-Null } catch { }
Write-Host "Installing for user: $env:USERNAME"

Write-Host ''
Write-Host '=== STEP 1/3: installing and applying the Windows 98 theme ===' -ForegroundColor Cyan
New-Item -ItemType Directory -Path $themeDir -Force | Out-Null

if (Test-Path "$root\Theme\Windows98.theme") {
    # preferred: the zip ships the theme files loose - plain copy, no
    # dependency on the themepack shell handler
    Copy-Item -Path "$root\Theme\*" -Destination $themeDir -Recurse -Force
} elseif (Test-Path "$root\Windows98.themepack") {
    # fallback: extract the themepack (a CAB archive) with Windows' own expand.exe
    Write-Host 'Theme folder not found in the zip - extracting Windows98.themepack instead...'
    & "$env:SystemRoot\System32\expand.exe" '-F:*' "$root\Windows98.themepack" $themeDir | Out-Null
} else {
    Write-Host "Neither a Theme folder nor Windows98.themepack found next to Extras ($root)." -ForegroundColor Red
    Write-Host 'Unzip the ENTIRE archive first (right-click the zip > Extract All), then run INSTALL.bat from the extracted folder.'
    exit 1
}

if (-not (Test-Path "$themeDir\Windows98.theme")) {
    Write-Host 'Could not install the theme files.' -ForegroundColor Red
    exit 1
}
Write-Host "Theme files installed to $themeDir"

Write-Host 'Applying the theme...'
Start-Process "$themeDir\Windows98.theme"
Start-Sleep -Seconds 6
Stop-Process -Name SystemSettings -Force -ErrorAction SilentlyContinue

$current = (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes' -ErrorAction SilentlyContinue).CurrentTheme
if ($current -and ($current -like '*Windows98*')) {
    Write-Host 'Theme applied.' -ForegroundColor Green
} else {
    Write-Host 'Theme files are in place but Windows did not confirm the switch -' -ForegroundColor Yellow
    Write-Host "if the desktop still looks stock afterwards, double-click $themeDir\Windows98.theme" -ForegroundColor Yellow
}

Write-Host ''
Write-Host '=== STEP 2/3: colors, icons, startup & shutdown music ===' -ForegroundColor Cyan
& "$PSScriptRoot\Enable-Win98-Extras.ps1"

Write-Host ''
Write-Host '=== STEP 3/3: classic taskbar, Start menu and lock screen ===' -ForegroundColor Cyan
& "$PSScriptRoot\Install-Win98-Shell.ps1"

Write-Host ''
Write-Host '=====================================================' -ForegroundColor Green
Write-Host ' Windows 98 experience installed. Enjoy the nostalgia!' -ForegroundColor Green
Write-Host '' -ForegroundColor Green
Write-Host ' IMPORTANT: RESTART YOUR PC now - folder and drive' -ForegroundColor Green
Write-Host ' icons only fully change after a restart, and the' -ForegroundColor Green
Write-Host ' startup music plays at every sign-in from then on.' -ForegroundColor Green
Write-Host '' -ForegroundColor Green
Write-Host ' A full install log was saved to your Desktop as' -ForegroundColor Green
Write-Host ' Win98-Install-Log.txt - share it if anything looks off.' -ForegroundColor Green
Write-Host ' Undo everything with UNINSTALL.bat.' -ForegroundColor Green
Write-Host '=====================================================' -ForegroundColor Green
try { Stop-Transcript | Out-Null } catch { }
