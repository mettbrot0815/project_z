# ARCHITECTURE.md - System Architecture

**Project:** Z (1996) Recreation in Godot 4.6  
**Date:** 2026-04-06  
**Confidence:** HIGH (comprehensive codebase analysis)

---

## Architecture Overview

### Design Pattern: Component-Based with Singletons

```
┌─────────────────────────────────────────────────────────────┐
│                        AUTOLOADS                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────┐ ┌───────────┐ │
│  │ Territory   │ │  Combat     │ │  Game   │ │ Selection │ │
│  │ Manager     │ │  Manager    │ │  State  │ │ Manager   │ │
│  └─────────────┘ └─────────────┘ └─────────┘ └───────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      GAME MANAGER                          │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐              │
│  │ Camera    │  │  Level     │  │  UI       │              │
│  │ Controller│  │  Loader    │  │  Sidebar  │              │
│  └───────────┘  └───────────┘  └───────────┘              │
└─────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
    ┌───────────┐       ┌───────────┐       ┌───────────┐
    │  UNITS    │       │ BUILDINGS │       │  EFFECTS  │
    │ (17 types)│       │(Flag,Fact,│       │(Turret,   │
    │           │       │  Fort)    │       │  Driver)  │
    └───────────┘       └───────────┘       └───────────┘
```

---

## Component Hierarchy

### Unit Class Hierarchy

```
UnitBase (class_name)
├── RobotBase (implicit via grunt.gd etc.)
│   ├── grunt.gd (intelligence: 0)
│   ├── psycho.gd (intelligence: 1)
│   ├── tough.gd (intelligence: 2)
│   ├── sniper.gd (intelligence: 3)
│   ├── laser.gd (intelligence: 4)
│   └── commander.gd (intelligence: 5)
│
└── VehicleBase (extends UnitBase)
    ├── jeep.gd
    ├── light_tank.gd
    ├── medium_tank.gd
    ├── heavy_tank.gd (with flying turret on death)
    ├── apc.gd
    ├── crane.gd
    └── missile_launcher.gd
```

### Stationary Units

```
GunBase (implicit via scripts)
├── gatling.gd (stationary, auto-fire)
└── howitzer.gd (stationary, splash damage)
```

---

## Core System Responsibilities

### TerritoryManager (Autoload)

**Responsibilities:**
- Track flag ownership and territories
- Calculate production multiplier
- Emit signals on capture

**Key Data:**
```gdscript
territories: Dictionary  # territory_id → {owner, flag, factories}
owned_territories: Dictionary  # Owner → count
production_multiplier: float  # 1.0 + (0.15 * total_owned)
```

**Signals:**
- `territory_captured(territory_id, new_owner)`
- `production_multiplier_updated(multiplier)`

**Key Methods:**
- `register_territory(id, flag)`
- `capture_territory(id, owner)`
- `get_production_speed_for_owner(owner)`
- `get_territory_count(owner)`

---

### CombatManager (Autoload)

**Responsibilities:**
- Manage active projectiles
- Handle collision detection
- Apply splash damage

**Key Data:**
```gdscript
active_projectiles: Array  # [{position, origin, target, velocity, damage, attacker}]
PROJECTILE_SPEED: 800.0
MAX_PROJECTILE_DISTANCE: 2000.0
```

**Signals:**
- `projectile_fired(origin, target)`
- `unit_damaged(unit, damage, attacker)`

**Key Methods:**
- `fire_projectile(origin, target, damage, attacker)`
- `apply_splash_damage(origin, radius, damage, attacker)`

---

### GameState (Autoload)

**Responsibilities:**
- Track win/loss conditions
- Manage game time
- Pause/resume

**Key Data:**
```gdscript
player_owner: int  # 1 = RED
game_running: bool
game_time: float
```

**Signals:**
- `game_won(winner)`
- `game_lost`

**Key Methods:**
- `check_victory_conditions()`
- `pause_game()`
- `resume_game()`

