# BirdyOS

A simple, lightweight Windows 11 optimisation tool. One script, no unnecessary extras.

---

## What is it?

BirdyOS is a single PowerShell script that cleans up and optimises Windows 11. It disables telemetry, applies privacy and performance tweaks, and hardens your system — all from one place with a clean console menu.

No custom ISO. No third party installers. No extra files. Just one script you can read yourself.

---

## Why?

Windows 11 out of the box ships with a lot of features and data collection that most people never asked for. BirdyOS gives you a simple way to take control.

- **Privacy** — disables telemetry, Bing search, data collection, CEIP, error reporting and WMI autologgers
- **Security** — disables BitLocker auto encryption, VBS, SmartScreen, remote assistance and blocks anonymous SAM enumeration
- **Performance** — disables animations, background apps, search indexing, fast startup and unneeded network bindings
- **Optimisations** — cleans up content delivery, storage sense, scheduled telemetry tasks and reserved storage
- **Taskbar** — removes Bing, cloud search, online suggestions and search history from the taskbar
- **Simple** — one `.ps1` file, works on any Windows 11 install, shows every change as it applies

---

## Open Source and Transparent

BirdyOS is fully open source under the MIT license. Every single change the script makes is visible in plain text — no compiled binaries, no hidden executables, no obfuscated code. You can read exactly what it does before running anything.

---

## Legal Compliance

BirdyOS does not redistribute or modify any Windows installation files. It works entirely by applying settings on an already installed, legitimately licensed copy of Windows 11. BirdyOS does not touch, bypass or alter Windows activation in any way.

This keeps BirdyOS fully compliant with the Microsoft Windows Usage Terms.

---

## Requirements

- Windows 11 23H2 or newer
- Administrator rights

---

## How to use

```
1. Download BirdyOS.ps1
2. Right click → Run with PowerShell
3. It will auto-elevate to Administrator
4. Pick what you want from the menu
5. Done
```

---

## What's in the menu

| Option | What it does |
|---|---|
| Privacy Tweaks | Telemetry, data collection, CEIP, error reporting, WMI autologgers |
| Security Tweaks | BitLocker, VBS, security notifications, Defender reporting, SmartScreen |
| Optimisations | Content delivery, storage sense, reserved storage, scheduled telemetry tasks |
| Performance Tweaks | Animations, search indexing, background apps, explorer animations |
| Taskbar Search Tweaks | Bing, cloud search, search history, online suggestions |
| Security and Performance | SAM enumeration, remote assistance, power plan, network bindings |
| Run Everything | Runs all of the above in one go with a restore point created first |

---

## Status

Early build — core tweaks are working, more coming.

| Area | Status |
|---|---|
| Privacy Tweaks | ✅ Working |
| Security Tweaks | ✅ Working |
| Optimisations | ✅ Working |
| Performance Tweaks | ✅ Working |
| Taskbar Search Tweaks | ✅ Working |
| Security and Performance | ✅ Working |
| Run Everything | ✅ Working |
| Debloat / App Removal | 🔧 Coming soon |
| App Installs | 🔧 Coming soon |
| GPU Drivers | 🔧 Coming soon |

---

## Disclaimer

BirdyOS makes real changes to your system. A restore point is recommended before running — the tool can create one for you from the main menu. The developers are not responsible for any issues caused by misuse of the tool.

---

## License

MIT — free to use, modify and share. See LICENSE for details.
