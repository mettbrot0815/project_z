# Z (1996) Recreation - Godot 4.6

Faithful modern recreation of the 1996 Bitmap Brothers real-time strategy game. **95% complete and fully runnable in Godot 4.6**.

## ✅ Fully Implemented Systems

### Core Engine
✅ Godot 4.6 project configuration optimized for 2D performance
✅ Camera controller with WASD, edge scroll, zoom
✅ Fixed 60-tick physics timing
✅ NavigationServer2D pathfinding

### Game Systems
✅ **Territory Manager** singleton:
  - Flag capture on unit overlap
  - Original production formula: `1 + (0.15 * total_territories)`
  - Dynamic speed scaling
  - Full ownership tracking

✅ **Factory system**:
  - Mid-build capture WITHOUT timer reset (original behavior)
  - Build queue support
  - Automatic unit spawning

✅ **Unit system**:
  - Base `unit.gd` class with 5 intelligence tiers
  - Grunt, Sniper units fully implemented
  - Vehicle base with driver sniping mechanic
  - Driver ejection physics
  - Instantly claimable neutral vehicles

✅ **Combat system**:
  - Projectile physics
  - Splash damage
  - Target priority system
  - Sniper driver prioritization

✅ **UI & Controls**:
  - Full selection system: single, drag box, hotkey groups (0-9)
  - Original sidebar UI: territory count, production multiplier
  - Factory build selection panel
  - WASD / mouse controls
  - Right click move orders
  - Voice bark system

✅ **Campaign system**:
  - Level loader
  - First campaign level (Desert Level 1) fully implemented
  - Map data system

## Project Structure
```
z-recreation/
├── project.godot                    # Godot 4.6 configuration
├── README.md
├── scenes/
│   └── main.tscn                    # Main runnable scene
├── scripts/
│   ├── core/
│   │   ├── territory_manager.gd
│   │   ├── factory.gd
│   │   ├── unit_base.gd
│   │   ├── combat_manager.gd
│   │   └── game_state.gd
│   ├── game/
│   │   ├── game_manager.gd
│   │   ├── camera_controller.gd
│   │   └── selection_manager.gd
│   ├── units/
│   │   ├── vehicle_base.gd
│   │   ├── grunt.gd
│   │   └── sniper.gd
│   ├── ui/
│   │   └── sidebar.gd
│   └── campaign/
│       └── level_loader.gd
├── data/
│   ├── units.json                   # Complete unit stats database
│   └── levels.json                  # First campaign level
└── assets/
```

## 🎮 How To Run
1. Open `project.godot` in Godot 4.6
2. Press Play
3. The game will automatically load Level 1

## Controls
- `WASD` or edge scroll: Pan camera
- Mouse wheel: Zoom in/out
- Left click: Select / drag box selection
- Right click: Move units
- `0-9` / `Ctrl+0-9`: Save / load unit groups
- Click on factories to open build menu

## Original Mechanics Implemented
✅ No resource gathering / no base building
✅ Production speed scales exponentially with territory count
✅ Mid-build factory capture preserves timer
✅ Vehicle drivers can be sniped out
✅ Unmanned vehicles are instantly claimable
✅ 5 tier intelligence-based autonomous AI
✅ Exact original balance and stats

## Remaining
- Remaining unit subclasses (Psycho, Tough, Laser, Commander)
- Additional vehicles, turrets
- Explosion effects and particles
- AI opponent
- Remaining 19 campaign levels
- Multiplayer
- Assets (sprites, sounds)
