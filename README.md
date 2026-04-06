# Z - A Godot 4.6 Recreation of the 1996 Bitmap Brothers Game

A faithful recreation of the classic 1996 strategy game "Z" (also known as "Commander Keen in Harm's Way" or "Z: The Underground War") built with Godot Engine 4.6.

## Quick Start

```bash
# 1. Open in Godot 4.6
#    - Double-click project.godot, or
#    - Run: godot project.godot

# 2. Press Play!
#    - Level 1 loads automatically
#    - No configuration needed
```

## Game Features

- **Tactical Combat**: Select and command your units in real-time
- **Territory Capture**: Build factories and expand your empire
- **Production System**: Research technologies and build units
- **AI Opponent**: Adaptive difficulty levels (Easy, Normal, Hard)
- **Campaign Mode**: 20+ levels with unique challenges
- **Classic Gameplay**: Pure tactical mayhem with no resource gathering

## Controls

| Action | Key |
|--------|-----|
| Select Units | Click on unit |
| Move Units | Right-click on destination |
| Factory Menu | Click factory building |
| Camera | Mouse scroll / drag |
| Pause | P key |

## Game Structure

```
project_z/
├── project.godot          # Project configuration
├── scenes/                # All scene files
│   ├── Main.tscn          # Main game scene
│   ├── buildings/         # Building scenes
│   ├── units/             # Unit scenes
│   └── effects/            # Effect scenes
├── scripts/               # All GDScript code
│   ├── game/              # Core game logic
│   ├── campaign/          # Level loading
│   ├── core/              # Systems
│   ├── ui/                # UI handling
│   └── units/             # Unit scripts
├── data/                  # Game data
│   ├── levels.json        # Level definitions
│   └── units.json         # Unit definitions
└── assets/                # Game assets
    ├── audio/             # Sound files
    └── sprites/            # Sprite sheets
```

## Requirements

- **Godot Engine**: 4.6 or later
- **Operating System**: Windows, Linux, or macOS
- **Memory**: 512 MB minimum (1 GB recommended)

## Exporting

### Windows
```bash
# From Godot Editor:
Project -> Export -> Windows -> Export

# Or from command line:
godot --export-release "Windows Desktop" project.godot
```

### Linux
```bash
# From Godot Editor:
Project -> Export -> Linux -> Export

# Or from command line:
godot --export-release "Linux/X11" project.godot
```

### macOS
```bash
# From Godot Editor:
Project -> Export -> macOS -> Export

# Or from command line:
godot --export-release "macOS" project.godot
```

## Known Issues

- Voice barks are placeholders (audio system functional but not implemented)
- Planet theme colors are disabled for Godot 4 compatibility (can be added later)

## License

This is a fan recreation of the 1996 game "Z" by Bitmap Brothers. All original assets and game design belong to their respective owners.

## Credits

**Game Design**: Bitmap Brothers (1996)  
**Godot Implementation**: Fan recreation  
**Engine**: Godot Engine 4.6

---

*Last updated: April 2026*