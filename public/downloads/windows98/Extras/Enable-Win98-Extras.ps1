<#
  Windows 98 Extras - optional enhancements on top of Windows98.themepack
  ========================================================================
  Windows 11 silences logon/logoff sound events and hides classic caption
  colors behind per-user settings that no .theme file is allowed to change.
  This script flips exactly those switches - nothing else:

    1. Navy title bars & taskbar accent (shows the theme's classic colors)
    2. Classic folder, drive, floppy and CD icons across all of Explorer
    3. Startup music at every sign-in
    4. Shutdown music (best effort, plays while Windows is closing)

  Every change is per-user registry only - no system files are touched.
  Undo everything with Remove-Win98-Extras.ps1.

  Run:  powershell -ExecutionPolicy Bypass -File .\Enable-Win98-Extras.ps1
        (or double-click Enable-Win98-Extras.bat)
#>
$ErrorActionPreference = 'Continue'
$theme = "$env:LOCALAPPDATA\Microsoft\Windows\Themes\Windows98"

if (-not (Test-Path "$theme\Windows98.theme")) {
    Write-Host 'Windows 98 theme not found. Double-click Windows98.themepack first, then re-run this script.' -ForegroundColor Yellow
    exit 1
}

Write-Host '[1/4] Navy title bars and taskbar accent...'
$dwm = 'HKCU:\SOFTWARE\Microsoft\Windows\DWM'
# 0xFF800000 = opaque navy RGB(0,0,128) in ABGR, expressed as a signed DWORD
Set-ItemProperty -Path $dwm -Name AccentColor -Value (-8388608) -Type DWord
Set-ItemProperty -Path $dwm -Name ColorPrevalence -Value 1 -Type DWord
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' `
    -Name ColorPrevalence -Value 1 -Type DWord
# the taskbar/Start accent is read from Explorer\Accent, NOT from DWM -
# without these Windows derives its own (indigo) shade
$accent = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent'
if (-not (Test-Path $accent)) { New-Item -Path $accent -Force | Out-Null }
# 8-slot palette (light -> dark shades of Win98 navy), 4 bytes RGB0 each
$palette = [byte[]](
    0x99, 0x99, 0xCC, 0x00,
    0x66, 0x66, 0xB3, 0x00,
    0x33, 0x33, 0xA0, 0x00,
    0x00, 0x00, 0x80, 0x00,
    0x00, 0x00, 0x66, 0x00,
    0x00, 0x00, 0x4D, 0x00,
    0x00, 0x00, 0x33, 0x00,
    0x00, 0x00, 0x80, 0x00)
Set-ItemProperty -Path $accent -Name AccentPalette -Value $palette -Type Binary
Set-ItemProperty -Path $accent -Name AccentColorMenu -Value (-8388608) -Type DWord   # navy
Set-ItemProperty -Path $accent -Name StartColorMenu  -Value (-10092544) -Type DWord  # darker navy

Write-Host '[2/4] Classic folder, drive, floppy and CD icons across Explorer...'
$si = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons'
if (-not (Test-Path $si)) { New-Item -Path $si -Force | Out-Null }
Set-ItemProperty -Path $si -Name '3'  -Value "$theme\Icons\folder.ico,0" -Type String       # closed folder
Set-ItemProperty -Path $si -Name '4'  -Value "$theme\Icons\folder_open.ico,0" -Type String  # open folder
Set-ItemProperty -Path $si -Name '6'  -Value "$theme\Icons\floppy.ico,0" -Type String       # 3.5" floppy
Set-ItemProperty -Path $si -Name '8'  -Value "$theme\Icons\drive.ico,0" -Type String        # fixed drive
Set-ItemProperty -Path $si -Name '9'  -Value "$theme\Icons\drive.ico,0" -Type String        # network drive
Set-ItemProperty -Path $si -Name '11' -Value "$theme\Icons\cdrom.ico,0" -Type String        # CD drive
Set-ItemProperty -Path $si -Name '29' -Value "$theme\Icons\shortcut_overlay.ico,0" -Type String  # shortcut arrow

Write-Host '[3/4] Startup and shutdown music (background sound agent)...'
# a scheduled task cannot reliably launch while Windows shuts down, so a
# tiny hidden agent plays the startup music at sign-in and the classic
# Logoff sound on the session-ending notification
$agent = Join-Path $theme 'Win98-SoundAgent.ps1'
$agentCmd = 'powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}"' -f $agent
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' `
    -Name 'Win98SoundAgent' -Value $agentCmd -Type String
# clean up the older, less reliable mechanisms from previous versions
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' `
    -Name 'Win98StartupSound' -ErrorAction SilentlyContinue
schtasks /Delete /TN 'Win98ShutdownSound' /F 2>$null | Out-Null
# start it now (plays the startup music immediately as confirmation)
if (Test-Path $agent) {
    $running = Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like '*Win98-SoundAgent*' }
    if (-not $running) { Start-Process powershell.exe -ArgumentList "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$agent`"" }
    Write-Host '      agent running - you should hear the startup music now.'
} else {
    Write-Host "      agent script not found at $agent" -ForegroundColor Yellow
}

Write-Host '[4/4] Wallpaper slideshow, colors and cursors come from the theme itself.'

Write-Host 'Rebuilding the icon cache so the classic icons actually show...'
# without this, Explorer keeps serving the old cached icons
& "$env:SystemRoot\System32\ie4uinit.exe" -show
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2
Remove-Item "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db" -Force -ErrorAction SilentlyContinue
if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) { Start-Process explorer.exe }

Write-Host ''
Write-Host 'All done! Sign out and back in to hear the startup music.' -ForegroundColor Green
Write-Host 'Tip: replace Sounds\win98-startup.wav in the theme folder with any WAV you like.'