---

### SelectionManager (Autoload)

**Responsibilities:**
- Handle unit selection (single, box, groups)
- Issue move orders
- Track selected units

**Key Data:**
```gdscript
selected_units: Array
groups: Array[10]  # Hotkey groups
is_dragging_selection: bool
```

**Signals:**
- `selection_changed(selected_units)`

**Key Methods:**
- `set_selection(units)`
- `clear_selection()`
- `issue_move_order(target_pos)`
- `get_global_mouse_position()`

---

## Building Architecture

### Flag (Node2D)

**Structure:**
```
Flag (Node2D)
├── CollisionShape2D
└── Area2D
    └── CollisionShape2D (for capture detection)
```

**Key Properties:**
```gdscript
territory_id: int
team_owner: int  # Matches TerritoryManager.Owner
```

**Behavior:**
- Units entering Area2D trigger capture
- Ownership synced with TerritoryManager

---

### Factory (Node2D)

**Key Properties:**
```gdscript
territory_id: int
base_production_time: float  # 10.0 for robots
factory_type: String  # "robot" or "vehicle"
current_build: String
build_progress: float
is_producing: bool
team_owner: int
production_queue: Array
```

**Signals:**
- `production_started(unit_type)`
- `production_completed(unit)`

**Critical Behavior:**
- Mid-build capture does NOT reset timer
- Production speed scales with `TerritoryManager.get_production_speed_for_owner()`

---

### Fort (Node2D)

**Key Properties:**
```gdscript
max_hp: float  # 500
hp: float
team_id: int
```

**Behavior:**
- Corner turrets (decorative)
- HP tracking for victory conditions
- Destroyed = game over for that player

---

## Unit Architecture

### UnitBase (CharacterBody2D)

**Key Properties:**
```gdscript
max_hp: float
damage: float
move_speed: float
intelligence: int  # 0-5
unit_type: String
fire_rate: float
last_fired: float
team_id: int  # Avoid conflict with CharacterBody2D.owner
team: Team  # Enum: NEUTRAL, RED, BLUE
target: Node2D
current_order: Dictionary
navigation_agent: NavigationAgent2D
```

**Key Methods:**
```gdscript
move_to(target_position)  # Clamps to MAP_SIZE
attack(target_unit)
take_damage(amount, attacker)
die(killer)
get_team() → Team
get_team_id() → int
```

**Intelligence Behaviors:**
- `_find_nearest_flag()` - Grunt (0)
- `_find_nearest_enemy()` - Psycho (1)
- `_find_nearest_vehicle()` - Tough (2)
- `_find_nearest_driver()` - Sniper (3)
- `_avoid_threats()` - Laser (4)
- `_strategic_behaviour()` - Commander (5)

---

### VehicleBase (extends UnitBase)

**Additional Properties:**
```gdscript
has_driver: bool
driver_hitbox_offset: Vector2
driver_alive: bool
driver_hitbox: Area2D
```

**Signals:**
- `driver_killed()`

**Key Methods:**
- `kill_driver()` - Ejects driver, makes neutral
- `capture(new_owner)` - Claim neutral unmanned vehicle
- `can_be_captured()` → bool
- `update_damage_visuals()`

**Death Behavior:**
- `heavy_tank.gd`: `apply_splash_damage()`, spawn flying turret
- `missile_launcher.gd`: `apply_splash_damage()` (larger radius)

---

## Game Manager Architecture

### GameManager (Node2D)

**Children:**
```
GameManager
├── TileMap (TileMapLayer)
├── NavigationRegion2D
├── SelectionManager
└── LevelLoader
```

**Key Responsibilities:**
- Initialize navigation mesh
- Spawn units/buildings from level data
- Handle victory transitions

---

### LevelLoader (Node)

**Key Data:**
```gdscript
current_level: int
levels_data: Dictionary
MAX_LEVEL: int  # 20
```

