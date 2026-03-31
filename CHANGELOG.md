# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-03-31

### Initial Release

#### Added
- Core game loop with territory capture mechanics
- Production multiplier system based on owned sectors
- 6 robot unit types with unique stats
- 7 vehicle types with driver ejection mechanics
- 4 stationary gun types
- Intelligence tier system (1-10) affecting AI behavior
- Basic autonomous AI controller
- Mouse input system (left click select, right click attack)
- Unit cycling hotkeys (F1-F6)
- HUD with unit info panel
- Minimap placeholder
- Sector/flag capture system
- Factory auto-production
- 20 campaign level data structures
- Godot 4.x project structure
- Basic level loading system

#### Technical
- GameManager autoload for central game control
- SectorManager for territory and production
- Unit base class with inheritance
- UnitAI with intelligence-based behaviors
- InputHandler for all player input
- Factory class for unit production
- Sector class for flag/sector management
- AIController for enemy AI orchestration
- Data models in JSON format
- Scene template structure

#### Data
- unit_stats.json with all 19 unit types
- intelligence_tables.json with tier behaviors
- level_data.json with 20 levels across 5 planets
- config/game_config.gd for settings

#### Documentation
- Comprehensive README.md
- CONTRIBUTING.md for developers
- LICENSE file
- This CHANGELOG.md

### Known Issues
- Placeholder graphics need replacement
- AI pathfinding simplified
- Some vehicle mechanics not fully realized
- Sound effects need implementation
- Cutscenes not implemented

### Future Plans
- Complete sprite art
- Original soundtrack
- All 20 campaign levels playable
- Multiplayer support
- Level editor integration
- Replay system
- Advanced pathfinding
- More vehicle types

---

## [Unreleased]

### Planned Features
- Complete all 20 levels with proper maps
- Full sprite art implementation
- Soundtrack and sound effects
- Cutscenes with Brad/Allan
- Rocket-fuel victory party
- Multiplayer (ENet)
- Level editor (from Zod Engine)
- Replay recording
- Achievement system
- Options menu (resolution, volume, controls)
- Save/load game
- Difficulty settings
- Tutorial mode
- Practice mode
- Speedrun timer

### Architecture Improvements
- Better scene organization
- Object pooling for performance
- Optimized pathfinding
- Network code for multiplayer
- Unit state machine
- Better AI decision making
- Cover system
- Line of sight
- Terrain features
- Weather effects

### Bug Fixes
- None yet (v0.1.0)

---

## Version History

### v0.1.0 (March 2026)
- Initial release with core mechanics

### Future Versions

v0.2.0 - Complete Campaign
- All 20 levels playable
- Complete sprite art
- Soundtrack
- Basic multiplayer

v0.3.0 - Full Features
- Multiplayer network
- Level editor
- Replay system
- All planned features

v1.0.0 - Complete
- 100% faithful to original
- All planned features
- Performance optimized
- Cross-platform polished

---

## Contributors

### Initial Release
- Project architect and implementation
- Core systems design
- Data structure creation

### Community
- Welcome contributions!
- See CONTRIBUTING.md for guidelines

---

## Acknowledgments

- The Bitmap Brothers for creating the original Z
- Zod Engine developers for open-source inspiration
- Godot Engine for the development platform
- All RTS fans who keep the genre alive

---

## Notes

This project is a fan recreation and is not affiliated with The Bitmap Brothers.

All original IP, assets, and code remain the property of The Bitmap Brothers.
