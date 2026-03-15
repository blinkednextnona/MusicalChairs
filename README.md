# 🪑 Musical Chairs Script

**Made by CozzyBruh**

A Roblox Musical Chairs automation script with a clean, dark-themed UI. Automatically tweens your character above a chair and drops you onto it when the round releases everyone.

![Roblox](https://img.shields.io/badge/Platform-Roblox-red?style=flat-square)
![Lua](https://img.shields.io/badge/Language-Lua-blue?style=flat-square)
![Version](https://img.shields.io/badge/Version-1.0-green?style=flat-square)

---

## Features

- **Auto Chair** — Tweens above the closest chair and drops you onto it. Detects when you're locked (circling phase) and waits until released.
- **Two-Step Movement** — Phase 1 glides you above the chair, Phase 2 drops you with gravity. Looks natural, avoids detection.
- **Adjustable Tween Speed** — Slider from 10–200 studs/sec with preset buttons (Sneaky, Normal, Fast, Risky).
- **Anti-AFK** — Prevents idle kicks using VirtualUser. Enabled by default.
- **Clean UI** — Dark-themed, draggable window with tabs, toggles, sliders, buttons, and notifications.
- **Keybind** — Press `RightShift` to toggle the UI open/closed.

## How It Works

1. Toggle **"Goto Chairs Automatically"** on the Main tab
2. The script waits during the circling phase (detects locked movement)
3. When released, it tweens your character **above** the closest chair
4. Then drops you straight down with gravity onto the seat
5. Repeats every round automatically

## Installation

### Quick Load (Recommended)
Paste this into your executor:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/MusicalChairs/main/src/Main.lua"))()
```
> Replace `YOUR_USERNAME` with your GitHub username.

### Manual Load
1. Copy the contents of `src/Main.lua`
2. Paste into your executor
3. Execute

## File Structure

```
MusicalChairs/
├── README.md              # This file
├── LICENSE                 # MIT License
├── src/
│   ├── Main.lua           # Full script (all-in-one)
│   ├── UI/
│   │   ├── Library.lua    # UI library (window, tabs, components)
│   │   └── Config.lua     # Colors, fonts, layout settings
│   ├── Modules/
│   │   ├── ChairFinder.lua    # Chair detection & seat finding
│   │   ├── ChairTween.lua     # Tween above + drop logic
│   │   ├── AntiAFK.lua        # Anti-AFK system
│   │   └── PlayerUtils.lua    # Player state checks (sitting, locked)
│   └── Tabs/
│       ├── MainTab.lua        # Main tab setup
│       ├── SpeedTab.lua       # Tween speed controls
│       ├── MiscTab.lua        # Anti-AFK & utilities
│       └── SettingsTab.lua    # UI settings
```

## Tabs

| Tab | Description |
|-----|-------------|
| 🪑 **Main** | Auto chair toggle + manual TP button |
| 💨 **Speed** | Tween speed slider + presets |
| 🔧 **Misc** | Anti-AFK, rejoin server, copy server link |
| ⚙️ **Settings** | Reset position, destroy UI, keybind info |

## Speed Presets

| Preset | Speed | Description |
|--------|-------|-------------|
| Sneaky | 25 studs/sec | Very slow, looks completely natural |
| Normal | 50 studs/sec | Default, good balance |
| Fast | 100 studs/sec | Quick, slightly suspicious |
| Risky | 200 studs/sec | Very fast, use at your own risk |

## Notes

- The script searches for a `Chairs` model in workspace that contains `Chair` child models
- It handles duplicate "Chairs" objects by checking which one actually has Chair models inside
- During the circling phase (WalkSpeed = 0, anchored, or PlatformStand), the script pauses
- Anti-AFK hooks into `Player.Idled` and uses VirtualUser to prevent kicks
- The UI persists through respawns (`ResetOnSpawn = false`)

## Disclaimer

This script is for **educational purposes only**. Use at your own risk. I am not responsible for any bans or consequences from using this script.

---

**Made with ❤️ by CozzyBruh**
