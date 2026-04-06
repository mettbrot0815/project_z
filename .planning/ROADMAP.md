# ROADMAP.md - Project Z Recreation

## Table of Contents
1. [Phase 1: Critical Fixes](#phase-1-critical-fixes)
2. [Phase 2: Visual Assets](#phase-2-visual-assets)
3. [Phase 3: AI Opponent](#phase-3-ai-opponent)
4. [Phase 4: Audio & Polish](#phase-4-audio--polish)
5. [Phase 5: Testing & Polish](#phase-5-testing--polish)
6. [Phase 6: Release Preparation & Launch](#phase-6-release-preparation--launch)

---

## Phase 1: Critical Fixes - Plan
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

---

## Phase 2: Visual Assets - Plan
Tasks
High Priority
Create Sprite Manager — New scripts/core/sprite_manager.gd
Integrate Sprites – Infantry — Grunt, Psycho, Tough, Sniper, Laser, Commander
Integrate Sprites – Vehicles — Jeep, Light/Medium/Heavy Tank, APC, Crane, Missile Launcher, Gatling, Howitzer
Integrate Buildings — Factory, Fort, Flag

Medium Priority
Centered Pivot Points — All sprites properly centered
Team Color System — Correct red/blue variants
Animation Integration — Walk, idle, attack where applicable

Low Priority
Placeholder Fallbacks — Prevent pink squares

Verification
All 17 unit types have visible, team-colored sprites
No visual errors in any level

---

## Phase 3: AI Opponent - Plan
Tasks
High Priority
Create AI Controller — scripts/game/ai_controller.gd (autoload)
Implement AI State Machine — EXPAND → ATTACK → DEFEND → REINFORCE
AI Production Logic — Difficulty-based unit production
AI Unit Command System — Squad control

Medium Priority
Difficulty Tuning — Easy / Normal / Hard behaviors
Territory Awareness — Use TerritoryManager for decisions

Low Priority
AI Debug Visualization

Verification
AI playable and beatable on all 20 levels
Clear difficulty progression

---

## Phase 4: Audio & Polish - Plan
Tasks
High Priority
Create Audio Manager — scripts/core/audio_manager.gd
Explosion Effect + Sound
Death & Destruction Feedback
Weapon Firing Sounds + Muzzle Flash

Medium Priority
Voice Barks
Background Music
Damage Visuals (smoke)

Low Priority
Audio Settings Menu

Verification
All major actions have proper audio + visual feedback
Game feels polished and immersive

---

## Phase 5: Testing & Polish - Plan
Tasks
High Priority
Test Level 1-5 — Basic gameplay
Test Level 6-10 — Medium AI
Test Level 11-15 — Hard AI
Test Level 16-20 — Maximum challenge

Medium Priority
Test Edge Cases
Projectile Pooling
Enemy Query Caching

Low Priority
Flying Turret Limits

Verification
All 20 levels completable
No crashes
Performance > 30 FPS with 50+ units

---

## Phase 6: Release Preparation & Launch - Plan
Tasks
High Priority
Final Build & Packaging — All target platforms
Platform Compatibility Testing
Store Submission Preparation — Screenshots, descriptions, trailers
Release Candidate Approval

Medium Priority
Marketing Assets — Press kit, announcements
Patch & Hotfix Plan
Analytics Integration

Low Priority
Future Content Roadmap

Verification
Stable release builds on all platforms
Store listings ready
Monitoring active
Launch date confirmed