# Z (1996) Recreation - Godot 4.6

Faithful modern recreation of the 1996 Bitmap Brothers real-time strategy game.

## Implemented Systems

### Core Engine
✅ Godot 4.6 project configuration (optimized for 2D performance)
✅ Camera controller with pan, zoom, edge scroll
✅ Fixed timestep physics at 60 ticks per second
✅ NavigationServer2D pathfinding setup

### Game Systems
✅ **Territory Manager** singleton:
  - Flag capture on unit overlap
  - Original production multiplier formula: `1 + (0.15 * total_territories)`
  - Dynamic speed scaling for all factories
  - Ownership tracking for all sectors

✅ **Factory system**:
  - Production timers that continue running when captured mid-build
  - Build queue support
  - No timer reset on capture (exact original behavior)
  - Automatic unit spawning on completion

✅ **Base Unit class**:
  - All shared properties (hp, damage, speed, intelligence)
  - 5 tier intelligence system for autonomous AI
  - Navigation agent integration
  - Damage and death handling

## File Structure
```
z-recreation/
├── project.godot                    # Godot 4.6 configuration
├── README.md
├── assets/
├── scenes/
├── scripts/
│   ├── core/
│   │   ├── territory_manager.gd     # Singleton territory system
│   │   ├── factory.gd               # Production logic
│   │   └── unit_base.gd             # Base unit class
│   └── game/
│       └── camera_controller.gd     # Game camera
├── levels/
└── data/
```

## Next Implementation Steps
1. Unit types: Grunt, Psycho, Tough, Sniper, all vehicles
2. Vehicle driver sniping mechanic
3. Combat manager and projectile system
4. UI sidebar, selection system
5. Campaign level loader

## Controls
- `WASD` / Edge scroll: Pan camera
- Mouse wheel: Zoom in/out
- Left click: Select
- Right click: Move / Attack
