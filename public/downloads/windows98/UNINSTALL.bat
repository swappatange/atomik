@echo off
title Windows 98 for Windows 11 - Uninstaller
echo Removing the Windows 98 experience and restoring Windows 11 defaults...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Extras\Uninstall-Windows98.ps1"
pause
