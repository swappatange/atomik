<#
  Windows 98 Shell - the taskbar and Start menu layer
  ====================================================
  Installs and configures:
    - RetroBar   (github.com/dremin/RetroBar)          classic taskbar
    - Open-Shell (github.com/Open-Shell/Open-Shell-Menu) classic Start menu

  Install strategy, most reliable first:
    1. installer files in the Installers folder (fully offline - run
       PREPARE-OFFLINE.bat once beforehand to populate it)
    2. winget - the package manager built into Windows 11
    3. direct download from the official GitHub releases

  Startup order matters: the Windows 11 taskbar is hidden and Explorer
  restarted BEFORE RetroBar/Open-Shell launch, so the work area they
  see is final - this is what keeps the Start menu flush with the
  RetroBar taskbar instead of floating with a gap.

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
Write-Host '[1/4] RetroBar - pixel-accurate Windows 95/98 taskbar...'
$exe = Find-RetroBar

if (-not $exe) {
    $localMsi = Get-ChildItem $localInstallers -Filter '*RetroBar*.msi' -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($localMsi) {
        Write-Host "      installing from bundled $($localMsi.Name) (offline)..."
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
    # seed the classic theme on first install (RetroBar keeps user changes after)
    $rbDir = "$env:LOCALAPPDATA\RetroBar"
    if (-not (Test-Path "$rbDir\settings.json")) {
        New-Item -ItemType Directory -Path $rbDir -Force | Out-Null
        '{ "Theme": "Windows 95-98" }' | Out-File "$rbDir\settings.json" -Encoding ascii
    }
    Write-Host '      RetroBar installed and set to start at sign-in.'
} else {
    Write-Host '      RetroBar could not be installed by any method.' -ForegroundColor Yellow
    Write-Host '      Run PREPARE-OFFLINE.bat on a PC with internet, or place its .msi'
    Write-Host '      in the Installers folder, then re-run INSTALL.bat.'
}

# ------------------------------------------------- classic Show Desktop
Write-Host '[2/4] Classic "Show Desktop" button (Quick Launch, just like 1998)...'
$ql = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch"
New-Item -ItemType Directory -Path $ql -Force | Out-Null
@"
[Shell]
Command=2
IconFile=explorer.exe,3
[Taskbar]
Command=ToggleDesktop
"@ | Out-File -FilePath "$ql\Show Desktop.scf" -Encoding ascii
Write-Host '      one click collapses all windows to the desktop; click again to restore.'

# ---------------------------------------- Open-Shell + lock screen (elevated)
Write-Host '[3/4] Open-Shell Start menu + lock screen (one Administrator prompt)...'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$osExisting = Test-Path "$env:ProgramFiles\Open-Shell\StartMenu.exe"
$lockImage = "$theme\DesktopBackground\win98-clouds.png"

if ($osExisting) {
    Write-Host '      Open-Shell already installed.'
} else {
    $setup = Get-ChildItem $localInstallers -Filter '*Open*Shell*.exe' -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
    if ($setup) { Write-Host "      using bundled $(Split-Path $setup -Leaf) (offline)..." }
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
        Write-Host '      Open-Shell was not installed - run PREPARE-OFFLINE.bat first, or place' -ForegroundColor Yellow
        Write-Host '      OpenShellSetup*.exe in the Installers folder and re-run INSTALL.bat.' -ForegroundColor Yellow
    }
}
if ($osExisting) {
    $os = 'HKCU:\Software\OpenShell\StartMenu\Settings'
    New-Item -Path $os -Force | Out-Null
    Set-ItemProperty -Path $os -Name MenuStyle -Value 'Classic1' -Type String
    Set-ItemProperty -Path $os -Name Skin1 -Value 'Classic skin' -Type String
    Set-ItemProperty -Path $os -Name EnableStartButton -Value 0 -Type DWord
    Write-Host '      Open-Shell configured: classic cascading menu, classic skin.'
}

# -------------------- hide Win11 taskbar FIRST, then launch the shell apps
Write-Host '[4/4] Hiding the Windows 11 taskbar, then starting the classic shell...'
try {
    $sr = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
    $v = (Get-ItemProperty -Path $sr).Settings
    $v[8] = 3   # 3 = auto-hide, 2 = always show
    Set-ItemProperty -Path $sr -Name Settings -Value $v
} catch {
    Write-Host '      Could not toggle auto-hide - enable it manually: Settings > Personalization > Taskbar > Taskbar behaviors.' -ForegroundColor Yellow
}
Stop-Process -Name RetroBar -Force -ErrorAction SilentlyContinue
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 4        # let Explorer settle so the work area is final
if ($exe) { Start-Process $exe }
if ($osExisting) { Start-Process "$env:ProgramFiles\Open-Shell\StartMenu.exe" -ErrorAction SilentlyContinue }

Write-Host ''
Write-Host 'Shell layer done - taskbar and Start menu are now Windows 98.' -ForegroundColor Green
Write-Host 'If the Start menu ever opens with a gap above the taskbar, sign out and back in once.'
