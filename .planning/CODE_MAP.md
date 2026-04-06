# Z (1996) Recreation - Godot Project Code Map

## Project Overview
**Name:** Z (1996) Recreation  
**Tech Stack:** Godot 4.6 (GDScript)  
**Description:** Faithful recreation of the Bitmap Brothers RTS game Z (1996)  
**Version:** 0.1.0  
**Main Scene:** `res://scenes/main.tscn`

---

## 1. PROJECT STRUCTURE

```
project_z/
├── project.godot          # Engine config, autoloads, input mappings
├── AGENTS.md              # Agent instructions
├── README.md
├── scenes/
│   ├── Main.tscn          # Main entry point scene
│   ├── units/             # 16 unit scenes
│   ├── buildings/         # 4 building scenes
│   └── effects/           # 1 effect scene
├── scripts/
│   ├── core/              # 6 core system scripts
│   ├── units/             # 14 unit scripts
│   ├── buildings/         # 2 building scripts
│   ├── game/              # 3 game management scripts
│   ├── effects/           # 1 effect script
│   ├── ui/                # 1 UI script
│   └── campaign/          # 1 level loader script
├── data/
│   ├── levels.json        # 20 campaign levels
│   └── units.json         # Unit stats data
└── assets/
    └── sprites/
        ├── robots/        # Robot sprites (ground units)
        ├── vehicles/      # Vehicle sprites (7 types)
        ├── buildings/     # Building sprites
        └── cannons/       # Cannon/turret sprites
```

---

## 2. AUTOLOADED SINGLETONS (from project.godot)

| Singleton | Script | Purpose |
|-----------|--------|---------|
| `TerritoryManager` | `scripts/core/territory_manager.gd` | Flag capture, territory ownership, production multiplier |
| `CombatManager` | `scripts/core/combat_manager.gd` | Projectile physics, collision, splash damage |
| `GameState` | `scripts/core/game_state.gd` | Win/loss conditions, game time tracking |
| `SelectionManager` | `scripts/game/selection_manager.gd` | Unit selection, drag box, hotkey groups |

---

## 3. SCRIPTS DIRECTORY

### 3.1 CORE (`/scripts/core/`)

| File | Purpose | Key Classes/Functions |
|------|---------|----------------------|
| `unit_base.gd` | **Base class for all units** (robots, vehicles, guns) | `UnitBase` class with Team enum (NEUTRAL/RED/BLUE), HP/damage/speed stats, `move_to()`, `attack()`, `take_damage()`, `die()`, `find_nearest_enemy()`, `find_enemy_groups()`, intelligence-based AI (0-5 scale) |
| `game_state.gd` | **Global game state singleton** | `game_won`, `game_lost` signals, `check_victory_conditions()`, `pause_game()`, `resume_game()` |
| `territory_manager.gd` | **Territory & flag capture system** | Owner enum (NEUTRAL/RED/BLUE), `register_territory()`, `capture_territory()`, `update_production_multiplier()`, `get_territory_count()` |
| `combat_manager.gd` | **Projectile & combat system** | `fire_projectile()`, `_physics_process()` for projectile updates, `apply_splash_damage()`, collision detection with physics |
| `factory.gd` | **Unit production from factories** | `start_production()`, `complete_production()`, `get_build_percentage()`, production queue, multiplier-based speed scaling |
| `sprite_manager.gd` | **Sprite path resolution utility** | `team_to_color()`, `load_sprite_texture()`, `create_robot_sprite()`, `create_vehicle_sprite()` - loads walk/fire animations |

### 3.2 UNITS (`/scripts/units/`)

