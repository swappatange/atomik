# Windows 98 Theme for Windows 11

A complete Windows 98 experience packaged as a native Windows **`.themepack`** — one double-click on Windows 11 installs and applies everything, nothing to configure afterwards.

## Download

**[Windows98.themepack](./Windows98.themepack)** ← this is the one to install

## How to install (Windows 11)

1. Download `Windows98.themepack`. **Don't rename the file** — Windows extracts its contents into a folder named after it, and the theme's internal paths depend on that name.
2. **Double-click it.** Windows extracts the wallpaper and icons to `%LocalAppData%\Microsoft\Windows\Themes\Windows98\` and applies the theme immediately.

That's it. No admin rights, no extra steps — the wallpaper, screensaver, colors, cursors, sounds and desktop icons are all active as soon as it opens.

## What it applies

| Element | What you get |
|---|---|
| **Wallpaper** | Retro dithered "clouds" wallpaper (1920×1080), recreating the Windows 98 setup-screen sky |
| **Screensaver** | **Mystify** — the classic *Mystify Your Mind* screensaver, still shipped with Windows 11, enabled automatically |
| **Colors** | The full Windows 98 "Windows Standard" scheme: silver-gray chrome, **navy title bars**, navy selection highlight, pale-yellow tooltips |
| **Window style** | AeroLite visual style — squarer window chrome that honors the classic caption colors (much closer to Win98 than default Aero) |
| **Desktop icons** | Win98-style pixel-art icons for **This PC**, **Recycle Bin** (separate empty/full states), **User's Files** and **Network** |
| **Cursors** | The classic black arrow / hourglass-era cursor scheme |
| **Sounds** | The Windows 98 sound scheme — ding, chord, tada, chimes, notify and the recycle sound, mapped from the legacy `.wav` files still in `C:\Windows\Media` |
| **Mode** | Light mode forced on, navy accent tint |

## How to remove

*Settings → Personalization → Themes* → pick any built-in theme (e.g. *Windows (light)*). To delete it, right-click the **Windows 98** tile there and choose *Delete*.

## Files in this folder

- `Windows98.themepack` — the installable package (CAB archive, native Windows format)
- `Windows98.theme` — the theme definition inside the pack, kept here as source
- `DesktopBackground/win98-clouds.png` — the wallpaper
- `Icons/*.ico` — the desktop icons

The loose `.theme` file references assets under `%LocalAppData%\Microsoft\Windows\Themes\Windows98\`, so use the `.themepack` for installation — it puts everything in the right place automatically.

## Known limitations

Windows 11 removed the classic (non-themed) window renderer, so no `.theme`/`.themepack` can bring back 1998 completely:

- The taskbar and Start menu keep Windows 11's layout, and window chrome is flat rather than 3D-beveled (AeroLite gets the colors and squareness right, but not the bevels).
- Everything else — wallpaper, screensaver, colors, icons, cursors, sounds — applies natively.

For the last mile of nostalgia, these free tools pair perfectly with this theme (both optional):

- [RetroBar](https://github.com/dremin/RetroBar) — pixel-accurate Windows 95/98 taskbar replacement
- [Open-Shell](https://github.com/Open-Shell/Open-Shell-Menu) — classic cascading Start menu
