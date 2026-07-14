@echo off
title Windows 98 for Windows 11 - Offline preparation
echo Downloading the RetroBar and Open-Shell installers into the Installers folder
echo so that INSTALL.bat can run fully offline afterwards...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Extras\Download-Installers.ps1"
pause
