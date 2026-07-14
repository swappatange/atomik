<#
  Windows 98 sound agent
  ======================
  Windows 11 removed logon/logoff sound playback, and a scheduled task
  cannot reliably start a new process while Windows is shutting down.
  This tiny agent is the dependable way: it starts hidden at sign-in,
  plays the startup music once, then waits for the session-ending
  notification and plays the classic Logoff sound synchronously while
  Windows closes the session.

  It is started by a Run registry entry created by
  Enable-Win98-Extras.ps1 and removed by Remove-Win98-Extras.ps1.
  Memory footprint is a single idle hidden PowerShell process.
#>
$themeDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$startup = Join-Path $themeDir 'Sounds\win98-startup.wav'
$shutdown = Join-Path $themeDir 'Sounds\logoff.wav'

Add-Type -ReferencedAssemblies 'System.Windows.Forms', 'System' -TypeDefinition @"
using System;
using Microsoft.Win32;

public static class Win98SoundAgent
{
    public static void Run(string startupWav, string shutdownWav)
    {
        try { new System.Media.SoundPlayer(startupWav).PlaySync(); } catch { }
        SystemEvents.SessionEnding += delegate(object s, SessionEndingEventArgs e)
        {
            // played synchronously so the sound finishes before the session dies
            try { new System.Media.SoundPlayer(shutdownWav).PlaySync(); } catch { }
        };
        System.Windows.Forms.Application.Run();
    }
}
"@
[Win98SoundAgent]::Run($startup, $shutdown)
