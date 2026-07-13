<#
  Windows 98 Shell - the taskbar and Start menu layer
  ====================================================
  Windows 11 provides no mechanism for a theme to reskin its taskbar or
  Start menu, so this script installs the two standard open-source apps
  that recreate them, then configures both for the Windows 98 look:

    - RetroBar   (github.com/dremin/RetroBar)          classic taskbar
    - Open-Shell (github.com/Open-Shell/Open-Shell-Menu) classic Start menu

  Install strategy, most reliable first:
    1. installer files you placed in the Installers folder (offline)
    2. winget - the package manager built into Windows 11
    3. direct download from the official GitHub releases

  Undo with Remove-Win98-Shell.ps1.
#>
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$theme = "$env:LOCALAPPDATA\Microsoft\Windows\Themes\Windows98"
$root = Split-Path $PSScriptRoot -Parent
$localInstallers = Join-Path $root 'Installers'
$inst = Join-Path $theme 'Installers'
New-Item -ItemType Directory -Path $inst -Force | Out-Null
$winget = Get-Command winget.exe -ErrorAction SilentlyContinue

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
        Write-Host "      no asset matching $pattern in the latest $repo release" -ForegroundColor Yellow
    } catch {
        Write-Host "      GitHub download failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    return $null
}

function Find-RetroBar {
    @("$env:LOCALAPPDATA\Programs\RetroBar\RetroBar.exe",
      "$env:ProgramFiles\RetroBar\RetroBar.exe",
      "${env:ProgramFiles(x86)}\RetroBar\RetroBar.exe") |
        Where-Object { Test-Path $_ } | Select-Object -First 1
}

# ---------------------------------------------------------------- RetroBar
Write-Host '[1/3] RetroBar - pixel-accurate Windows 95/98 taskbar...'
$exe = Find-RetroBar

if (-not $exe) {
    $localMsi = Get-ChildItem $localInstallers -Filter '*RetroBar*.msi' -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($localMsi) {
        Write-Host "      installing from bundled $($localMsi.Name) ..."
        Start-Process msiexec.exe -ArgumentList "/i `"$($localMsi.FullName)`" /qn /norestart" -Wait
        $exe = Find-RetroBar
    }
}
if (-not $exe -and $winget) {
    Write-Host '      installing via winget (dremin.RetroBar)...'
    & winget.exe install -e --id dremin.RetroBar --silent `
        --accept-package-agreements --accept-source-agreements | Out-Null
    $exe = Find-RetroBar
}
if (-not $exe) {
    $msi = Get-LatestAsset 'dremin/RetroBar' '*.msi'
    if ($msi) {
        Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait
        $exe = Find-RetroBar
    }
}
if (-not $exe) {
    # last resort: the portable build
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
    Write-Host '      RetroBar could not be installed by any method.' -ForegroundColor Yellow
    Write-Host '      Manual fix: download it from github.com/dremin/RetroBar/releases,'
    Write-Host '      or place its .msi in the Installers folder and re-run INSTALL.bat.'
}

# ---------------------------------------- Open-Shell + lock screen (elevated)
Write-Host '[2/3] Open-Shell Start menu + lock screen (one Administrator prompt)...'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$osExisting = Test-Path "$env:ProgramFiles\Open-Shell\StartMenu.exe"
$lockImage = "$theme\DesktopBackground\win98-clouds.png"

if ($osExisting) {
    Write-Host '      Open-Shell already installed.'
} else {
    # prefer a bundled installer; else download; else the elevated child
    # falls back to winget on its own
    $setup = Get-ChildItem $localInstallers -Filter 'OpenShellSetup*.exe' -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
    if (-not $setup) { $setup = Get-LatestAsset 'Open-Shell/Open-Shell-Menu' 'OpenShellSetup*.exe' }
    if (-not $setup) { $setup = '' }

    $adminScript = Join-Path $PSScriptRoot 'Install-Win98-Admin.ps1'
    $adminArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$adminScript`" -Installer `"$setup`" -LockImage `"$lockImage`""
    try {
        if ($isAdmin) {
            & $adminScript -Installer $setup -LockImage $lockImage
        } else {
            Start-Process powershell.exe -ArgumentList $adminArgs -Verb RunAs -Wait
        }
    } catch {
        Write-Host '      Administrator prompt declined - skipping Start menu and lock screen.' -ForegroundColor Yellow
    }
    $osExisting = Test-Path "$env:ProgramFiles\Open-Shell\StartMenu.exe"
    if (-not $osExisting) {
        Write-Host '      Open-Shell was not installed - you can add it later from github.com/Open-Shell/Open-Shell-Menu/releases,' -ForegroundColor Yellow
        Write-Host '      or place OpenShellSetup*.exe in the Installers folder and re-run INSTALL.bat.' -ForegroundColor Yellow
    }
}
if ($osExisting) {
    # classic single-column menu, classic skin; the floating Start button
    # overlay is disabled - it sits badly on the Windows 11 taskbar, and
    # RetroBar provides the proper classic Start button instead
    $os = 'HKCU:\Software\OpenShell\StartMenu\Settings'
    New-Item -Path $os -Force | Out-Null
    Set-ItemProperty -Path $os -Name MenuStyle -Value 'Classic1' -Type String
    Set-ItemProperty -Path $os -Name Skin1 -Value 'Classic skin' -Type String
    Set-ItemProperty -Path $os -Name EnableStartButton -Value 0 -Type DWord
    Start-Process "$env:ProgramFiles\Open-Shell\StartMenu.exe" -ErrorAction SilentlyContinue
    Write-Host '      Open-Shell configured: classic cascading menu; open it with the'
    Write-Host '      Windows key or RetroBar''s Start button.'
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
Write-Host 'Shell layer done.' -ForegroundColor Green
