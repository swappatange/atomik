<#
  Elevated helper - everything that genuinely needs Administrator rights:
    - installing Open-Shell (goes to Program Files); provided installer
      first, then winget (built into Windows 11)
    - mirroring the classic Shell Icons into HKLM - newer Windows 11
      builds ignore the per-user override for folder icons, so the
      machine-wide one is required for them to actually change
    - setting the lock screen via the PersonalizationCSP policy key
    - tucking away Open-Shell's own Start-menu shortcuts so the menu
      looks integrated rather than like a separate app
  Launched with -Verb RunAs by Install-Win98-Shell.ps1.
#>
param(
    [string]$Installer = '',
    [string]$LockImage = '',
    [string]$ThemeDir = ''
)
$ErrorActionPreference = 'Continue'

if (-not (Test-Path "$env:ProgramFiles\Open-Shell\StartMenu.exe")) {
    if ($Installer -and (Test-Path $Installer)) {
        Write-Host "Installing Open-Shell from $Installer ..."
        Start-Process $Installer -ArgumentList '/qn ADDLOCAL=StartMenu' -Wait
    }
    if (-not (Test-Path "$env:ProgramFiles\Open-Shell\StartMenu.exe")) {
        $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
        if ($winget) {
            Write-Host 'Installing Open-Shell via winget...'
            & winget.exe install -e --id Open-Shell.Open-Shell-Menu --silent `
                --accept-package-agreements --accept-source-agreements `
                --override '/qn ADDLOCAL=StartMenu' | Out-Null
        } else {
            Write-Host 'winget is not available on this machine.' -ForegroundColor Yellow
        }
    }
}

# keep the Start menu free of Open-Shell's own shortcuts - its settings
# stay available at "C:\Program Files\Open-Shell\StartMenu.exe -settings"
$osShortcuts = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Open-Shell"
if (Test-Path $osShortcuts) {
    Remove-Item $osShortcuts -Recurse -Force -ErrorAction SilentlyContinue
}

if ($ThemeDir -and (Test-Path "$ThemeDir\Icons\folder.ico")) {
    Write-Host 'Applying classic Explorer icons machine-wide (HKLM Shell Icons)...'
    $si = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons'
    if (-not (Test-Path $si)) { New-Item -Path $si -Force | Out-Null }
    Set-ItemProperty -Path $si -Name '3'  -Value "$ThemeDir\Icons\folder.ico,0" -Type String
    Set-ItemProperty -Path $si -Name '4'  -Value "$ThemeDir\Icons\folder_open.ico,0" -Type String
    Set-ItemProperty -Path $si -Name '6'  -Value "$ThemeDir\Icons\floppy.ico,0" -Type String
    Set-ItemProperty -Path $si -Name '8'  -Value "$ThemeDir\Icons\drive.ico,0" -Type String
    Set-ItemProperty -Path $si -Name '9'  -Value "$ThemeDir\Icons\drive.ico,0" -Type String
    Set-ItemProperty -Path $si -Name '11' -Value "$ThemeDir\Icons\cdrom.ico,0" -Type String
    Set-ItemProperty -Path $si -Name '29' -Value "$ThemeDir\Icons\shortcut_overlay.ico,0" -Type String
}

if ($LockImage -and (Test-Path $LockImage)) {
    Write-Host 'Setting the Clouds lock screen...'
    $csp = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
    if (-not (Test-Path $csp)) { New-Item -Path $csp -Force | Out-Null }
    Set-ItemProperty -Path $csp -Name LockScreenImagePath   -Value $LockImage -Type String
    Set-ItemProperty -Path $csp -Name LockScreenImageUrl    -Value $LockImage -Type String
    Set-ItemProperty -Path $csp -Name LockScreenImageStatus -Value 1 -Type DWord
}