| File | Purpose | Key Classes/Functions |
|------|---------|----------------------|
| `unit_base.gd` | **Base for ALL units** | See core above |
| `vehicle_base.gd` | **Base class for vehicles** | `VehicleBase` extends UnitBase, driver sniping mechanic, `kill_driver()`, `capture()`, `update_damage_visuals()` - driver hitbox system |
| `grunt.gd` | **Fastest, weakest robot (int 0)** | HP:50, DMG:8, SPD:140, rushes flags |
| `psycho.gd` | **Rapid-fire machine gun robot (int 1)** | HP:65, DMG:6, SPD:120, FR:0.15s, auto-fires nearby enemies |
| `tough.gd` | **High HP tank robot (int 2)** | HP:100, DMG:12, SPD:90, targets vehicles |
| `sniper.gd` | **Long range, high damage (int 3)** | HP:45, DMG:75, RNG:400, prioritizes vehicle drivers |
| `commander.gd` | **Strategic AI leader (int 5)** | HP:150, DMG:25, strategic behavior - retreats when outnumbered |
| `driver.gd` | **Ejected when vehicle driver killed** | `Driver` class, 20HP, runs away when ejected |
| `jeep.gd` | **Fast scout vehicle (int 2)** | HP:80, DMG:10, SPD:220, small explosion on death |
| `light_tank.gd` | **Balanced tank (int 2)** | HP:200, DMG:25, SPD:130, 96px splash, flying turret effect |
| `medium_tank.gd` | **Heavy armor tank (int 3)** | HP:350, DMG:40, SPD:100, 128px splash, prioritizes vehicles |
| `heavy_tank.gd` | **Maximum armor tank (int 3)** | HP:500, DMG:65, SPD:75, 160px splash, targets buildings |
| `apc.gd` | **Troop transport vehicle (int 2)** | HP:150, SPD:140, carries 4 passengers, `load_unit()`, `unload_units()` |
| `howitzer.gd` | **Stationary artillery (int 0)** | HP:120, DMG:80, RNG:500, 64px splash, turret rotation |
| `missile_launcher.gd` | **Mobile missile launcher (int 3)** | HP:100, DMG:100, RNG:600, 200px splash, group detection |
| `gatling.gd` | **Stationary rapid fire (int 0)** | HP:100, DMG:5, FR:0.08s, 250px range, auto-tracking turret |
| `laser.gd` | **High intelligence laser (int 4)** | HP:75, DMG:20, SPD:100, avoids threats, targets vehicles |
| `crane.gd` | **Repair vehicle (int 3)** | HP:120, SPD:110, repairs allies at 20HP/s, `find_damaged_ally()` |

### 3.3 BUILDINGS (`/scripts/buildings/`)

| File | Purpose | Key Classes/Functions |
|------|---------|----------------------|
| `flag.gd` | **Territory capture flag** | `territory_id`, team ownership, `_on_body_entered()` captures on unit touch, animated sprite by team color |
| `fort.gd` | **Main base structure** | HP:1000, 4 corner gatling turrets, `destroyed` signal triggers win condition, splash damage on destruction |

### 3.4 GAME (`/scripts/game/`)

| File | Purpose | Key Classes/Functions |
|------|---------|----------------------|
| `game_manager.gd` | **Main game orchestrator** | `units_container`, `buildings_container`, navigation setup, level loading, right-click orders, voice bark system |
| `camera_controller.gd` | **2D camera with pan/zoom** | Keyboard (WASD) + edge scroll, mouse wheel zoom (0.5-2.0x), smooth interpolation |
| `selection_manager.gd` | **Unit selection system** | Drag box selection, single click, 10 hotkey groups (Ctrl+0-9), `issue_move_order()` |

### 3.5 UI (`/scripts/ui/`)

| File | Purpose | Key Classes/Functions |
|------|---------|----------------------|
| `sidebar.gd` | **Original Z-style sidebar** | Factory unit build buttons, territory count, production multiplier display |

### 3.6 EFFECTS (`/scripts/effects/`)

| File | Purpose | Key Classes/Functions |
|------|---------|----------------------|
| `flying_turret.gd` | **Tank explosion effect** | `FlyingTurret` class, gravity-affected projectile, 64px splash on impact |

### 3.7 CAMPAIGN (`/scripts/campaign/`)

| File | Purpose | Key Classes/Functions |
|------|---------|----------------------|
| `level_loader.gd` | **Campaign level system** | 20 levels from JSON, `load_level()`, `advance_level()`, `show_cutscene()`, planet theme system, AI production cheat (>level 10) |

---

## 4. SCENES DIRECTORY

### 4.1 MAIN SCENE (`scenes/Main.tscn`)
- Root node with `GameManager` script
- Camera2D with `CameraController`
- TileMapLayer (empty placeholder)
- NavigationRegion2D (2048x2048 map)
- `SelectionManager` node
- `LevelLoader` node
- UI CanvasLayer with Sidebar

