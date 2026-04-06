# STACK.md - Technology Stack Research

**Project:** Z (1996) Recreation in Godot 4.6  
**Date:** 2026-04-06  
**Confidence:** HIGH (project.godot analysis + current implementation)

---

## Core Engine

| Technology | Version | Rationale |
|------------|---------|-----------|
| **Godot Engine** | 4.6.x | 2D physics, NavigationServer2D, signal system, autoloads |
| **GDScript** | - | Native Godot language, clean syntax for game logic |
| **Godot Scene System** | - | tscn format for all units, buildings, effects |

### Why Godot 4 over alternatives?

| Alternative | Why Not |
|-------------|---------|
| Unity 2D | Requires C#, more complex 2D toolset |
| Custom engine | Time investment, no editor support |
| Godot 3.x | NavigationServer2D improvements in 4.x |
| GameMaker | Limited signal system, harder RTS implementation |

---

## Core Systems

### Physics & Navigation

| System | Implementation | Notes |
|--------|---------------|-------|
| **NavigationServer2D** | NavigationRegion2D + NavigationAgent2D | Pathfinding for all units |
| **Collision** | CharacterBody2D + CollisionShape2D | Unit movement and selection |
| **PhysicsQuery** | PhysicsPointQueryParameters2D | Projectile collision, selection raycast |
| **2D Physics** | Built-in Godot 2D physics | Fixed 60-tick timing |

### Rendering

| System | Implementation | Notes |
|--------|---------------|-------|
| **TileMapLayer** | Godot 4 TileMap | Terrain rendering (replaces deprecated TileMap) |
| **Canvas Items** | 2D sprites and shapes | Unit and building rendering |
| **Viewport** | Main viewport + canvas transform | Camera-based scrolling |

### State Management

| System | Implementation | Notes |
|--------|---------------|-------|
| **Autoloads** | Global singletons | TerritoryManager, CombatManager, GameState, SelectionManager |
| **Signals** | Godot signal system | Loose coupling between systems |
| **Groups** | `selectable`, `building`, `fort` | Group-based queries |

---

## Data & Configuration

| Technology | Format | Rationale |
|------------|--------|-----------|
| **JSON** | `data/units.json`, `data/levels.json` | Human-readable, easy to edit |
| **Godot Resources** | .tscn scene files | Visual editor integration |
| **Export variables** | `@export` in scripts | Inspector-friendly tuning |

### Data Files

| File | Purpose | Size |
|------|---------|------|
| `data/units.json` | 17 unit definitions | 116 lines |
| `data/levels.json` | 20 campaign levels | 602 lines |

---

## Input System

| Input Type | Implementation | Bindings |
|------------|---------------|----------|
| **Keyboard** | InputEventKey | WASD (movement), 0-9 (groups) |
| **Mouse** | InputEventMouseButton | Left (select), Right (order), Wheel (zoom) |
| **Edge scroll** | CameraController | Mouse near viewport edges |

### Input Actions (project.godot)

```gdscript
move_left, move_right, move_up, move_down  # WASD
zoom_in, zoom_out                            # Mouse wheel
select, order                                # Mouse buttons
group_0 through group_9                       # Ctrl+0-9 save, 0-9 load
```

---

## Project Structure

```
project_z/
├── project.godot              # 146 lines, Godot 4.6 config
├── scenes/
│   ├── main.tscn              # Main scene
│   ├── units/                 # 17 unit scenes
│   └── buildings/             # Factory, flag, fort scenes
├── scripts/
│   ├── core/                  # 5 singletons
│   ├── game/                  # GameManager, CameraController, SelectionManager
│   ├── units/                 # 17 unit scripts + vehicle_base
│   ├── buildings/             # fort.gd, flag.gd
│   ├── ui/                   # sidebar.gd
│   └── campaign/             # level_loader.gd
└── data/
    ├── units.json             # Unit database
    └── levels.json            # Campaign data
```

---

## Dependencies

### Internal Dependencies (Autoloads)

| Autoload | Type | Purpose |
|----------|------|---------|
| TerritoryManager | Node | Flag capture, production multiplier |
| CombatManager | Node | Projectiles, splash damage |
| GameState | Node | Win/loss conditions, game time |
| SelectionManager | Node | Unit selection, groups, move orders |

### Scene Dependencies

| Pattern | Usage |
|---------|-------|
| `load("res://scenes/...")` | Lazy loading for unit spawning |
| `instantiate()` | Runtime scene creation |
| Error checking | `if scene == null` for robustness |

---

## Performance Considerations

| Area | Implementation |
|------|---------------|
| **Physics** | 3 max steps/frame, 8 contacts/collision |
| **Threading** | Thread model 2 (single thread for simplicity) |
| **Rendering** | Texture atlases enabled, 2D snap to pixel |
| **Navigation** | Simple polygon nav mesh (2048x2048 map) |

---

## Critical Version Requirements

| Requirement | Value | Reason |
|-------------|-------|--------|
| **Godot version** | 4.6.x | NavigationServer2D, TileMapLayer |
| **GDScript** | Godot 4 syntax | `class_name`, `extends`, `@export` |
| **Config format** | project.godot v5 | Godot 4 format |

---

## Future Considerations

### Potential Upgrades

| Upgrade | Current State | Recommendation |
|---------|--------------|----------------|
| **Multiplayer** | Network section in project.godot | ENet ready, not implemented |
| **Shaders** | None | Could add for terrain effects |
| **Particles** | None | Flying turrets use scenes, not particles |
| **Audio** | Placeholder only | Needs sound implementation |

---

## Sources

1. `project.godot` - Full project configuration analysis
2. `scripts/core/*.gd` - Autoload implementations
3. Current working codebase with no errors

---

*Generated from codebase analysis (2026-04-06)*
