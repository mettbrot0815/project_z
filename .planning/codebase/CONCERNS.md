# Codebase Concerns

**Analysis Date:** 2026-04-06

## Tech Debt

**Duplicate `find_nearest_enemy()` function:**
- Issue: Identical function copy-pasted across 12 unit scripts
- Files: `grunt.gd`, `psycho.gd`, `tough.gd`, `sniper.gd`, `laser.gd`, `commander.gd`, `jeep.gd`, `light_tank.gd`, `medium_tank.gd`, `heavy_tank.gd`, `missile_launcher.gd`, `howitzer.gd`, `gatling.gd`
- Impact: Maintenance nightmare - any change needs 13 edits
- Fix approach: Create a shared utility function in `UnitBase` class

**Missing `factory_vehicle.tscn` scene:**
- Issue: Levels reference `"type": "vehicle"` factories but scene doesn't exist
- Files: `scenes/buildings/factory_vehicle.tscn` (missing)
- Impact: Null reference error when loading any level with vehicle factories (19 levels!)
- Fix approach: Create `factory_vehicle.tscn` by duplicating `factory_robot.tscn` and setting `factory_type = "vehicle"`

**Debug `print()` statements in production code:**
- Issue: Console logging used for game feedback (damage states, voice, cutscenes)
- Files: `vehicle_base.gd` (4 prints), `game_manager.gd` (1 print), `level_loader.gd` (2 prints), `flying_turret.gd` (1 print)
- Impact: Performance overhead, noisy console in release builds
- Fix approach: Replace with proper logging system or remove in production

**Hardcoded magic numbers:**
- Issue: Thresholds like `4` (missile group size), `3` (howitzer group size), `100` (enemy detection range) scattered in code
- Files: `missile_launcher.gd`, `howitzer.gd`, multiple unit scripts
- Impact: Difficult to tune balance, inconsistent behavior
- Fix approach: Move to constants or `data/units.json` configuration

## Known Bugs

**Vehicle factory loading will crash:**
- Symptoms: "Failed to load unit scene" error, game freezes
- Files: `scripts/campaign/level_loader.gd:38-39`
- Trigger: Load any level with `{"type": "vehicle", ...}` factory (levels 2-20)
- Workaround: Only play level 1

**Flying turret `null` attacker in splash damage:**
- Symptoms: Potential null reference if attacker is already freed
- Files: `scripts/effects/flying_turret.gd:41`
- Trigger: Tank explodes while turret is in flight
- Workaround: Current code passes `null` to `apply_splash_damage` which handles it

## Security Considerations

**No input sanitization:**
- Risk: Direct values from `levels.json` used in scene loading
- Files: `scripts/campaign/level_loader.gd`
- Current mitigation: JSON parsing validates structure
- Recommendations: Validate factory types exist before loading

**No rate limiting on production:**
- Risk: Rapid clicking could spawn unlimited units
- Files: `scripts/ui/sidebar.gd:41`
- Current mitigation: None
- Recommendations: Add production cooldown indicator

## Performance Bottlenecks

**`get_tree().get_nodes_in_group("selectable")` called every frame:**
- Problem: Full tree traversal 60 times/second per unit
- Files: All unit scripts with AI (intelligence > 0)
- Cause: No caching of enemy/unit lists
- Improvement path: Use spatial partitioning or cached group queries

**No object pooling for projectiles:**
- Problem: New projectile dicts created/destroyed constantly
- Files: `scripts/core/combat_manager.gd`
- Cause: Array push/remove operations
- Improvement path: Pre-allocate projectile pool

**Flying turret instances accumulate:**
- Problem: Turrets spawn on each tank death, many could exist
- Files: `scripts/units/heavy_tank.gd:75-80`
- Cause: No cleanup of turrets that fall off map
- Improvement path: Add maximum turret count or auto-cleanup

## Fragile Areas

**Unit team assignment relies on both `team_id` and `team`:**
- Files: `scripts/core/unit_base.gd`, all unit scripts
- Why fragile: Two properties must be kept in sync manually
- Safe modification: Add setter to `team` property that also updates `team_id`
- Test coverage: Verify capture/copy logic maintains sync

**Factory production state machine:**
- Files: `scripts/core/factory.gd`
- Why fragile: Build progress, queue, and owner must coordinate
- Safe modification: Test mid-build capture scenarios thoroughly
- Test coverage: Missing - need automated tests for capture mid-production

**Navigation mesh generation:**
- Files: `scripts/game/game_manager.gd:26-31`
- Why fragile: Simple polygon doesn't match terrain obstacles
- Safe modification: Currently works with simple 2048x2048 map
- Test coverage: Navigation warnings appear in console

## Scaling Limits

**Map size fixed at 2048x2048:**
- Current capacity: 1 large map
- Limit: No multi-map support, no dynamic sizing
- Scaling path: Load different sized maps via level data

**Autoload singletons:**
- Current capacity: 4 singletons
- Limit: Limited to Godot's autoload system
- Scaling path: Convert to dependency injection if needed

**Unit selection array:**
- Current capacity: Unlimited (uses Array)
- Limit: UI may struggle with 100+ units
- Scaling path: Implement batch selection or unit caps

## Dependencies at Risk

**Godot 4.6.x only:**
- Risk: Godot releases break compatibility frequently
- Impact: Project requires exact 4.6.x version
- Migration plan: Pin to 4.6 LTS when available

**zod_engine external assets:**
- Risk: External repo could be deleted/moved
- Impact: No sprites, sounds, or maps
- Migration plan: Fork and commit assets locally

## Missing Critical Features

**No AI opponent:**
- Problem: Can't play against computer
- Blocks: Full gameplay testing, campaign completion

**No sprite assets:**
- Problem: Units invisible, no visual feedback
- Blocks: Playable experience, screenshots, marketing

**No sound system:**
- Problem: Silent gameplay
- Blocks: Immersion, polish

**No saved game system:**
- Problem: Can't save campaign progress
- Blocks: Long playthroughs, user retention

## Test Coverage Gaps

**Untested: Factory mid-build capture:**
- What's not tested: Timer continues vs resets on factory capture
- Files: `scripts/core/factory.gd`
- Risk: Core mechanic may not match original Z behavior
- Priority: HIGH

**Untested: Vehicle driver sniping:**
- What's not tested: Driver ejection, neutral capture, re-boarding
- Files: `scripts/units/vehicle_base.gd`
- Risk: Key mechanic could be broken
- Priority: HIGH

**Untested: Territory capture edge cases:**
- What's not tested: Multiple units capturing, enemy recapture during capture
- Files: `scripts/core/territory_manager.gd`, `scripts/buildings/flag.gd`
- Risk: Desync between flag and territory manager
- Priority: MEDIUM

**Untested: Projectile collision:**
- What's not tested: Projectiles hitting multiple units, self-collision
- Files: `scripts/core/combat_manager.gd`
- Risk: Incorrect damage application
- Priority: MEDIUM

**Untested: Victory condition triggers:**
- What's not tested: Simultaneous win/loss, draw conditions
- Files: `scripts/core/game_state.gd`
- Risk: Game could hang or incorrectly end
- Priority: MEDIUM

---

*Concerns audit: 2026-04-06*
