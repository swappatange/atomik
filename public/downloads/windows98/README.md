# Windows 98 Theme for Windows 11

A Windows 11 theme (`.theme` file) that brings back the classic Windows 98 look:

- **Authentic teal desktop** (`RGB 0,128,128`) — just like a fresh Win98 install
- **Classic "Windows Standard" color scheme** — silver-gray chrome (`192,192,192`), navy title bars (`0,0,128`), navy selection highlight
- **Classic cursors** — the original black arrow, no Aero cursors
- **Classic sounds** — ding, chord, tada, chimes and the recycle sound, mapped from the legacy `.wav` files that still ship with Windows 11
- **Light mode forced on** — silver accent tint, no dark mode

## Download

**[Windows98.theme](./Windows98.theme)** (right-click → *Save link as…* if it opens as text)

## How to apply (Windows 11)

1. Download `Windows98.theme`.
2. **Double-click the file.** Windows applies the theme immediately and opens *Settings → Personalization → Themes*, where it appears as **Windows 98**.

That's it — no admin rights or installation required.

Alternatively, copy the file to `%LocalAppData%\Microsoft\Windows\Themes\` and select it from *Settings → Personalization → Themes*.

## How to remove

Open *Settings → Personalization → Themes* and pick any built-in theme (e.g. *Windows (light)*). To delete it, right-click the **Windows 98** theme tile and choose *Delete*.

## Known limitations

Windows 11 removed the classic (non-themed) window renderer, so a `.theme` file alone cannot restore everything from 1998:

- Title bars, buttons and the taskbar keep Windows 11's flat rendering — the 3D beveled look is not reproducible via a theme file.
- The teal desktop, color scheme, cursors and sounds all apply correctly.

If you want the *full* retro experience on top of this theme, these free tools pair well with it:

- [RetroBar](https://github.com/dremin/RetroBar) — pixel-accurate Windows 95/98 taskbar replacement
- [Open-Shell](https://github.com/Open-Shell/Open-Shell-Menu) — classic cascading Start menu

Both are optional; the theme works standalone.
