# Z - A Godot 4.6 Recreation of the 1996 Bitmap Brothers Classic

[![Godot 4.6](https://img.shields.io/badge/Godot-4.6-blue.svg)](https://godotengine.org/)
[![License](https://img.shields.io/badge/License-CC--BY--NC--ND-red.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)
[![Status](https://img.shields.io/badge/status-active-green.svg)](https://github.com/mettbrot0815/project_z)

A faithful recreation of the classic 1996 strategy game **Z** (also known as "Commander Keen in Harm's Way" or "Z: The Underground War") built with Godot Engine 4.6.

---

## 🚀 Quick Start

### Installation

1. **Clone or download** this repository
2. **Open in Godot 4.6**:
   - Double-click `project.godot`
   - Or run: `godot project.godot`
3. **Press Play** - Level 1 loads automatically
   - No configuration needed

```bash
# Verify Godot version
godot --version

# Run the project
godot project.godot
```

---

## 🎮 Game Features

| Feature | Description |
|---------|-------------|
| **Tactical Combat** | Select and command your units in real-time tactical battles |
| **Territory Capture** | Build factories and expand your empire across the map |
| **Production System** | Research technologies and build diverse unit types |
| **AI Opponent** | Adaptive difficulty levels (Easy, Normal, Hard) |
| **Campaign Mode** | 20+ levels with unique challenges and objectives |
| **Classic Gameplay** | Pure tactical mayhem with no resource gathering |

---

## ⌨️ Controls

| Action | Key / Input |
|--------|-------------|
| Select Units | Click on unit |
| Move Units | Right-click on destination |
| Factory Menu | Click factory building |
| Camera View | Mouse scroll / drag |
| Pause Game | `P` key |
| Cancel Action | `ESC` key |

---

## 📁 Project Structure

```
project_z/
├── project.godot                 # Project configuration
├── README.md                     # This file
├── .gitignore                    # Git ignore rules
├── assets/                       # Game assets
│   ├── audio/                    # Sound files
│   ├── buildings/                # Building sprites
│   ├── cursors/                  # Cursor sprites
│   ├── fonts/                    # Font files
│   ├── other/                    # Miscellaneous assets
│   ├── planets/                  # Planet sprites
│   ├── planets_1-10-10/          # Planet variations
│   ├── sounds/                   # Audio effects
│   ├── sprites/                  # Sprite sheets
│   ├── teams/                    # Team color assets
│   └── units/                    # Unit sprites
├── data/                         # Game data
│   ├── levels.json               # Level definitions
│   └── units.json                # Unit definitions
├── scenes/                       # All scene files
│   ├── Main.tscn                 # Main game scene
│   ├── buildings/                # Building scenes
│   ├── effects/                  # Effect scenes
│   └── units/                    # Unit scenes
└── scripts/                      # All GDScript code
    ├── buildings/                # Building logic
    ├── campaign/                 # Level loading
    ├── core/                     # Core systems
    ├── effects/                  # Visual effects
    ├── game/                     # Game management
    ├── ui/                       # UI handling
    └── units/                    # Unit scripts
```

---

## 📋 Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **Godot Engine** | 4.6.0 | 4.6.x |
| **OS** | Windows 10, Linux, macOS | Any modern OS |
| **RAM** | 512 MB | 1 GB |
| **Disk** | 100 MB | 200 MB |

---

## 📦 Exporting

### Windows
```bash
# From Godot Editor
Project → Export → Windows → Export

# Or from command line
godot --export-release "Windows Desktop" project.godot
```

### Linux
```bash
# From Godot Editor
Project → Export → Linux → Export

# Or from command line
godot --export-release "Linux/X11" project.godot
```

### macOS
```bash
# From Godot Editor
Project → Export → macOS → Export

# Or from command line
godot --export-release "macOS" project.godot
```

---

## 🐛 Known Limitations

- **Voice barks** are placeholders (audio system functional but not implemented)
- **Planet theme colors** are disabled for Godot 4 compatibility (can be added later)
- **AI intelligence** varies by difficulty level

---

## 📜 License

This is a fan recreation of the 1996 game **Z** by Bitmap Brothers. All original assets and game design belong to their respective owners. This project is released under the **Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License**.

---

## 🙏 Credits

| Role | Attribution |
|------|-------------|
| **Original Game Design** | Bitmap Brothers (1996) |
| **Godot Implementation** | mettbrot0815 |
| **Engine** | Godot Engine 4.6 |

---

## 📞 Support

- **Issues**: [Open an issue on GitHub](https://github.com/mettbrot0815/project_z/issues)
- **Contributions**: Welcome! Please submit pull requests
- **Fork & Star**: Feel free to fork and star this project

---

*Last updated: April 2026*