### 4.2 UNIT SCENES (`scenes/units/`)

| Scene | Extends | Description |
|-------|---------|-------------|
| `grunt.tscn` | `grunt.gd` | Basic infantry |
| `psycho.tscn` | `psycho.gd` | Machine gun robot |
| `tough.tscn` | `tough.gd` | Heavy combat robot |
| `sniper.tscn` | `sniper.gd` | Long-range robot |
| `laser.tscn` | `laser.gd` | Laser robot |
| `commander.tscn` | `commander.gd` | Elite robot |
| `driver.tscn` | `driver.gd` | Ejected driver |
| `jeep.tscn` | `jeep.gd` | Scout vehicle |
| `light_tank.tscn` | `light_tank.gd` | Light armor |
| `medium_tank.tscn` | `medium_tank.gd` | Medium armor |
| `heavy_tank.tscn` | `heavy_tank.gd` | Heavy armor |
| `apc.tscn` | `apc.gd` | Transport vehicle |
| `missile_launcher.tscn` | `missile_launcher.gd` | Heavy artillery |
| `crane.tscn` | `crane.gd` | Repair vehicle |
| `gatling.tscn` | `gatling.gd` | Turret gun |
| `howitzer.tscn` | `howitzer.gd` | Artillery gun |

### 4.3 BUILDING SCENES (`scenes/buildings/`)

| Scene | Extends | Description |
|-------|---------|-------------|
| `flag.tscn` | `flag.gd` | Territory flag |
| `fort.tscn` | `fort.gd` | Main base with turrets |
| `factory_robot.tscn` | `factory.gd` | Robot production |
| `factory_vehicle.tscn` | `factory.gd` | Vehicle production |

### 4.4 EFFECT SCENES (`scenes/effects/`)

| Scene | Extends | Description |
|-------|---------|-------------|
| `flying_turret.tscn` | `flying_turret.gd` | Explosion effect |

---

## 5. DATA FILES

### 5.1 `data/levels.json`
- **20 campaign levels** with progressive difficulty
- Each level defines:
  - `id`, `name`, `planet` theme
  - `territories[]` - flag positions and owners
  - `factories[]` - robot/vehicle factory placements
  - `units[]` - starting unit positions and owners
- **Planets:** desert, volcanic, arctic, jungle, city

### 5.2 `data/units.json`
- **Stats definitions** for all unit types
- Categories: `robots`, `vehicles`, `guns`
- Fields: `max_hp`, `damage`, `move_speed`, `intelligence`, `fire_rate`, `build_time`

---

## 6. ASSETS ORGANIZATION

### 6.1 Sprites (`assets/sprites/`)

| Directory | Contents |
|-----------|----------|
| `robots/` | Ground unit sprites with walk animations (blue/green/red/yellow) |
| `robots/grunt/` | Grunt-specific fire animation |
| `robots/psycho/` | Psycho-specific fire animation |
| `robots/sniper/` | Sniper-specific fire animation |
| `robots/tough/` | Tough-specific fire animation |
| `robots/laser/` | Laser-specific fire animation |
| `robots/pyro/` | Pyro (unused) fire animation |
| `vehicles/jeep/` | Jeep base/damaged sprites |
| `vehicles/light_tank/` | Light tank sprites |
| `vehicles/medium_tank/` | Medium tank sprites |
| `vehicles/heavy_tank/` | Heavy tank sprites |
| `vehicles/apc/` | APC sprites |
| `vehicles/crane/` | Crane sprites |
| `vehicles/missile_launcher/` | Missile launcher sprites |
| `buildings/fort/` | Fort and flag sprites |
| `buildings/robot/` | Robot factory sprites |
| `buildings/vehicle/` | Vehicle factory sprites |
| `cannons/gatling/` | Gatling turret sprites |
| `cannons/howitzer/` | Howitzer sprites |
| `cannons/missile_cannon/` | Missile cannon sprites |

---

## 7. INPUT MAPPINGS (from project.godot)

| Action | Keys |
|--------|------|
| `move_left/right/up/down` | A, D, W, S |
| `zoom_in/out` | Mouse Wheel |
| `select` | Left Click |
| `order` | Right Click |
| `group_0` through `group_9` | 0-9 keys |
| Ctrl + `group_*` | Assign to group |

