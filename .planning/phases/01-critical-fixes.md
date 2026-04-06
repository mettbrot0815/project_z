# Phase 1: Critical Fixes - Plan
Tasks
High Priority
Create Driver Ejection Scene — scenes/units/driver.tscn
Create Flying Turret Effect Scene — scenes/effects/flying_turret.tscn
Unify Team Enum — Replace all Owner usage with Team enum
Fix Projectile Collision — Set collision_mask = 0b1 (units only)
Fix Tough Unit Targeting — Remove erroneous .unit.unit.team reference
Fix APC Passenger AI — Passengers must retain AI after load/unload
Fix Crane Repair Logic — Persistent target seeking when ally moves
Correct Missile Launcher Threshold — Require 4+ enemies for group attack
Correct Howitzer Threshold — Require 3+ enemies for group attack

Medium Priority
Fix Projectile Distance Logic — Remove broken Vector2 comparison
Update Remaining Core Scripts — game_state.gd, vehicle_base.gd, etc.

Low Priority
Placeholder Assets — Basic textures for driver and flying turret

Verification
All missing scenes created and load cleanly
No enum mismatches (Team used everywhere)
Projectiles only collide with units
Driver ejection, flying turret effects, APC, Crane, and group-targeting AI all work
Zero console errors on level load