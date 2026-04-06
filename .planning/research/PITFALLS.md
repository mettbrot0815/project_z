# PITFALLS.md - Known Issues and Pitfalls

**Project:** Z (1996) Recreation in Godot 4.6  
**Date:** 2026-04-06  
**Confidence:** HIGH (bugs documented from phases 1 & 2)

---

## Critical Pitfalls (Blockers)

These issues must be avoided or will cause game-breaking problems:

### 1. CharacterBody2D `owner` Property Conflict ⚠️ CRITICAL

**Problem:** CharacterBody2D has a built-in `owner` property that returns the parent Node. Defining `var owner: int` in child scripts causes conflicts.

**Affected Files:** All unit scripts originally

**Solution Applied:**
```gdscript
# Bad
var owner: int = 0

# Good
var team_id: int = 0
func get_team_id() -> int:
    return team_id
```

**Prevention:** Never name variables `owner` in CharacterBody2D-derived classes.

---

### 2. TileMap → TileMapLayer in Godot 4

**Problem:** `TileMap` node type was deprecated in Godot 4. Use `TileMapLayer` instead.

**Affected Files:** `game_manager.gd`, scene files

**Solution Applied:**
```gdscript
# Godot 3
@onready var tile_map: TileMap = $TileMap

# Godot 4
@onready var tile_map_layer: TileMapLayer = $TileMap
```

**Prevention:** Always use Godot 4 documentation when referencing node types.

---

### 3. Rect2.get_end() → Rect2.end

**Problem:** API change in Godot 4. `get_end()` method no longer exists.

**Affected Files:** `game_manager.gd` (navigation mesh creation)

**Solution Applied:**
```gdscript
# Godot 3
var rect = Rect2(0, 0, 2048, 2048)
rect.get_end()  # Error

# Godot 4
rect.end  # Correct
```

---

### 4. Projectile Collision Mask

**Problem:** `collision_mask = 0b11` causes projectiles to hit terrain. Should only hit units.

**Affected Files:** `combat_manager.gd`

**Solution Applied:**
```gdscript
# Wrong - hits layer 1 AND 2
query.collision_mask = 0b11

# Correct - only layer 1 (units)
query.collision_mask = 0b1
```

**Prevention:** Always verify collision layers match intended targets.

---

## High Priority Pitfalls

### 5. Null Scene Loading

**Problem:** `load("res://...")` can return null if scene doesn't exist. Not checking causes silent failures.

**Affected Files:** `factory.gd`, `vehicle_base.gd`, `heavy_tank.gd`

**Solution Applied:**
```gdscript
var scene = load("res://scenes/units/driver.tscn")
if scene == null:
    push_error("VehicleBase: Failed to load driver scene")
else:
    var driver = scene.instantiate()
    # ...
```

**Prevention:** Always check `load()` return values and use `push_error()` for debugging.

---

### 6. Team Enum Inconsistency

**Problem:** Mixed usage of `Team` enum vs integer values for team identification.

**Affected Files:** Multiple files

**Inconsistency Example:**
```gdscript
# In territory_manager.gd
enum Owner { NEUTRAL, RED, BLUE }

# In unit_base.gd  
enum Team { NEUTRAL, RED, BLUE }

# In factory.gd
var team_owner: int  # Sometimes int, sometimes enum
```

**Solution Applied:** Unified to `TerritoryManager.Owner` with `var team_owner: int = 0`

**Prevention:** Create a single shared enum in an autoload or global scope.

---

### 7. Mid-Build Factory Capture

**Problem:** Original Z behavior requires build timer to NOT reset on factory capture.

**Affected Files:** `factory.gd`

**Verification:**
```gdscript
# When territory is captured, factory's team_owner changes
# BUT build_progress timer continues (does NOT reset)
# Production speed scales with new owner's territories
```

**Prevention:** Verify timer behavior when testing factory capture.

---

### 8. Driver Sniping Detection

**Problem:** Area2D signal connection must be established before overlap detection works.

**Affected Files:** `vehicle_base.gd`, `territory_manager.gd`

**Solution Applied (VehicleBase):**
```gdscript
func _ready() -> void:
    driver_hitbox = $DriverHitbox
    if driver_hitbox:
        driver_hitbox.body_entered.connect(_on_driver_hit)
```

**Solution Applied (TerritoryManager):**
```gdscript
func register_territory(territory_id: int, flag_node: Node2D) -> void:
    var flag_area = flag_node.get_node_or_null("Area2D")
    if flag_area and flag_area.has_signal("body_entered"):
        flag_area.body_entered.connect(func(body): _on_flag_overlap(territory_id, body))
```

**Prevention:** Always verify signal connections in `_ready()`.

---

## Medium Priority Pitfalls

### 9. Group Threshold Magic Numbers

**Problem:** Hardcoded enemy count thresholds for group targeting (missile_launcher: 4, howitzer: 3).

**Affected Files:** `missile_launcher.gd`, `howitzer.gd`

**Current Values:**
```gdscript
# missile_launcher.gd
if nearby.size() >= 4:  # Group of 4+ triggers attack

# howitzer.gd  
if nearby.size() >= 3:  # Group of 3+ triggers attack
```

**Recommendation:** Move to constants or JSON config for tuning.

---

### 10. APC Passenger AI Preservation

**Problem:** Passengers should retain their AI state when boarding/disembarking.

**Affected Files:** `apc.gd`

**Issue:** `set_process(false)` was disabling passenger AI.