---

## 8. CODEBASE ARCHITECTURE DIAGRAM

```
                    ┌─────────────────────────────────────────┐
                    │           Main.tscn (Entry)              │
                    │  ┌─────────────────────────────────────┐ │
                    │  │ GameManager (game_manager.gd)       │ │
                    │  │ - NavigationRegion2D                │ │
                    │  │ - TileMapLayer                      │ │
                    │  │ - Camera2D + CameraController       │ │
                    │  │ - SelectionManager (singleton)      │ │
                    │  │ - LevelLoader (campaign system)     │ │
                    │  └─────────────────────────────────────┘ │
                    │  ┌─────────────────────────────────────┐ │
                    │  │ UI CanvasLayer                      │ │
                    │  │ - Sidebar (sidebar.gd)              │ │
                    │  └─────────────────────────────────────┘ │
                    └──────────────────┬──────────────────────┘
                                       │
           ┌───────────────────────────┼───────────────────────────┐
           │                           │                           │
           ▼                           ▼                           ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│ AUTOLOADED           │   │ SPAWNED AT RUNTIME   │   │ DATA ASSETS         │
│ ─────────────────── │   │ ─────────────────── │   │ ─────────────────── │
│ TerritoryManager     │   │ Units (from tscn)   │   │ levels.json         │
│ CombatManager        │◄──│ Buildings           │   │ units.json          │
│ GameState            │   │ Effects             │   │                     │
│ SelectionManager      │   └─────────────────────┘   └─────────────────────┘
└─────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────────┐
│ UNIT CLASS HIERARCHY                                               │
├─────────────────────────────────────────────────────────────────┤
│ UnitBase (CharacterBody2D)                                        │
│ ├── RobotBase (grunts, psychos, etc.)                            │
│ │   ├── grunt.gd (int 0)                                         │
│ │   ├── psycho.gd (int 1)                                        │
│ │   ├── tough.gd (int 2)                                          │
│ │   ├── sniper.gd (int 3)                                         │
│ │   ├── laser.gd (int 4)                                          │
│ │   ├── commander.gd (int 5)                                      │
│ │   ├── gatling.gd (stationary)                                   │
│ │   └── howitzer.gd (stationary, splash)                          │
│ │                                                                  │
│ ├── VehicleBase (extends UnitBase + driver system)                │
│     ├── jeep.gd                                                   │
│     ├── light_tank.gd                                             │
│     ├── medium_tank.gd                                            │
│     ├── heavy_tank.gd                                             │
│     ├── apc.gd (carries passengers)                               │
│     ├── missile_launcher.gd                                       │
│     └── crane.gd (repairs allies)                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 9. GAME FLOW

1. **Game Start** → `Main.tscn` loads
2. **Level Loading** → `LevelLoader.load_level()` reads `levels.json`
3. **Spawn Units/Buildings** → Factories, flags, starting units placed
4. **Game Loop**:
   - Units AI based on `intelligence` (0-5)
   - Combat via `CombatManager` projectiles
   - Territory capture via flag overlaps
   - Production speed scales with territories owned
5. **Victory** → Destroy all enemy units OR enemy fort
6. **Next Level** → `LevelLoader.advance_level()`

---

## 10. KEY MECHANICS SUMMARY

| Mechanic | Implementation |
|----------|----------------|
| **Territory Control** | Flags with Area2D overlap detection |
| **Production Scaling** | Speed = 1.0 + (0.15 × territories_owned) |
| **Driver Sniping** | Area2D hitbox on vehicles; kills driver → neutral |
| **Unit Intelligence** | 0-5 scale: 0=rush flags, 5=strategic |
| **Splash Damage** | Circle physics query with distance falloff |
| **Flying Turrets** | Tank death spawns physics body with gravity |

---

## 11. FILE COUNTS

| Category | Scripts | Scenes |
|----------|---------|--------|
| Core | 6 | 0 |
| Units | 17 | 16 |
| Buildings | 2 | 4 |
| Game | 3 | 0 |
| UI | 1 | 0 |
| Effects | 1 | 1 |
| Campaign | 1 | 0 |
| **Total** | **31** | **21** |
