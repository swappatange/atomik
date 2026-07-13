<#
  Windows 98 Shell - the taskbar and Start menu layer
  ====================================================
  Windows 11 provides no mechanism for a theme to reskin its taskbar or
  Start menu, so this script installs the two standard open-source apps
  that recreate them, then configures both for the Windows 98 look:

    - RetroBar   (github.com/dremin/RetroBar)          classic taskbar
    - Open-Shell (github.com/Open-Shell/Open-Shell-Menu) classic Start menu

  Both are downloaded from their official GitHub releases over HTTPS.
  Requires internet. Open-Shell's installer needs Administrator rights;
  RetroBar installs per-user. Undo with Remove-Win98-Shell.ps1.
#>
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$theme = "$env:LOCALAPPDATA\Microsoft\Windows\Themes\Windows98"
$inst = Join-Path $theme 'Installers'
New-Item -ItemType Directory -Path $inst -Force | Out-Null

function Get-LatestAsset([string]$repo, [string]$pattern) {
    try {
        $rel = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -UseBasicParsing
        $a = $rel.assets | Where-Object name -like $pattern | Select-Object -First 1
        if ($a) {
            $f = Join-Path $inst $a.name
            Write-Host "      downloading $($a.name) from github.com/$repo ..."
            Invoke-WebRequest $a.browser_download_url -OutFile $f -UseBasicParsing
            return $f
        }
    } catch { }
    return $null
}

# ---------------------------------------------------------------- RetroBar
Write-Host '[1/3] RetroBar - pixel-accurate Windows 95/98 taskbar...'
$exe = @("$env:LOCALAPPDATA\Programs\RetroBar\RetroBar.exe",
         "$env:ProgramFiles\RetroBar\RetroBar.exe",
         "${env:ProgramFiles(x86)}\RetroBar\RetroBar.exe") |
    Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $exe) {
    $msi = Get-LatestAsset 'dremin/RetroBar' '*.msi'
    if ($msi) {
        Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait
        $exe = @("$env:LOCALAPPDATA\Programs\RetroBar\RetroBar.exe",
                 "$env:ProgramFiles\RetroBar\RetroBar.exe",
                 "${env:ProgramFiles(x86)}\RetroBar\RetroBar.exe") |
            Where-Object { Test-Path $_ } | Select-Object -First 1
    }
}
if (-not $exe) {
    # fall back to the portable build
    $pattern = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { '*arm64*.zip' } else { '*x64*.zip' }
    $zip = Get-LatestAsset 'dremin/RetroBar' $pattern
    if ($zip) {
        $dest = "$env:LOCALAPPDATA\Programs\RetroBar"
        Expand-Archive -Path $zip -DestinationPath $dest -Force
        $exe = Get-ChildItem $dest -Recurse -Filter 'RetroBar.exe' |
            Select-Object -First 1 -ExpandProperty FullName
    }
}
if ($exe) {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' `
        -Name 'RetroBar' -Value "`"$exe`"" -Type String
    Start-Process $exe
    Write-Host '      RetroBar installed, running and set to start at sign-in.'
    Write-Host '      Its default theme is already Windows 95-98; right-click it for options.'
} else {
    Write-Host '      Could not install RetroBar automatically - grab it manually at github.com/dremin/RetroBar/releases' -ForegroundColor Yellow
}

# --------------------------------------------------------------- Open-Shell
Write-Host '[2/3] Open-Shell - the classic cascading Start menu...'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$osExisting = Test-Path "$env:ProgramFiles\Open-Shell\StartMenu.exe"
if ($osExisting) {
    Write-Host '      Open-Shell already installed.'
} elseif (-not $isAdmin) {
    Write-Host '      Skipped - the Open-Shell installer needs Administrator rights.' -ForegroundColor Yellow
    Write-Host '      Re-run INSTALL.bat as Administrator to add the classic Start menu.'
} else {
    $setup = Get-LatestAsset 'Open-Shell/Open-Shell-Menu' 'OpenShellSetup*.exe'
    if ($setup) {
        Start-Process $setup -ArgumentList '/qn ADDLOCAL=StartMenu' -Wait
        $osExisting = Test-Path "$env:ProgramFiles\Open-Shell\StartMenu.exe"
    }
    if (-not $osExisting) {
        Write-Host '      Could not install Open-Shell automatically - grab it at github.com/Open-Shell/Open-Shell-Menu/releases' -ForegroundColor Yellow
    }
}
if ($osExisting) {
    # classic single-column menu with the classic skin
    $os = 'HKCU:\Software\OpenShell\StartMenu\Settings'
    New-Item -Path $os -Force | Out-Null
    Set-ItemProperty -Path $os -Name MenuStyle -Value 'Classic1' -Type String
    Set-ItemProperty -Path $os -Name Skin1 -Value 'Classic skin' -Type String
    Start-Process "$env:ProgramFiles\Open-Shell\StartMenu.exe" -ErrorAction SilentlyContinue
    Write-Host '      Open-Shell configured: classic cascading menu, classic skin.'
}

# ------------------------------------------- hide the Windows 11 taskbar
Write-Host '[3/3] Auto-hiding the Windows 11 taskbar so RetroBar owns the bottom edge...'
if ($exe) {
    try {
        $sr = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
        $v = (Get-ItemProperty -Path $sr).Settings
        $v[8] = 3   # 3 = auto-hide, 2 = always show
        Set-ItemProperty -Path $sr -Name Settings -Value $v
        Stop-Process -Name explorer -Force
        Write-Host '      Windows 11 taskbar set to auto-hide (reversible in Settings > Taskbar).'
    } catch {
        Write-Host '      Could not toggle auto-hide - enable it manually: Settings > Personalization > Taskbar > Taskbar behaviors.' -ForegroundColor Yellow
    }
} else {
    Write-Host '      Skipped (RetroBar is not installed).'
}

Write-Host ''
Write-Host 'Shell layer done - taskbar and Start menu are now Windows 98.' -ForegroundColor Green
