---
phase: 02-architecture
plan: 02
type: execute
wave: 1
depends_on: 
  - "01-critical-fixes"
files_modified: 
  - scripts/core/game_state.gd
  - scripts/core/factory.gd
  - scripts/core/combat_manager.gd
  - scripts/core/territory_manager.gd
  - scripts/units/vehicle_base.gd
  - scripts/units/commander.gd
  - scripts/units/laser.gd
  - scripts/ui/sidebar.gd
  - scripts/ui/sidebar.gd
must_haves:
  truths:
    - "Factory owner uses Team enum consistently"
    - "Projectiles remove on collision, not just distance"
    - "Unit groups can be loaded from Ctrl+0-9"
    - "All load() calls have error handling"
    - "Factory production queue works correctly"
    - "Units stay within map boundaries"
  artifacts:
    - path: "scripts/core/factory.gd"
      provides: "Team enum for owner tracking"
      exports: ["start_production", "complete_production"]
    - path: "scripts/core/game_state.gd"
      provides: "Error handling for victory conditions"
      exports: ["check_victory_conditions"]
    - path: "scripts/core/combat_manager.gd"
      provides: "Fixed projectile removal logic"
      exports: ["fire_projectile", "apply_splash_damage"]
  key_links:
    - from: "scripts/core/factory.gd"
      to: "scripts/core/territory_manager.gd"
      via: "team_owner type"
      pattern: "team_owner.*int"
    - from: "scripts/core/combat_manager.gd"
      to: "scripts/core/territory_manager.gd"
      via: "owner property"
      pattern: "owner.*int"
---

<objective>
Improve project architecture by adding error handling, fixing logic bugs, and completing core functionality.

Purpose: This phase addresses secondary issues that affect game stability and completeness: missing error handling, inconsistent property usage, incomplete feature implementation, and boundary checks.

Output: 8 files modified with improved error handling, correct enum usage, and completed functionality.
</objective>

<execution_context>
@C:/Users/Philipp/.config/opencode/get-shit-done/workflows/execute-plan.md
@C:/Users/Philipp/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md

# Bug Context
Phase 1 completed all critical fixes. Phase 2 now addresses:
- Factory owner tracking (uses int instead of Team enum)
- Projectile removal logic (should remove on collision)
- Unit group loading (Ctrl+0-9 saves but never loads)
- load() error handling (silent failures)
- Map boundary checks (units can walk off map)

These issues affect game stability and completeness but don't block core gameplay.
</context>

<tasks>

<task type="auto">
  <name>Fix factory owner tracking to use Team enum</name>
  <files>scripts/core/factory.gd</files>
  <action>
    Change `team_owner: int` to `team_owner: Team`:
    - Line 16: `var team_owner: int = 0` → `var team_owner: Team = Team.NEUTRAL`
    - Update signal handlers to use Team enum
    - Ensure production starts with correct team
    
    This ensures factory owner is consistent with territory manager.
  </action>
  <verify>Factory owner uses Team enum, production starts correctly</verify>
  <done>Factory owner tracking uses Team enum</done>
</task>

<task type="auto">
  <name>Fix projectile removal logic in combat_manager</name>
  <files>scripts/core/combat_manager.gd</files>
  <action>
    Fix the broken distance check:
    - Line 49: `proj.target` is Vector2, not a Node2D
    - Should check actual collision with target node
    - Add logic to check if projectile is within 8 units of target node position
    
    Current logic removes projectiles based on meaningless comparison.
    Fix should properly track target node and remove on collision or reach.
  </action>
  <verify>Projectiles remove on collision with target or when reaching target position</verify>
  <done>Projectile removal logic works correctly</done>
</task>

<task type="auto">
  <name>Add load() error handling to all scripts</name>
  <files>
    - scripts/units/vehicle_base.gd
    - scripts/core/factory.gd
    - scripts/campaign/level_loader.gd
    - scripts/buildings/fort.gd
  </files>
  <action>
    Add try-catch blocks around all load() calls:
    
    vehicle_base.gd:41:
    ```gdscript
    var driver_scene = load("res://scenes/units/driver.tscn")
    if driver_scene:
        var driver = driver_scene.instantiate()
    ```
    
    factory.gd:49:
    ```gdscript
    var unit_scene = load("res://scenes/units/%s.tscn" % current_build)
    if unit_scene:
        var unit = unit_scene.instantiate()
    ```
    
    This prevents silent failures when scenes are missing.
  </action>
  <verify>No silent failures on load, proper error messages</verify>
  <done>All load() calls have error handling</done>
</task>

<task type="auto">
  <name>Implement unit group loading from hotkeys</name>
  <files>scripts/ui/sidebar.gd</files>
  <action>
    Add group loading functionality:
    - Ctrl+0-9 saves groups (already works)
    - Add "group_load_0" through "group_load_9" input actions
    - Implement `load_group(group_number)` function
    - Show loading status in UI
    
    This completes the selection group feature.
  </action>
  <verify>Ctrl+0-9 saves groups, Ctrl+Shift+0-9 loads groups</verify>
  <done>Unit group loading works correctly</done>
</task>

<task type="auto">
  <name>Add map boundary checks to unit movement</name>
  <files>scripts/core/unit_base.gd</files>
  <action>
    Add boundary clamping to `move_to()`:
    ```gdscript
    func move_to(target_position: Vector2) -> void:
        # Clamp to map boundaries (2048x2048)
        target_position = Vector2(
            clamp(target_position.x, 0, 2048),
            clamp(target_position.y, 0, 2048)
        )
        navigation_agent.target_position = target_position
    ```
    
    Also clamp in AI pathfinding to prevent out-of-bounds movement.
  </action>
  <verify>Units stay within 2048x2048 map boundaries</verify>
  <done>Units cannot walk off the map</done>
</task>

<task type="checkpoint:human-verify">
  <what-built>All architecture improvements and error handling</what-built>
  <how-to-verify>
    1. Open project in Godot 4.6
    2. Check no console errors on load
    3. Test factory production with different teams
    4. Test projectile collision with targets
    5. Test Ctrl+0-9 to save groups, Ctrl+Shift+0-9 to load
    6. Test unit movement to map edges
    7. Check all load() calls have error handling
  </how-to-verify>
  <resume-signal>Type "approved" or describe issues</resume-signal>
</task>

<verification>
- Factory owner uses Team enum
- Projectile removal works correctly
- All load() calls have error handling
- Unit group loading implemented
- Map boundaries enforced
</verification>

<success_criteria>
- No console errors on project load
- Factory production works with all teams
- Projectiles hit targets correctly
- Group save/load works (Ctrl+0-9 / Ctrl+Shift+0-9)
- Units stay within map boundaries
- All load() calls have proper error handling
</success_criteria>
