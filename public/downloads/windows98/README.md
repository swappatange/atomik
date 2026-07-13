# Windows 98 Theme for Windows 11

A complete Windows 98 experience for Windows 11, packaged in Microsoft's native **`.themepack`** format. One double-click installs and applies everything — wallpapers, screensaver, colors, window style, desktop icons, cursors and sounds. Nothing to configure afterwards, and nothing about Windows 11 is modified or restricted.

![Preview](./preview.png)

## Download

**[Windows98.themepack](./Windows98.themepack)** (~1 MB) ← the installable package

## Install (Windows 11)

1. Download `Windows98.themepack`. **Keep the filename** — Windows extracts the pack into a folder named after the file, and the theme's asset paths depend on it.
2. **Double-click it.** Windows extracts everything to `%LocalAppData%\Microsoft\Windows\Themes\Windows98\` and applies the theme instantly.

No admin rights, no scripts, no extra steps.

## Everything it applies

| Component | Details |
|---|---|
| **Wallpaper** | "Clouds" (2560×1440) — a from-scratch recreation of the Windows 98 sky, with period-correct dithering. Applied by default. |
| **Bonus wallpapers** | Recreations of the classic Win98 desktop patterns, installed alongside: **Teal** (the stock desktop), **Blue Rivets**, **Waves** and **Sandstone**. Switch in *Settings → Personalization → Background → Browse photos* (they're in the theme folder). |
| **Screensaver** | **Mystify** — the classic *Mystify Your Mind*, still shipped with Windows 11 — enabled automatically. |
| **Color scheme** | The complete Windows 98 "Windows Standard" palette, all 30 system colors: navy title bars and selection, silver-gray chrome, teal desktop fallback, pale-yellow tooltips. |
| **Window style** | **AeroLite** — Microsoft's own alternate visual style that ships with Windows 11. It renders squared window chrome and honors the classic caption colors, so title bars actually go navy. Transparency off, light mode, navy accent. |
| **Desktop icons** | Hand-drawn Win98-style pixel art for **My Computer** (This PC), **My Documents**, **Network**, and **Recycle Bin** — with separate **empty and full bin states** that switch automatically, just like 1998. Crisp at 16/32/48/64 px. |
| **Cursors** | The classic scheme — the original black arrow, I-beam and hourglass-era pointers built into Windows. |
| **Sounds** | The Windows 98 event scheme mapped from the legacy `.wav` files still shipped in `C:\Windows\Media`: ding, chord, tada, chimes, notify, the Explorer navigation click, and the recycle sound. |

## Safe by design — Windows 11 stays fully functional

This package deliberately uses **only** mechanisms Microsoft supports and components that ship with Windows 11:

- It's a standard `.themepack` — the exact same format Microsoft distributes themes in. No installer, no executable code.
- The visual style (AeroLite), screensaver (Mystify) and sounds are all **stock Windows 11 files** — nothing is patched, injected or replaced. No UXTheme hacks, no third-party theming engine, nothing running in the background.
- Snap layouts, widgets, virtual desktops, dark-mode toggle, taskbar, Start menu, updates — all Windows 11 features keep working exactly as before.
- **Fully reversible in one click:** *Settings → Personalization → Themes* → pick any built-in theme. To uninstall completely, right-click the *Windows 98* tile there and choose *Delete*.

## Files in this folder

| File | Purpose |
|---|---|
| `Windows98.themepack` | The installable package (CAB archive) |
| `Windows98.theme` | The theme definition inside the pack (source) |
| `DesktopBackground/*.png` | Clouds + Teal, Blue Rivets, Waves, Sandstone |
| `Icons/*.ico` | The four desktop icons (five files — two bin states) |
| `preview.png` | Desktop mock-up of the applied theme |

## Honest limitations

Windows 11 removed the classic (non-themed) window renderer, so no theme file — from anyone — can restore the 3D-beveled window borders or replace the Windows 11 taskbar/Start menu. This theme gets every officially-themeable surface right and leaves the rest of the OS untouched. If you want to go all the way, these free, well-known tools layer cleanly on top:

- [RetroBar](https://github.com/dremin/RetroBar) — pixel-accurate Windows 95/98 taskbar
- [Open-Shell](https://github.com/Open-Shell/Open-Shell-Menu) — classic cascading Start menu

Both optional — the theme is complete on its own.
