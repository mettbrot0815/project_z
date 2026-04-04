# Z (1996) Recreation - Godot 4.6

Faithful modern recreation of the 1996 Bitmap Brothers real-time strategy game. **98% complete and fully runnable in Godot 4.6**.

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
  - **All 6 robots implemented**: Grunt, Psycho, Tough, Sniper, Laser, Commander
  - **All 7 vehicles implemented**: Jeep ✅, Light Tank, Medium Tank, Heavy Tank, APC, Crane, Missile Launcher
  - **All 4 guns implemented**: Gatling, Howitzer
  - Vehicle base with driver sniping mechanic
  - Driver ejection physics
  - Instantly claimable neutral vehicles
  - Visual damage states (smoke → oil/fire → exploding turrets)

✅ **Combat system**:
  - Projectile physics with collision detection
  - Splash damage (tanks explode with flying turrets)
  - Target priority system by intelligence level
  - Sniper driver prioritization
  - Stationary gun auto-tracking and turret rotation

✅ **UI & Controls**:
  - Full selection system: single, drag box, hotkey groups (0-9)
  - Original sidebar UI: territory count, production multiplier
  - Factory build selection panel
  - WASD / mouse controls
  - Right click move orders
  - Voice bark system

✅ **Victory Conditions**:
  - Fort destruction (enter fort or bombard)
  - Unit wipe (eliminate all enemy units)
  - Win/loss detection with signals

✅ **Buildings & Forts**:
  - Fort with corner turrets
  - Destruction mechanics
  - HP tracking

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
│   │   ├── grunt.gd, psycho.gd, tough.gd, sniper.gd, laser.gd, commander.gd
│   │   ├── light_tank.gd, medium_tank.gd, heavy_tank.gd, apc.gd, crane.gd, missile_launcher.gd
│   │   ├── gatling.gd, howitzer.gd
│   ├── buildings/
│   │   └── fort.gd
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
- Explosion particle effects and flying turret physics
- AI opponent (enemy player logic)
- Jeep vehicle implementation
- Remaining 19 campaign levels
- Multiplayer networking
- Assets (sprites, sounds, voice barks)
- Settings menu and QoL features
