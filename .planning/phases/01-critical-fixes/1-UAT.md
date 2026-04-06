---
status: testing
phase: 01-critical-fixes
source: 01-critical-fixes-SUMMARY.md
started: 2026-04-06T15:00:00Z
updated: 2026-04-06T15:00:00Z
---

## Current Test

number: 3
name: Flying turret appears when tanks explode
expected: |
  Destroy a tank (light_tank, medium_tank, or heavy_tank). A flying turret
  effect should spawn and fly upward before falling/detonating.
awaiting: user response

### 2. Driver ejected when vehicle driver killed
expected: |
  Shoot and kill the driver of any vehicle (jeep, tank, etc). The driver sprite
  should be ejected from the vehicle with physics velocity, leaving the vehicle
  in neutral/claimable state.
result: skipped
reason: "No sprite textures - units are invisible. Can't verify visually. Functionality works (code is correct), but no assets to see."

### 3. Flying turret appears when tanks explode
expected: |
  Destroy a tank (light_tank, medium_tank, or heavy_tank). A flying turret
  effect should spawn and fly upward before falling/detonating.
result: [pending]

### 4. Projectiles only hit units, not terrain
expected: |
  Fire projectiles at terrain (non-unit areas). Projectiles should not collide
  with terrain - they should only hit units on collision layer 1.
result: [pending]

### 5. Tough units correctly target enemies
expected: |
  Deploy a tough unit. It should correctly identify and attack enemy vehicles
  (not the wrong target type due to unit.unit.team bug).
result: [pending]

### 6. APC passengers retain AI after transport
expected: |
  Load units into an APC, then unload them. The passengers should remain
  functional with their AI intact - they should be able to move and act
  independently after unloading.
result: [pending]

### 7. Crane persists repair target across movement
expected: |
  Have a crane repair a damaged ally. If the ally moves away, the crane should
  find a new damaged ally within range rather than stopping.
result: [pending]

### 8. Missile launcher targets groups of 4+ enemies
expected: |
  Use a missile launcher near multiple enemies. It should only use area-targeting
  against groups of 4 or more enemies (not 3 as before).
result: [pending]

### 9. Howitzer targets groups of 3+ enemies
expected: |
  Use a howitzer near multiple enemies. It should only use area-targeting
  against groups of 3 or more enemies (not 2 as before).
result: [pending]

### 10. No debug print statements in console
expected: |
  Run the game normally. Console should be free of debug print statements
  from vehicle_base.gd, game_manager.gd, level_loader.gd, flying_turret.gd.
result: [pending]

## Summary

total: 10
passed: 1
issues: 0
pending: 9
skipped: 0

## Gaps

[none yet]