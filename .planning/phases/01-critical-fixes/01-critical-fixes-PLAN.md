---
phase: 01-critical-fixes
plan: 01
type: execute
wave: 1
depends_on: []
files_modified: 
  - scenes/units/driver.tscn
  - scenes/effects/flying_turret.tscn
  - scripts/core/territory_manager.gd
  - scripts/core/combat_manager.gd
  - scripts/core/game_state.gd
  - scripts/units/tough.gd
  - scripts/units/missile_launcher.gd
  - scripts/units/howitzer.gd
  - scripts/units/crane.gd
  - scripts/units/apc.gd
must_haves:
  truths:
    - "Driver sprites are ejected when vehicle driver is killed"
    - "Flying turret effects appear when tanks explode"
    - "All units use consistent Team enum (not mixed with Owner)"
    - "Projectiles only collide with units (collision_mask = 0b1)"
    - "APC passengers remain functional after loading/unloading"
    - "Crane persists repair target across movement"
    - "Missile launcher groups require 4+ enemies"
    - "Howitzer groups require 3+ enemies"
  artifacts:
    - path: "scenes/units/driver.tscn"
      provides: "Driver sprite for vehicle ejection"
      min_lines: 20
    - path: "scenes/effects/flying_turret.tscn"
      provides: "Flying turret visual effect"
      min_lines: 20
    - path: "scripts/core/territory_manager.gd"
      provides: "Unified Team enum"
      contains: "enum Team"
    - path: "scripts/core/combat_manager.gd"
      provides: "Fixed projectile collision"
      exports: ["fire_projectile", "apply_splash_damage"]
  key_links:
    - from: "scenes/units/driver.tscn"
      to: "scripts/units/vehicle_base.gd"
      via: "driver_scene.load()"
      pattern: "load.*driver.tscn"
---

<objective>
Fix all critical bugs and missing assets that prevent core gameplay from working correctly.

Purpose: This phase addresses blocker-level issues that break fundamental game mechanics: missing driver ejection, flying turret effects, enum inconsistencies, and collision bugs.

Output: 2 new scene files created, 9 existing files fixed with corrected logic and consistent enum usage.
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
The following issues were identified during codebase analysis:

## Missing Files (Blocker)
- `scenes/units/driver.tscn` - Driver ejection doesn't work
- `scenes/effects/flying_turret.tscn` - Tank explosions lack visual feedback

## Enum Inconsistency (Blocker)
- `territory_manager.gd` uses `Owner` enum (NEUTRAL, RED, BLUE)
- `unit_base.gd` uses `Team` enum (NEUTRAL, RED, BLUE)
- Unit scripts mix `.owner` (int) and `.team` (enum) properties

## Logic Bugs (High Priority)
- `combat_manager.gd:36`: collision_mask = 0b11 (collides with everything)
- `tough.gd:30`: `unit.unit.team` doesn't exist on all units
- `apc.gd:82-83`: Passengers lose AI when loaded
- `crane.gd:9`: Target lost when moving out of range
- `missile_launcher.gd:67`: Checks >= 3 for "4+ enemies"
- `howitzer.gd:83`: Checks >= 2 for "3+ enemies"
- `projectile.gd:49`: Compares Vector2 distance to target (meaningless)
</context>

<tasks>

<task type="auto">
  <name>Create driver.tscn scene for vehicle ejection</name>
  <files>scenes/units/driver.tscn</files>
  <action>
    Create a new driver sprite scene with:
    - Sprite2D node with placeholder texture (red circle for now)
    - Area2D for projectile collision (driver hitbox)
    - CharacterBody2D for physics
    - CollisionShape2D with circle shape radius 16
    - NavigationAgent2D for pathfinding
    
    Driver should be ejected with physics velocity when killed.
    Scene should be minimal - driver visual only, no AI needed.
  </action>
  <verify>File exists with Sprite2D and collision shape</verify>
  <done>Driver scene loads without errors, has sprite and collision</done>
</task>

<task type="auto">
  <name>Create flying_turret.tscn visual effect scene</name>
  <files>scenes/effects/flying_turret.tscn</files>
  <action>
    Create a flying turret particle effect scene with:
    - Sprite2D with placeholder (yellow circle for turret)
    - Velocity for upward trajectory (-300 to -500 Y)
    - CollisionShape2D for collision detection
    - NavigationAgent2D for movement
    
    Effect should appear when tanks explode, flying upward with random X velocity.
    This is a visual effect, no AI needed - just physics-based movement.
  </action>
  <verify>File exists with sprite and velocity setup</verify>
  <done>Flying turret scene loads without errors</done>
</task>

<task type="auto">
  <name>Unify Team and Owner enums in territory_manager.gd</name>
  <files>scripts/core/territory_manager.gd</files>
  <action>
    Replace Owner enum with Team enum to match unit_base.gd:
    - Change `enum Owner { NEUTRAL, RED, BLUE }` to use Team enum
    - Update all references: `Owner.NEUTRAL` → `Team.NEUTRAL`, etc.
    - Change `team_owner: int` to `team_owner: Team`
    - Update signal types to use Team instead of int
    
    This ensures all scripts use the same enum for team ownership.
  </action>
  <verify>Enum matches unit_base.gd Team enum</verify>
  <done>territory_manager uses Team enum consistently</done>