**Key Methods:**
- `load_level(level_id)` - Spawns flags, factories, units
- `advance_level()` - Loads next or shows "Complete"
- `set_planet_theme(planet)` - Currently disabled
- `show_cutscene(level_id)` - Prints to console

---

## Data Flow

### Unit Spawning

```
LevelLoader.load_level()
    │
    ├─► Factory spawns unit
    │       │
    │       ├─► scene = load("res://scenes/units/{type}.tscn")
    │       ├─► unit = scene.instantiate()
    │       ├─► unit.team_id = team_owner
    │       ├─► unit.team = team_owner
    │       └─► add_child(unit)
    │
    └─► Signal: production_completed(unit)
```

### Territory Capture

```
Unit enters Flag.Area2D
    │
    └─► Flag Area2D body_entered signal
            │
            └─► TerritoryManager._on_flag_overlap()
                    │
                    └─► TerritoryManager.capture_territory()
                            │
                            ├─► Update owned_territories counts
                            ├─► Update production_multiplier
                            └─► Emit: territory_captured()

Factory production speeds up (via signal connection)
```

### Combat

```
Unit attacks (via _process)
    │
    └─► CombatManager.fire_projectile()
            │
            ├─► Create projectile dict
            ├─► Append to active_projectiles
            └─► Emit: projectile_fired()

CombatManager._physics_process()
    │
    ├─► Move projectile: position += velocity * delta
    │
    ├─► PhysicsPointQueryParameters2D at position
    │       │
    │       └─► Hit unit?
    │               │
    │               ├─► unit.take_damage(damage, attacker)
    │               └─► Remove projectile
    │
    └─► Distance check: remove if too far
```

---

## Pattern Analysis

### Consistent Patterns

| Pattern | Usage |
|---------|-------|
| `load("res://...")` with null check | Scene loading |
| `team_id` (not `owner`) | Avoid CharacterBody2D conflict |
| `TerritoryManager.Owner` enum | Team identification |
| Signal-based communication | Loose coupling |
| NavigationAgent2D | Pathfinding |
| `get_tree().get_nodes_in_group()` | Entity queries |

### Anti-Patterns Identified

| Issue | Location | Fix Applied |
|-------|----------|-------------|
| `unit.unit.team` | tough.gd | Fixed to `unit.team` |
| `canvas_modulate` access | level_loader.gd | Disabled |
| Duplicate `last_fired` | Child units | Removed (inherited) |
| `set_process(false)` on passengers | apc.gd | Fixed |
| Collision mask `0b11` | combat_manager.gd | Fixed to `0b1` |

---

## Map Structure

```
Map Size: 2048 x 2048 units
    │
    ├─► TileMapLayer (terrain)
    ├─► NavigationRegion2D (2048x2048 polygon)
    │
    └─► Units/Buildings (in world space)
```

---

## External Assets Reference

### From a-sf-mirror/zod_engine

| Asset Type | Location | Usage |
|------------|----------|-------|
| Unit sprites | `assets/units/` | Replace placeholder textures |
| Buildings | `assets/planets/` | Fort themes |
| Team colors | `assets/teams/` | Red/Blue identification |
| Sounds | `assets/sounds/` | Gunfire, explosions, voice |

### From BallWin/Qt_ZodEngine

| Reference | Usage |
|-----------|-------|
| `zobject.h` | Unit state machine, waypoints |
| Portrait animations | Voice bark system |
| Map format | `.map` file parser |

---

## Sources

1. `scripts/core/unit_base.gd` - Base unit class
2. `scripts/core/territory_manager.gd` - Territory system
3. `scripts/core/combat_manager.gd` - Combat system
4. `scripts/core/factory.gd` - Production system
5. `scripts/units/vehicle_base.gd` - Vehicle mechanics
6. `scripts/game/game_manager.gd` - Main orchestration
7. `scripts/campaign/level_loader.gd` - Level loading

---

*Generated from architecture analysis (2026-04-06)*
