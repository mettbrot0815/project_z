# FEATURES.md - Feature Analysis

**Project:** Z (1996) Recreation in Godot 4.6  
**Date:** 2026-04-06  
**Confidence:** HIGH (comprehensive codebase analysis)

---

## Table Stakes (Must-Have)

These features are essential for a playable RTS and are currently implemented:

### Core Gameplay

| Feature | Status | Implementation |
|---------|--------|----------------|
| **Unit Selection** | ✅ Complete | Single click, drag box, group selection |
| **Move Orders** | ✅ Complete | Right-click pathfinding with NavigationAgent2D |
| **Unit Movement** | ✅ Complete | CharacterBody2D with boundary clamping |
| **Territory Capture** | ✅ Complete | Flag overlap → capture signal |
| **Factory Production** | ✅ Complete | Build queue, mid-capture timer preservation |
| **Combat System** | ✅ Complete | Projectiles, collision, damage |
| **Victory Conditions** | ✅ Complete | Fort destruction, unit wipe detection |

### Unit Roster (17 Types)

| Category | Units | Status |
|----------|-------|--------|
| **Robots (6)** | Grunt, Psycho, Tough, Sniper, Laser, Commander | ✅ All implemented |
| **Vehicles (7)** | Jeep, Light Tank, Medium Tank, Heavy Tank, APC, Crane, Missile Launcher | ✅ All implemented |
| **Guns (2)** | Gatling, Howitzer | ✅ All implemented |
| **Support (2)** | Driver, FlyingTurret | ✅ Created (need verification) |

### Buildings

| Building | Status | Notes |
|---------|--------|-------|
| **Flag** | ✅ Complete | Area2D for capture, team tracking |
| **Factory (Robot)** | ✅ Complete | Production queue, spawn logic |
| **Factory (Vehicle)** | ✅ Complete | Same as robot factory |
| **Fort** | ✅ Complete | Corner turrets, HP tracking |

### UI & Controls

| Feature | Status | Implementation |
|---------|--------|----------------|
| **Sidebar UI** | ✅ Complete | Territory count, production multiplier |
| **Factory Panel** | ✅ Complete | Build buttons for 6 unit types |
| **Camera Controls** | ✅ Complete | WASD, edge scroll, zoom |
| **Unit Groups** | ✅ Complete | Ctrl+0-9 save, 0-9 load |

---

## Differentiators (Should-Have)

Features that make this recreation faithful to the original:

### Original Z Mechanics

| Feature | Status | Faithfulness |
|---------|--------|--------------|
| **Territory = Production** | ✅ | `1 + (0.15 * territories)` formula |
| **Mid-build capture** | ✅ | Timer continues, no reset |
| **Driver sniping** | ✅ | Area2D hitbox, ejection physics |
| **Neutral capture** | ✅ | Unmanned vehicles instantly claimable |
| **Intelligence tiers** | ✅ | 0-5 scale: Grunt → Commander |
| **Splash damage** | ✅ | Tank explosions, flying turrets |
| **Group targeting** | ✅ | Missile launcher 4+ enemy groups |

### Intelligence-Based AI

| Tier | Unit | Behavior |
|------|------|----------|
| 0 | Grunt | Rush nearest flag only |
| 1 | Psycho | Attack nearest enemy |
| 2 | Tough | Prioritize vehicles |
| 3 | Sniper | Prioritize drivers |
| 4 | Laser | Avoid threats |
| 5 | Commander | Strategic mix |

### Visual Feedback

| Feature | Status | Implementation |
|---------|--------|----------------|
| **Damage states** | ✅ | Smoke → fire → critical (print only) |
| **Flying turrets** | ✅ | Scene spawn on tank death |
| **Driver ejection** | ✅ | Physics-based driver sprite |
| **Selection box** | ✅ | Visual drag selection |

---

## Anti-Features (Explicitly NOT Implementing)

These are intentionally excluded to match original Z:

| Feature | Reason for Exclusion |
|---------|---------------------|
| **Resource gathering** | Original Z had none |
| **Base building** | Original Z had none |
| **Tech trees** | Original Z had none |
| **Fog of war** | Original Z had none |
| **Multiple unit types per production** | One unit per factory |

---

## v2+ Features (Deferred)

### High Priority

| Feature | Complexity | Notes |
|---------|------------|-------|
| **AI Opponent** | High | Real AI logic, difficulty scaling |
| **Sound Effects** | Medium | Gunfire, explosions, voice barks |
| **Sprite Assets** | High | Download from zod_engine |
| **Particle Effects** | Medium | Explosions, smoke |

### Medium Priority

| Feature | Complexity | Notes |
|---------|------------|-------|
| **Multiplayer** | Very High | ENet integration, sync |
| **Campaign Levels 2-20** | Medium | Levels defined, need playtesting |
| **Save/Load** | Low | GameState persistence |
| **Pause Menu** | Low | UI overlay |

### Lower Priority

| Feature | Complexity | Notes |
|---------|------------|-------|
| **Replays** | High | Action recording |
| **Map Editor** | High | Custom level creation |
| **Mod Support** | Medium | JSON-based already |
| **Achievements** | Low | GameState tracking |

---

## Campaign Content

### Current State

| Level Range | Count | Status |
|------------|-------|--------|
| Level 1 | 1 | ✅ Fully playable |
| Levels 2-20 | 19 | ✅ Defined in JSON, not tested |

### Planet Themes (5)

| Planet | Color Scheme | Levels |
|--------|-------------|--------|
| Desert | `#d4a574` / `#b8956e` | 1, 2, 7, 12, 17 |
| Volcanic | `#7a3b2e` / `#4a2020` | 3, 8, 13, 18 |
| Arctic | `#e8f4f8` / `#cde4eb` | 4, 9, 14, 19 |
| Jungle | `#3d6b35` / `#2a4d25` | 5, 10, 15, 20 |
| City | `#555555` / `#333333` | 6, 11, 16 |

### Cutscenes

| Levels | Cutscene |
|--------|----------|
| 1 | Commander Zod intro |
| 5 | Brad & Allan rocket fuel joke |
| 10 | AI getting smarter |
| 15 | Double vision joke |
| 20 | Campaign complete celebration |

---

## Feature Gaps

### Critical Gaps (Blocking)

| Gap | Impact | Recommendation |
|-----|--------|----------------|
| **No sprites** | Units invisible | Download from zod_engine assets |
| **No sounds** | Silent gameplay | Extract from zod_engine sounds |
| **No AI opponent** | Can't play against computer | Implement basic state machine |

### Minor Gaps (Polish)

| Gap | Impact | Recommendation |
|-----|--------|----------------|
| **Voice barks print only** | No audio | AudioStreamPlayer integration |
| **Damage states print only** | No visual change | Sprite frame switching |
| **Planet themes not applied** | Canvas_modulate issue | Fix viewport reference |

---

## Feature Priority Matrix

| Priority | Features | Effort | Impact |
|----------|----------|--------|--------|
| **P0** | Sprites, AI, Sounds | High | Playability |
| **P1** | Particles, Level testing | Medium | Polish |
| **P2** | Multiplayer, Save/Load | Very High | Replayability |
| **P3** | Map Editor, Mod Support | High | Longevity |

---

## Sources

1. `data/units.json` - All 17 unit definitions
2. `data/levels.json` - 20 campaign levels
3. `scripts/core/unit_base.gd` - Intelligence tiers
4. `scripts/core/territory_manager.gd` - Production formula
5. `scripts/units/vehicle_base.gd` - Driver sniping
6. `scripts/game/selection_manager.gd` - Selection system

---

*Generated from feature analysis (2026-04-06)*
