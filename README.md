# BirdyOS

A simple, lightweight Windows 11 optimisation tool. One script, clean GUI, no unnecessary extras.

---

## What is it?

BirdyOS is a single PowerShell script that cleans up and optimises Windows 11. It removes unwanted apps, disables telemetry, applies performance tweaks and helps set up GPU drivers — all from one place with a proper dark GUI.

No custom ISO. No third party installers. No extra files. Just one script you can read yourself.

---

## Why?

Windows 11 out of the box ships with a lot of features and apps that most people never use. BirdyOS gives you a simple way to take control of your system.

- **Performance** — disables unnecessary background processes, tunes power settings, sets up timer resolution and GPU profiles
- **Privacy** — disables telemetry, Bing search, Copilot, location services and data collection
- **Debloat** — removes Edge, OneDrive, Xbox apps, Teams and other pre-installed applications
- **Simple** — one `.ps1` file with a built-in GUI, works on any clean Windows 11 install

---

## Open Source and Transparent

BirdyOS is fully open source under the MIT license. Every single change the script makes is visible in plain text — there are no compiled binaries, no hidden executables and no obfuscated code. You can read exactly what it does before running anything.

This also means BirdyOS is straightforward to audit, fork and contribute to.

---

## Legal Compliance

BirdyOS does not redistribute or modify any Windows installation files. It works entirely by applying settings and removing components on an already installed, legitimately licensed copy of Windows 11. BirdyOS does not touch, bypass or alter Windows activation in any way.

This keeps BirdyOS fully compliant with the Microsoft Windows Usage Terms.

---

## Requirements

- Windows 11 23H2 or newer
- Administrator rights
- Internet connection (for downloading drivers and apps)

---

## How to use

```
1. Download BirdyOS.ps1
2. Right click → Run with PowerShell as Administrator
3. Pick what you want from the menu
4. Done
```

---

## Status

Early build. Most features are placeholders right now while the core gets built out.

| Feature | Status |
|---|---|
| GUI | ✅ Working |
| Debloat | 🔧 In progress |
| Privacy tweaks | 🔧 In progress |
| Performance tweaks | 🔧 In progress |
| App removal | 🔧 In progress |
| App installs | 🔧 In progress |
| GPU drivers | 🔧 In progress |
| Power plan | 🔧 In progress |

---

## Disclaimer

BirdyOS makes real changes to your system. Each option shows what it does before applying anything. Please read carefully and back up anything important before running. The developers are not responsible for any issues caused by misuse of the tool.

---

## License

MIT — free to use, modify and share. See LICENSE for details.
