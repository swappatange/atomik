# Windows 98 Theme for Windows 11 — Complete Edition

The full Windows 98 experience on Windows 11: wallpapers, screensaver, classic colors with **real navy title bars**, desktop **and folder** icons, cursors, event sounds, **startup & shutdown music**, and the lock screen. Nothing about Windows 11 is patched or restricted, and every piece is reversible.

![Preview](./preview.png)

## Download

| File | What it is |
|---|---|
| **[Windows98-Complete.zip](./Windows98-Complete.zip)** (~2 MB) | **Recommended** — themepack + extras scripts + quick-start |
| [Windows98.themepack](./Windows98.themepack) | Just the theme, if you don't want the extras |

## Install

**Step 1 — the theme (required).** Unzip, double-click `Windows98.themepack`. Wallpaper, colors, window style, desktop icons, cursors, screensaver and event sounds apply instantly. *(Keep the filename — Windows extracts the pack into a folder named after it.)*

**Step 2 — the extras (recommended).** Double-click `Extras\Enable-Win98-Extras.bat`.

Why step 2 exists: Windows 11 itself **disables logon/logoff music** and **hides classic title-bar colors** behind per-user settings that no `.theme` file is permitted to change — that's why the first version looked washed-out and silent at boot. The extras script flips exactly those user-level switches:

- **Navy title bars + navy taskbar accent** — the classic color scheme finally shows on window chrome
- **Classic yellow folder icons** across every Explorer window
- **Startup music** at every sign-in
- **Shutdown music** as Windows closes (best effort — very fast shutdowns may cut it off)
- **Clouds lock screen** (only when the script is run as Administrator; skipped otherwise)

Everything it does is per-user registry only — view the `.ps1` source yourself, it's short and commented.

## Everything covered

| Component | Details |
|---|---|
| **Wallpaper** | "Clouds" 2560×1440, from-scratch recreation with period-correct dithering, applied by default |
| **Bonus wallpapers** | Teal (stock desktop), Blue Rivets, Waves, Sandstone — all installed locally, switchable in Settings → Background |
| **Screensaver** | Mystify (*Mystify Your Mind*), enabled automatically |
| **Colors** | All 30 Windows 98 "Windows Standard" system colors — navy captions/selection, silver chrome, teal fallback, pale-yellow tooltips |
| **Window style** | AeroLite (ships with Windows 11) — squared chrome that honors classic caption colors; transparency off; light mode |
| **Desktop icons** | Pixel-art My Computer, My Documents, Network, Recycle Bin with auto-switching empty/full states (16/32/48/64 px) |
| **Folder icons** | Classic yellow closed/open folders applied Explorer-wide (extras) |
| **Cursors** | The built-in classic scheme — original black arrow and hourglass-era pointers |
| **Event sounds** | The authentic Win95/98-era `.wav` files still shipped in `C:\Windows\Media`: ding, chord, tada, chimes, notify, navigation click, recycle |
| **Startup / shutdown music** | Original warm synth compositions in the spirit of the era, bundled in the pack and wired up by the extras script |
| **Lock screen** | Clouds (extras, admin) |

**About the startup music:** Microsoft's actual 1998 recordings are copyrighted and can't be redistributed. The pack ships original compositions in the same spirit — if you own the originals, just replace `Sounds\win98-startup.wav` / `win98-shutdown.wav` in `%LocalAppData%\Microsoft\Windows\Themes\Windows98\` and they'll play instead. No re-run needed.

## Uninstall

- **Theme:** *Settings → Personalization → Themes* → pick any built-in theme (right-click the Windows 98 tile → *Delete* to remove it fully).
- **Extras:** double-click `Extras\Remove-Win98-Extras.bat` — restores accent behaviour, folder icons, sounds and lock screen to Windows 11 defaults.

## Safe by design

- Standard Microsoft `.themepack` format; the extras are two short, readable PowerShell scripts touching per-user registry values only.
- Visual style, screensaver and event sounds are stock Windows 11 files — no patching, no injection, no third-party theming engine, nothing resident in memory.
- Snap layouts, widgets, virtual desktops, taskbar, Windows Update — all untouched and fully functional.

## Honest limitations

Windows 11 removed the classic window renderer, so 3D-beveled borders and a true Win98 taskbar/Start menu are impossible for **any** theme, from anyone — that requires replacement apps, not themes. This package covers every surface Windows 11 allows. For the final stretch: [RetroBar](https://github.com/dremin/RetroBar) (classic taskbar) and [Open-Shell](https://github.com/Open-Shell/Open-Shell-Menu) (classic Start menu) layer cleanly on top.

## Files

`Windows98-Complete.zip` (bundle) · `Windows98.themepack` (installer) · `Windows98.theme` (definition source) · `DesktopBackground/` (5 wallpapers) · `Icons/` (7 icons) · `Sounds/` (startup/shutdown music) · `Extras/` (enable/remove scripts) · `preview.png`
