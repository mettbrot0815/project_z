# Z - Modern Recreation of the 1996 Bitmap Brothers RTS

A faithful modern recreation of the classic 1996 real-time strategy game "Z" by The Bitmap Brothers, rebuilt with Godot 4.x while preserving the exact core gameplay mechanics.

## Game Overview

Z is a pure territorial-conquest RTS where two robot armies (Red vs Blue) capture map sectors to accelerate factory-based unit production and destroy the enemy command fort. No resources. No base-building. Just pure unit command and autonomous AI warfare.

### Core Loop
1. Start with a fort and starter units at your base
2. Send robots to capture neutral flags/sectors
3. Captured sectors activate factories and reduce production timers
4. Command your army to destroy enemy units or infiltrate their fort
5. Win by destroying the enemy fort OR eliminating all enemy units

### Unique Mechanics
- **Territory Multiplier**: Each captured sector speeds up all unit production by 20%
- **Intelligence Tiers**: Units have intelligence ratings (1-10) that affect autonomous behavior
- **Driver Ejection**: Vehicle pilots can be killed, turning vehicles into neutral capturable assets
- **Autonomous AI**: Units act independently once ordered - no micromanagement required
- **6 Robot Types**: Grunt, Psycho, Tough, Sniper, Pyro, Laser with unique stats
- **7 Vehicle Types**: Jeeps, APCs, Tanks, Mortars, Transports, Command Vehicles
- **4 Stationary Guns**: Gatling, Howitzer, Missile, Turret

## Installation

### Requirements
- Godot Engine 4.3+
- Modern OS (Windows, Linux, macOS, Web)

### Setup
1. Clone or download the project folder
2. Open in Godot 4.3+
3. Import any missing assets (placeholders included)
4. Run the game from the main scene

### Export
```bash
# Windows
godot --export "Windows Desktop" project_z/

# Linux
godot --export "Linux/X11" project_z/

# Web
godot --export "Web" project_z/
```

## Controls

### Mouse
- **Left Click**: Select unit(s)
- **Left Drag**: Box select units
- **Right Click on Unit**: Attack that unit
- **Right Click on Map**: Attack position / Move

### Keyboard
- **F1-F6**: Cycle unit types (Grunt, Psycho, Tough, Sniper, Pyro, Laser)
- **P**: Pause game
- **Esc**: Open/close menu

### Unit Cycling
Press F1-F6 to select the first available unit of each type:
- F1: Grunt (basic infantry)
- F2: Psycho (machine gun)
- F3: Tough (high armor)
- F4: Sniper (long range)
- F5: Pyro (flamethrower)
- F6: Laser (energy weapon)

## Campaign

20 single-player levels across 5 planets:

### Desert (Levels 1-5)
- Desert Outpost (Tutorial)
- Oasis Campaign
- Sandstorm
- Dune Wars
- Final Sands

### Volcanic (Levels 6-8)
- Lava Flow
- Crater Field
- Eruption

### Arctic (Levels 9-12)
- Ice Fields
- Glacier Fortress
- Frost Bite
- Ice Age

### Jungle (Levels 13-15)
- Rainforest Rush
- Canopy War
- Amazon Ambush

### City (Levels 16-20)
- Urban Assault
- Skyscraper Siege
- Metro Mayhem
- Tower Takeover
- Neon Revolution (Final Boss Level)

## Technical Architecture

### Core Systems
- **GameManager**: Central game controller, win conditions, level management
- **SectorManager**: Flag capture, sector ownership, production multipliers
- **Unit**: Base class for all robots and vehicles
- **UnitAI**: Autonomous AI with intelligence-based behaviors
- **InputHandler**: Mouse selection, hotkeys, attack commands
- **HUD**: UI display, unit info, game status

### Data Models
```json
Unit: {
  "id": string,
  "type": string,
  "team": int,
  "x": float,
  "y": float,
  "health": int,
  "armor": int,
  "speed": float,
  "damage": int,
  "range": float,
  "intelligence": int,
  "weapon": string
}

Sector: {
  "id": string,
  "x": float,
  "y": float,
  "owner": int,
  "is_neutral": bool,
  "structures": [string]
}

Factory: {
  "flag_id": string,
  "type": string,  # "robot" or "vehicle"
  "build_timer": float,
  "build_queue": [string]
}
```

## Unit Statistics

| Unit | Speed | Armor | Health | Damage | Range | Intelligence | Weapon | Build Time |
|------|-------|-------|--------|--------|-------|--------------|--------|------------|
| Grunt | 1.8 | 10 | 100 | 10 | 12 | 3 | None | 5s |
| Psycho | 2.0 | 15 | 120 | 12 | 15 | 5 | Machine Gun | 8s |
| Tough | 1.5 | 60 | 180 | 15 | 12 | 4 | None | 12s |
| Sniper | 1.6 | 12 | 110 | 25 | 60 | 9 | Sniper | 15s |
| Pyro | 2.2 | 20 | 140 | 8 | 10 | 6 | Flamethrower | 10s |
| Laser | 1.9 | 18 | 130 | 18 | 40 | 7 | Laser | 12s |