**Solution Applied:** Remove `set_process(false)` call.

**Prevention:** Test passenger AI after transport.

---

### 11. Crane Target Persistence

**Problem:** Crane should continuously repair damaged allies, not stop after first target.

**Affected Files:** `crane.gd`

**Solution:** Implemented continuous target re-evaluation.

**Prevention:** Test repair behavior with multiple damaged units.

---

### 12. Map Boundary Clamping

**Problem:** Units can move outside map boundaries without clamping.

**Affected Files:** `unit_base.gd`

**Solution Applied:**
```gdscript
func _physics_process(_delta: float) -> void:
    # Clamp position to map boundaries
    global_position.x = clamp(global_position.x, 0, MAP_SIZE.x)
    global_position.y = clamp(global_position.y, 0, MAP_SIZE.y)

func move_to(target_position: Vector2) -> void:
    # Clamp target to map boundaries
    target_position.x = clamp(target_position.x, 0, MAP_SIZE.x)
    target_position.y = clamp(target_position.y, 0, MAP_SIZE.y)
    navigation_agent.target_position = target_position
```

**Prevention:** Add boundary checks early in development.

---

## Minor Pitfalls (Polish Issues)

### 13. Damage State Visual Feedback

**Problem:** Damage states (smoke, fire, critical) only print to console, no visual change.

**Affected Files:** `vehicle_base.gd`

**Current Implementation:**
```gdscript
func set_damage_state(state: int) -> void:
    match state:
        0: print("%s: No damage" % unit_type)
        1: print("%s: Smoking" % unit_type)
        # ...
```

**Recommendation:** Implement sprite frame switching for visual feedback.

---

### 14. Voice Bark System

**Problem:** Voice barks only print to console, no audio playback.

**Affected Files:** `game_manager.gd`

**Current Implementation:**
```gdscript
func play_voice_bark(bark_type: String) -> void:
    var barks = {
        "moving": ["Yes sir!", "On my way!", "Roger that!"],
        # ...
    }
    if barks.has(bark_type):
        var line = barks[bark_type][randi() % barks[bark_type].size()]
        print("VOICE: ", line)  # No audio!
```

**Recommendation:** Implement AudioStreamPlayer for actual sound.

---

### 15. Canvas Modulate for Themes

**Problem:** Planet theme colors not applied due to `canvas_modulate` access issues.

**Affected Files:** `level_loader.gd`

**Current Implementation:**
```gdscript
func set_planet_theme(planet: String) -> void:
    pass  # Skipped - canvas_modulate access is different in Godot 4
```

**Recommendation:** Use viewport's `canvas_modulate` property in Godot 4.

---

## Development Phase Warnings

### Phase: Sprite Integration

**Warning:** When integrating sprites from zod_engine:

| Pitfall | Prevention |
|---------|------------|
| Sprite pivot point mismatch | Check center/anchor settings |
| Animation frame rate differences | Match to game tick rate |
| Team color overlay | Use shader or modulate |
| Scaling issues | Test at multiple zoom levels |

---

### Phase: Sound Integration

**Warning:** When integrating sounds from zod_engine:

| Pitfall | Prevention |
|---------|------------|
| Sound format compatibility | Convert to .ogg or .wav |
| Spatial audio setup | Use AudioStreamPlayer2D |
| Voice bark timing | Don't overlap multiple barks |
| Volume balancing | Separate music/SFX/voice |

---

### Phase: AI Opponent

**Warning:** When implementing AI:

| Pitfall | Prevention |
|---------|------------|
| Unfair advantages | Cap AI production multiplier |
| Predictable patterns | Add randomization |
| Rubber-banding | Avoid catch-up mechanics |
| Cheating visibility | Don't give AI information player lacks |

---

## Testing Checklist

Use this checklist when verifying bug fixes:

- [ ] Units spawn at factories with correct team
- [ ] Territory capture works for all team types
- [ ] Production continues after factory capture
- [ ] Driver sniping ejects driver sprite
- [ ] Neutral vehicles can be captured
- [ ] Projectiles only hit units (not terrain)
- [ ] Splash damage affects nearby units
- [ ] Group selection works (Ctrl+0-9)
- [ ] Move orders pathfind correctly
- [ ] Victory conditions trigger correctly
- [ ] Units stay within map boundaries
- [ ] AI units exhibit correct intelligence behavior

---

## Sources

1. `.planning/PROJECT-RESTRUCTURE-SUMMARY.md` - Phase 1 & 2 bug fixes
2. `scripts/core/unit_base.gd` - Base unit issues
3. `scripts/core/factory.gd` - Production bugs
4. `scripts/core/combat_manager.gd` - Collision issues
5. `scripts/units/vehicle_base.gd` - Driver mechanics
6. `scripts/game/game_manager.gd` - Scene loading issues

---

## Related Issues

### From Original AGENTS.md Discovery

| Bug | File | Fix |
|-----|------|-----|
| `owner` conflicts | All unit scripts | Renamed to `team_id` |
| Missing `hp` init | `unit_base.gd` | Added `hp = max_hp` |
| Missing `get_team_id()` | `unit_base.gd` | Added method |
| Duplicate `last_fired` | Child units | Removed |
| `unit.unit.team` typo | `tough.gd` | Fixed |
| Collision mask `0b11` | `combat_manager.gd` | Fixed to `0b1` |

---

*Generated from bug analysis (2026-04-06)*
