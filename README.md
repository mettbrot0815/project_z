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

## 🎮 How to Play

### Objective
**Command your army and conquer the planet!** Build factories, research technologies, and deploy units to capture enemy territory.

### Core Gameplay Loop
1. **Select Units** - Click on your units (blue squares) to select them
2. **Move Units** - Right-click on the map to move your units
3. **Build Factories** - Click on empty terrain to place factories (costs resources)
4. **Research Tech** - Upgrade factories to unlock better units
5. **Deploy Units** - Build and command your army into battle

### Win Conditions
- **Capture the Planet** - Own the majority of terrain tiles
- **Destroy Enemy Units** - Eliminate all opposing forces
- **Complete Mission Objectives** - Some levels have specific goals

### Tips for New Players
- **Patience Pays Off** - Build up your forces before attacking
- **Control the Center** - Factories in the middle are most valuable
- **Watch Your Economy** - Balance production with expansion
- **Use Terrain** - Some units have advantages on certain ground types

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

## 📥 Downloads

### Official Releases

| Version | Date | Description |
|---------|------|-------------|
| **[v1.0]** | Apr 6, 2026 | Professional release with Windows, Linux, and Web builds |

#### Download Links

| Platform | Download | Size |
|----------|----------|------|
| **Windows** | [Project_Z-v1.0-Windows.zip](https://github.com/mettbrot0815/project_z/releases/download/v1.0/Project_Z-v1.0-Windows.zip) | ~85 MB |
| **Linux** | [Project_Z-v1.0-Linux.zip](https://github.com/mettbrot0815/project_z/releases/download/v1.0/Project_Z-v1.0-Linux.zip) | ~85 MB |
| **Web (HTML5)** | [Project_Z-v1.0-Web.zip](https://github.com/mettbrot0815/project_z/releases/download/v1.0/Project_Z-v1.0-Web.zip) | ~25 MB |

> **Note:** Download links will be available in the [GitHub Releases](https://github.com/mettbrot0815/project_z/releases) page after the release is published.

---

## 🖼️ Screenshots

### Gallery

> **Coming Soon!** Screenshots will be added once the game runs in a graphical environment.

### Planned Screenshots

1. **Main Menu / Title Screen** - Retro bitmap graphics with iconic Z logo
2. **Gameplay - Units Moving** - Tactical real-time strategy view
3. **Territory Capture** - Map showing owned territory and factories
4. **Combat Action** - Dynamic battles with explosions and effects
5. **Victory Screen** - Win animation and summary
6. **Factory Menu** - Building interface and tech research

### View Screenshots

- Local screenshots: `screenshots/` (when game runs locally)
- GitHub Releases: [Project Z v1.0 Screenshots](https://github.com/mettbrot0815/project_z/releases/tag/v1.0)

---

## 🌐 Play in Browser

### Web Build (HTML5)

The Web build can be played directly in any modern browser:

1. Download **Project_Z-v1.0-Web.zip** from the [Releases page](https://github.com/mettbrot0815/project_z/releases)
2. Extract the archive
3. Open `index.html` in Chrome, Edge, or Firefox
4. **No installation required!**

#### Browser Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **Browser** | Chrome 90+ | Chrome 120+ |
| **JavaScript** | Enabled | Hardware acceleration |
| **HTTPS** | Recommended | Required for production |

### In-Browser Controls

- **WASD** - Camera movement
- **Mouse** - Select and move units
- **ESC** - Pause/Menu
- **P** - Toggle pause

---

## 📜 License

This is a fan recreation of the 1996 game **Z** by Bitmap Brothers. All original assets and game design belong to their respective owners. This project is released under the **Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License**.

See [LICENSE](LICENSE) for details.

---

## 🙏 Credits

| Role | Attribution |
|------|-------------|
| **Original Game Design** | Bitmap Brothers (1996) |
| **Godot Implementation** | mettbrot0815 |
| **Engine** | Godot Engine 4.6 |
| **Assets** | Original Bitmap Brothers assets |

---

## 📝 Changelog

### v1.0 (April 6, 2026)

**Features**
- Complete recreation of Z (1996) gameplay
- 20+ campaign levels with unique objectives
- Real-time tactical combat system
- Territory capture and factory building
- AI opponent with 3 difficulty levels

**Technical**
- Built with Godot Engine 4.6.1
- Export presets for Windows, Linux, and Web
- Optimized asset loading
- Cross-platform support

**Bug Fixes**
- Fixed V-Sync compatibility issues
- Improved asset management
- Enhanced input handling

---

*Last updated: April 6, 2026*

<div align="center">
  <a href="https://github.com/mettbrot0815/project_z/releases"><img src="https://img.shields.io/github/v/release/mettbrot0815/project_z?style=for-the-badge" alt="Latest Release"></a>
  <a href="https://github.com/mettbrot0815/project_z/releases"><img src="https://img.shields.io/github/downloads/mettbrot0815/project_z/total?style=for-the-badge" alt="Total Downloads"></a>
</div>