</task>

<task type="auto">
  <name>Fix projectile collision mask in combat_manager.gd</name>
  <files>scripts/core/combat_manager.gd</files>
  <action>
    Change collision mask from 0b11 to 0b1:
    - Line 36: `query.collision_mask = 0b11` → `query.collision_mask = 0b1`
    - This ensures projectiles only collide with units (collision layer 1)
    
    Also fix the distance check issue - projectiles should remove on collision,
    not just when reaching target. The current logic is broken.
  </action>
  <verify>collision_mask = 0b1, projectiles hit units correctly</verify>
  <done>Projectiles only collide with units, not terrain</done>
</task>

<task type="auto">
  <name>Fix tough.gd unit.unit.team reference bug</name>
  <files>scripts/units/tough.gd</files>
  <action>
    Fix line 30: Change `unit.unit.team != self.team` to `unit.team != self.team`
    - `unit.unit` doesn't exist on all unit types
    - Should directly access `unit.team` property from unit_base.gd
    
    This bug causes Tough units to incorrectly filter enemies.
  </action>
  <verify>Tough units correctly identify enemies</verify>
  <done>Tough unit AI works correctly</done>
</task>

<task type="auto">
  <name>Fix APC passenger AI persistence bug</name>
  <files>scripts/units/apc.gd</files>
  <action>
    Fix passenger loading/unloading:
    - Line 82-83: Remove `unit.set_process(false)` - passengers keep their AI
    - Passengers should remain functional after being loaded/unloaded
    - When unloading, restore visible and process, but don't stop AI
    
    This preserves passenger autonomy and AI behavior.
  </action>
  <verify>APC passengers retain their AI and can move independently</verify>
  <done>APC passengers remain functional after transport</done>
</task>

<task type="auto">
  <name>Fix crane target persistence bug</name>
  <files>scripts/units/crane.gd</files>
  <action>
    Fix target tracking when out of range:
    - When crane moves away from damaged ally, it should seek next target
    - Add a timeout or re-evaluate target when moving
    
    Current code: crane loses target and stops repairing.
    Fix: Crane should continuously seek damaged allies within range.
  </action>
  <verify>Crane finds new target when current ally moves out of range</verify>
  <done>Crane persistently repairs damaged allies</done>
</task>

<task type="auto">
  <name>Fix missile launcher group detection threshold</name>
  <files>scripts/units/missile_launcher.gd</files>
  <action>
    Fix line 67: Change `if nearby.size() >= 3:` to `if nearby.size() >= 4:`
    - Comment says "Group of 4+" but code checks for 3
    - Should require 4+ enemies to count as a group
    
    This fixes targeting logic for missile launcher AI.
  </action>
  <verify>Missile launcher groups require 4+ enemies</verify>
  <done>Missile launcher correctly identifies enemy groups</done>
</task>

<task type="auto">
  <name>Fix howitzer group detection threshold</name>
  <files>scripts/units/howitzer.gd</files>
  <action>
    Fix line 83: Change `if nearby.size() >= 2:` to `if nearby.size() >= 3:`
    - Comment says "Group of 3+" but code checks for 2
    - Should require 3+ enemies to count as a group
    
    This fixes targeting logic for howitzer AI.
  </action>
  <verify>Howitzer groups require 3+ enemies</verify>
  <done>Howitzer correctly identifies enemy groups</done>
</task>

<task type="checkpoint:human-verify">
  <what-built>All critical bug fixes and missing scenes</what-built>
  <how-to-verify>
    1. Open project in Godot 4.6
    2. Check scenes/units/driver.tscn exists and loads
    3. Check scenes/effects/flying_turret.tscn exists and loads
    4. Run the game - verify no console errors
    5. Test vehicle driver ejection (shoot jeep/tank)
    6. Test tank explosion with flying turret effect
    7. Verify projectiles only hit units (not terrain)
    8. Test APC passenger AI after loading/unloading
    9. Test crane repair persistence
  </how-to-verify>
  <resume-signal>Type "approved" or describe issues</resume-signal>
</task>

<verification>
- All missing scenes created (driver, flying_turret)
- Enum consistency achieved across all scripts
- Collision mask corrected to 0b1
- All identified logic bugs fixed
- APC and crane AI bugs resolved
- Group detection thresholds corrected
</verification>

<success_criteria>
- No console errors when loading scenes
- Driver sprites ejected correctly
- Flying turret effects appear on tank deaths
- Projectiles only collide with units
- All unit AI functions correctly
- No enum mismatches in code
</success_criteria>

<output>
After completion, create `.planning/phases/01-critical-fixes/01-critical-fixes-SUMMARY.md`
</output>

<tasks>
</tasks>

<verification>
Phase 1 complete when all 9 tasks completed and verified
</verification>

<success_criteria>
All critical bugs fixed, missing scenes created, game runs without errors
</success_criteria>
