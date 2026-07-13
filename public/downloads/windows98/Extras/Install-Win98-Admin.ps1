<#
  Elevated helper - the ONLY two things that genuinely need
  Administrator rights:
    - installing Open-Shell (goes to Program Files); tries the provided
      installer first, then winget (built into Windows 11)
    - setting the lock screen via the PersonalizationCSP policy key
  Launched with -Verb RunAs by Install-Win98-Shell.ps1; absolute paths
  are passed in so it works even if elevation uses another account.
#>
param(
    [string]$Installer = '',
    [string]$LockImage = ''
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

if ($LockImage -and (Test-Path $LockImage)) {
    Write-Host 'Setting the Clouds lock screen...'
    $csp = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
    if (-not (Test-Path $csp)) { New-Item -Path $csp -Force | Out-Null }
    Set-ItemProperty -Path $csp -Name LockScreenImagePath   -Value $LockImage -Type String
    Set-ItemProperty -Path $csp -Name LockScreenImageUrl    -Value $LockImage -Type String
    Set-ItemProperty -Path $csp -Name LockScreenImageStatus -Value 1 -Type DWord
}
