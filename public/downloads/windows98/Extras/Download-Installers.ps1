<#
  Offline preparation - run ONCE on any PC with internet
  =======================================================
  Downloads the two official installers into the Installers folder:
    - RetroBar (.msi)          from winget / github.com/dremin/RetroBar
    - Open-Shell setup (.exe)  from winget / github.com/Open-Shell/Open-Shell-Menu

  After this, INSTALL.bat performs NO downloads at all - the whole
  package installs fully offline. You can also run this on a different
  PC and copy the folder across.
#>
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$dest = Join-Path (Split-Path $PSScriptRoot -Parent) 'Installers'
New-Item -ItemType Directory -Path $dest -Force | Out-Null
$winget = Get-Command winget.exe -ErrorAction SilentlyContinue

function Have([string]$pat) {
    [bool](Get-ChildItem $dest -Filter $pat -ErrorAction SilentlyContinue)
}
function Get-Asset([string]$repo, [string]$pattern) {
    try {
        $rel = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -UseBasicParsing
        $a = $rel.assets | Where-Object name -like $pattern | Select-Object -First 1
        if ($a) {
            Write-Host "Downloading $($a.name) from github.com/$repo ..."
            Invoke-WebRequest $a.browser_download_url -OutFile (Join-Path $dest $a.name) -UseBasicParsing
        }
    } catch {
        Write-Host "GitHub download failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

if (-not (Have '*RetroBar*.msi') -and $winget) {
    Write-Host 'Downloading RetroBar via winget...'
    & winget.exe download -e --id dremin.RetroBar -d $dest `
        --accept-package-agreements --accept-source-agreements | Out-Null
}
if (-not (Have '*RetroBar*.msi')) { Get-Asset 'dremin/RetroBar' '*.msi' }

if (-not (Have '*Open*Shell*.exe') -and $winget) {
    Write-Host 'Downloading Open-Shell via winget...'
    & winget.exe download -e --id Open-Shell.Open-Shell-Menu -d $dest `
        --accept-package-agreements --accept-source-agreements | Out-Null
}
if (-not (Have '*Open*Shell*.exe')) { Get-Asset 'Open-Shell/Open-Shell-Menu' 'OpenShellSetup*.exe' }

Write-Host ''
if ((Have '*RetroBar*.msi') -and (Have '*Open*Shell*.exe')) {
    Write-Host 'Installers folder is complete - INSTALL.bat will now run fully offline.' -ForegroundColor Green
    # produce the single, fully self-contained installer archive
    $pkgRoot = Split-Path $PSScriptRoot -Parent
    $outZip = Join-Path (Split-Path $pkgRoot -Parent) 'Windows98-Complete-OFFLINE.zip'
    Write-Host 'Packing everything into a single offline installer archive...'
    Compress-Archive -Path "$pkgRoot\*" -DestinationPath $outZip -Force
    Write-Host "Created: $outZip" -ForegroundColor Green
    Write-Host 'That one file now contains the entire package including both app'
    Write-Host 'installers - copy it to any Windows 11 PC, extract, run INSTALL.bat:'
    Write-Host 'no internet is used at any point.'
} else {
    Write-Host 'Some installers are still missing - download them manually using the links' -ForegroundColor Yellow
    Write-Host 'in Installers\README.txt and place them in the Installers folder.' -ForegroundColor Yellow
}
