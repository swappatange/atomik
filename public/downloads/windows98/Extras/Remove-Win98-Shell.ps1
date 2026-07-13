<#
  Removes the Windows 98 shell layer: uninstalls RetroBar and Open-Shell
  and restores the Windows 11 taskbar. Safe to run multiple times.
#>
$ErrorActionPreference = 'SilentlyContinue'
$theme = "$env:LOCALAPPDATA\Microsoft\Windows\Themes\Windows98"
$inst = Join-Path $theme 'Installers'

Write-Host '[1/3] Removing RetroBar...'
Stop-Process -Name RetroBar -Force
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'RetroBar'
$msi = Get-ChildItem $inst -Filter '*.msi' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($msi) { Start-Process msiexec.exe -ArgumentList "/x `"$($msi.FullName)`" /qn /norestart" -Wait }
Remove-Item "$env:LOCALAPPDATA\Programs\RetroBar" -Recurse -Force

Write-Host '[2/3] Removing Open-Shell (needs Administrator)...'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    $u = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' |
        Where-Object { $_.DisplayName -like 'Open-Shell*' } | Select-Object -First 1
    if ($u -and $u.PSChildName -like '{*}') {
        Start-Process msiexec.exe -ArgumentList "/x $($u.PSChildName) /qn /norestart" -Wait
        Write-Host '      Open-Shell uninstalled.'
    } else {
        Write-Host '      Open-Shell not found - nothing to remove.'
    }
} else {
    Write-Host '      Skipped - run as Administrator to uninstall Open-Shell.' -ForegroundColor Yellow
}

Write-Host '[3/3] Restoring the Windows 11 taskbar...'
try {
    $sr = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
    $v = (Get-ItemProperty -Path $sr).Settings
    $v[8] = 2   # always show
    Set-ItemProperty -Path $sr -Name Settings -Value $v
} catch { }
Stop-Process -Name explorer -Force

Write-Host ''
Write-Host 'Shell layer removed - taskbar and Start menu are Windows 11 again.' -ForegroundColor Green
