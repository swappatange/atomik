<#
  Elevated helper - the ONLY two things that genuinely need
  Administrator rights:
    - running the Open-Shell installer (installs to Program Files)
    - setting the lock screen via the PersonalizationCSP policy key
  Launched with -Verb RunAs by Install-Win98-Shell.ps1; absolute paths
  are passed in so it works even if elevation uses another account.
#>
param(
    [string]$Installer = '',
    [string]$LockImage = ''
)
$ErrorActionPreference = 'Continue'

if ($Installer -and (Test-Path $Installer)) {
    Write-Host "Installing Open-Shell from $Installer ..."
    Start-Process $Installer -ArgumentList '/qn ADDLOCAL=StartMenu' -Wait
} elseif ($Installer) {
    Write-Host "Installer not found: $Installer" -ForegroundColor Yellow
}

if ($LockImage -and (Test-Path $LockImage)) {
    Write-Host 'Setting the Clouds lock screen...'
    $csp = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
    if (-not (Test-Path $csp)) { New-Item -Path $csp -Force | Out-Null }
    Set-ItemProperty -Path $csp -Name LockScreenImagePath   -Value $LockImage -Type String
    Set-ItemProperty -Path $csp -Name LockScreenImageUrl    -Value $LockImage -Type String
    Set-ItemProperty -Path $csp -Name LockScreenImageStatus -Value 1 -Type DWord
}
