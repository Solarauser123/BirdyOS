# BirdyOS

A simple, lightweight Windows 11 optimisation & hardening tool. One script. No fluff.

---

## What is it?

BirdyOS is a single **PowerShell script** that significantly cleans up, hardens and speeds up a stock Windows 11 installation — all through an easy-to-read console menu.

No custom ISO. No third-party tools. No installers. Just one `.ps1` file you can open in Notepad and understand.

---

## How To use

Download & run the script automatically via PowerShell.

1. Open PowerShell or Terminal, as administrator.
2. Copy and paste the command below into PowerShell:

```PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force
iex (irm "https://raw.githubusercontent.com/Solarauser123/BirdyOS/main/BirdyOS.ps1")
```

## Why?

Modern Windows 11 comes with heavy telemetry, AI features, forced updates, visual effects, bloat apps, reserved storage, advertising IDs, Copilot, Widgets, Recall previews, cloud integrations and more — most users never asked for any of it.

BirdyOS lets you disable almost all of that in one place, while keeping the OS fully usable.

### Main areas covered

- **Privacy** — telemetry (full), CEIP, error reporting, advertising ID, activity history, voice activation, Wi-Fi Sense, Recall, clipboard cloud sync…
- **Security & hardening** — VBS/HVCI, BitLocker auto-encryption, SmartScreen, Defender reporting, anonymous SAM/enumeration, null sessions, LLMNR, remote desktop/assistance…
- **Performance** — animations, Superfetch/SysMain, search indexing, memory compression, background apps, NTFS tweaks, core parking, power plan, sleep study…
- **Debloat** — removes huge list of preinstalled apps + optional OneDrive + Edge (with confirmation)
- **Taskbar & UI** — classic context menu, left-aligned taskbar, hide Widgets/Task View, disable Snap layouts, Copilot, MeetNow, News/Interests, Chat icon…
- **Windows Update** — block feature updates, auto-reboot, driver updates, Delivery Optimization, Insider, DevHome/Outlook forced reinstall…
- **QoL** — show file extensions, verbose boot, disable mouse acceleration, spellcheck, sound ducking, dynamic lighting, spotlight, OOBE privacy nags…
- **Gaming** — disable Game Bar/Xbox overlays, enable hardware-accelerated GPU scheduling, ultimate performance plan tweaks…
- **Network** — disable unneeded bindings, SMB throttling, NIC interrupt moderation…

Everything is optional — pick & choose or **Run Everything** (creates restore point first).

---

## Open Source and Transparent

100% open source (MIT license).  
No binaries, no encoded payloads, no external downloads.  
You can read every registry key, service name, scheduled task and hosts entry the script touches.

---

## Legal Compliance

BirdyOS only changes settings and removes provisioned packages on an already **legitimately licensed** Windows 11 installation.  
It does **not** modify activation, bypass license checks, redistribute Windows files or create modified install media.

Fully compliant with Microsoft terms.

---

## Requirements

- Recommend Windows 11 **23H2 (build 22631)** or newer  
  (some tweaks may partially work on 22H2, but many AI/Recall-related keys are ignored)
- Administrator rights (script auto-elevates)

---