## Intelligence Tiers

### Low Intelligence (1-3)
- Aggressive, exposes position, charges directly
- Poor situational awareness
- Units: Grunt, Pyro, Jeep, APC Light

### Medium Intelligence (4-6)
- Balanced tactics, moderate caution
- Basic positioning, seeks cover
- Units: Psycho, Tough, APC Light, Armored Car, Transport

### High Intelligence (7-8)
- Position-aware, uses cover
- Flanking attempts, tactical retreats
- Units: Laser, Tank Light/Medium, Mortar, Command Vehicle

### Elite Intelligence (9-10)
- Sniper tactics, extreme caution
- Ambush specialist, minimal exposure
- Units: Sniper

## Production System

Base build time is reduced by 20% per owned sector:
```
Build Time = Base Time / (1 + Owned Sectors * 0.2)
```

Example:
- 0 sectors: 100% build time
- 5 sectors: 70% build time
- 10 sectors: 50% build time

## AI Behaviors

Units make autonomous decisions based on:
1. **Intelligence Tier**: Dictates aggression, caution, tactics
2. **Target Priority**: Nearest enemy, fort capture, flag capture
3. **Cover Seeking**: Higher intelligence units avoid exposure
4. **Flanking**: Intelligence 7+ attempts flanking maneuvers
5. **Stealth**: Intelligence 9+ uses ambush tactics

## File Structure

```
project_z/
├── assets/                  # Sprites, tiles, sounds, music
├── scenes/                  # Main.tscn, Unit.tscn, etc.
├── scripts/
│   ├── autoloads/          # GameManager, SectorManager, AIController
│   ├── entities/           # Unit.gd, UnitAI.gd, Factory.gd
│   └── ui/                 # HUD.gd, InputHandler.gd
├── levels/                 # level_01.tscn ... level_20.tscn
├── data/                   # unit_stats.json, intelligence_tables.json, level_data.json
├── ui/                     # HUD.tscn, Minimap.tscn, UIPanel.tscn
├── entities/               # Robot.gd, Vehicle.gd, Gun.gd, Factory.gd
├── addons/                 # Godot plugins
├── export_presets.cfg
└── project.godot
```

## Multiplayer Support

Built-in Godot multiplayer (ENet) support:
- Local hot-seat (up to 4 players)
- Online play (when network layer implemented)
- Syncs: unit positions, attacks, captures, production

## Future Enhancements

- [ ] Full sprite art (placeholder graphics used)
- [ ] Original soundtrack
- [ ] Cutscenes with Brad/Allan
- [ ] Rocket-fuel victory party
- [ ] Replay system
- [ ] Level editor (from Zod Engine)
- [ ] Advanced pathfinding
- [ ] More vehicle types
- [ ] Campaign story mode

## Credits

**Original Game**: The Bitmap Brothers (1996)
**Remakes**: Zod Engine (open-source C++/SDL GPLv3)
**Qt_ZodEngine**: Qt + SDL reimplementation fork

This project is a fan recreation, not affiliated with The Bitmap Brothers.

## License

This project is open source. See LICENSE file for details.

## Contributing

Contributions welcome! See CONTRIBUTING.md for guidelines.

## Support

- Issues: Report bugs on GitHub
- Feature requests: Create GitHub issues
- Questions: Join the Discord community

## Known Issues

- Placeholder graphics need replacement
- AI pathfinding simplified (full A* to be implemented)
- Some vehicle mechanics not fully realized
- Sound effects need implementation

## Build Status

- [x] Core game loop implemented
- [x] Unit production system
- [x] Territory capture mechanics
- [x] Basic AI behaviors
- [x] Input system
- [x] HUD and UI
- [ ] Complete sprite art
- [ ] Full sound design
- [ ] Cutscenes
- [ ] Multiplayer network
- [ ] 20 campaign levels

## Changelog

### Version 0.1.0 (Initial Release)
- Core game mechanics implemented
- Unit system with 6 robot types
- Territory capture and production
- Basic AI with intelligence tiers
- Input system with hotkeys
- HUD and minimap
- Godot 4.x project structure

### Version 0.2.0 (Planned)
- Complete sprite art
- Soundtrack and effects
- All 20 campaign levels
- Multiplayer support
- Level editor integration
- Replay system

## Acknowledgments

- The Bitmap Brothers for creating the original Z
- Zod Engine developers for the open-source remake
- Godot Engine for the development platform
- RTS fans who inspired this project

---

**Built with ❤️ for the RTS community**
**Original game: Z (1996) by The Bitmap Brothers**
**Modern recreation: Godot 4.x**
