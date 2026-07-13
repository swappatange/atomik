@echo off
title Windows 98 for Windows 11 - Installer
echo Installing the complete Windows 98 experience (theme + colors + music + taskbar + Start menu)...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Extras\Setup-Windows98.ps1"
pause
