# ROADMAP.md - Z (1996) Recreation

**Project:** Z (1996) Recreation in Godot 4.6  
**Created:** 2026-04-06  
**Depth:** Standard (5-8 phases)

---

## Phases

- [x] **Phase 1: Critical Fixes & Foundation** - Fix missing vehicle factory, refactor duplicate code (completed 2026-04-06)
- [ ] **Phase 2: Visual Assets** - Add sprite assets for units and buildings
- [ ] **Phase 3: AI Opponent** - Implement computer opponent with difficulty levels
- [ ] **Phase 4: Audio & Polish** - Add sounds, voice barks, particle effects
- [ ] **Phase 5: Testing & Polish** - Test all 20 levels, performance optimization

---

## Phase Details

### Phase 1: Critical Fixes & Foundation

**Goal:** Fix blocking bugs and refactor tech debt to enable gameplay

**Depends on:** Nothing (first phase)

**Requirements:** 
- CONC-01: Create missing `factory_vehicle.tscn` scene
- CONC-02: Refactor duplicate `find_nearest_enemy()` to UnitBase
- CONC-03: Remove or conditionally disable debug prints
- CONC-04: Move hardcoded magic numbers to constants

**Success Criteria** (what must be TRUE):
1. All 20 campaign levels load without crashing (no null scene errors)
2. Level 2+ vehicle factories spawn correct vehicle types
3. UnitBase contains shared `find_nearest_enemy()` method used by all units
4. Console output is clean during normal gameplay (no debug spam)

**Plans:** 1/1 plans complete

---

### Phase 2: Visual Assets

**Goal:** Add sprite assets so units are visible and game is playable

**Depends on:** Phase 1 (foundation for testing)

**Requirements:**
- ASSET-01: Download/create unit sprites for all 17 types
- ASSET-02: Download/create building sprites (flags, factories, forts)
- ASSET-03: Implement damage state visual feedback (sprite frame switching)
- ASSET-04: Set correct sprite pivot points and animations

**Success Criteria** (what must be TRUE):
1. All unit types display visible sprites in-game
2. Buildings (flags, factories, forts) display correctly
3. Vehicles show damage states (smoke → fire → critical) visually
4. Sprite animations match game tick rate

**Plans:** TBD

---

### Phase 3: AI Opponent

**Goal:** Implement computer opponent so game is playable against AI

**Depends on:** Phase 2 (needs visual feedback for testing)

**Requirements:**
- AI-01: Implement basic AI state machine (idle, attack, defend, capture)
- AI-02: Add AI difficulty levels (easy, medium, hard)
- AI-03: Implement AI production logic (territory-based unit mix)
- AI-04: Implement AI unit behavior (intelligence tier execution)
- AI-05: Add AI information gathering (map vision, not cheating)

**Success Criteria** (what must be TRUE):
1. Player can select AI as opponent in game setup
2. AI captures flags and expands territory
3. AI produces units appropriate to owned territories
4. AI attacks player with appropriate force
5. AI difficulty feels distinct (Easy = passive, Hard = aggressive)

**Plans:** TBD

---

### Phase 4: Audio & Polish

**Goal:** Add sound effects and polish for immersive gameplay

**Depends on:** Phase 3 (AI testing requires feedback)

**Requirements:**
- AUDIO-01: Add gunshot sound effects
- AUDIO-02: Add explosion sound effects
- AUDIO-03: Add voice barks for unit actions
- AUDIO-04: Add ambient/background music
- POLISH-01: Add particle effects for explosions
- POLISH-02: Add particle effects for smoke/damage

**Success Criteria** (what must be TRUE):
1. Units make sound when firing
2. Explosions produce sound and particles
3. Units play voice barks when moving/attacking/dying
4. Background music plays during gameplay
5. Player can adjust volume levels

**Plans:** TBD

---

### Phase 5: Testing & Polish

**Goal:** Verify all game systems work, fix bugs, optimize performance

**Depends on:** Phase 4 (complete game loop ready for testing)

**Requirements:**
- TEST-01: Test all 20 campaign levels for playability
- TEST-02: Verify victory/defeat conditions work correctly
- TEST-03: Test edge cases (simultaneous capture, unit wipe, etc.)
- PERF-01: Optimize projectile collision (object pooling)
- PERF-02: Cache enemy unit queries (avoid per-frame tree traversal)
- PERF-03: Limit flying turret instances

**Success Criteria** (what must be TRUE):
1. All 20 levels are completable (player can win)
2. All 20 levels are losable (AI can win)
3. No crashes or hangs during normal gameplay
4. Performance stays above 30 FPS with 50+ units
5. Game saves progress between levels

**Plans:** TBD

---

## Coverage

| Requirement | Phase | Status |
|-------------|-------|--------|
| CONC-01: factory_vehicle.tscn | Phase 1 | Pending |
| CONC-02: find_nearest_enemy refactor | Phase 1 | Pending |
| CONC-03: Remove debug prints | Phase 1 | Pending |
| CONC-04: Magic numbers to constants | Phase 1 | Pending |
| ASSET-01: Unit sprites | Phase 2 | Pending |
| ASSET-02: Building sprites | Phase 2 | Pending |
| ASSET-03: Damage visuals | Phase 2 | Pending |
| ASSET-04: Animation setup | Phase 2 | Pending |
| AI-01: Basic AI state machine | Phase 3 | Pending |
| AI-02: Difficulty levels | Phase 3 | Pending |
| AI-03: Production logic | Phase 3 | Pending |
| AI-04: Unit behavior | Phase 3 | Pending |
| AI-05: Information gathering | Phase 3 | Pending |
| AUDIO-01: Gunshot sounds | Phase 4 | Pending |
| AUDIO-02: Explosion sounds | Phase 4 | Pending |
| AUDIO-03: Voice barks | Phase 4 | Pending |
| AUDIO-04: Background music | Phase 4 | Pending |
| POLISH-01: Explosion particles | Phase 4 | Pending |
| POLISH-02: Damage particles | Phase 4 | Pending |
| TEST-01: Level testing | Phase 5 | Pending |
| TEST-02: Victory conditions | Phase 5 | Pending |
| TEST-03: Edge cases | Phase 5 | Pending |
| PERF-01: Projectile pooling | Phase 5 | Pending |
| PERF-02: Query caching | Phase 5 | Pending |
| PERF-03: Turret limits | Phase 5 | Pending |

**Mapped:** 25/25 requirements ✓

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Critical Fixes | 0/1 | Complete    | 2026-04-06 |
| 2. Visual Assets | 0/1 | Not started | - |
| 3. AI Opponent | 0/1 | Not started | - |
| 4. Audio & Polish | 0/1 | Not started | - |
| 5. Testing & Polish | 0/1 | Not started | - |

---

## Research References

### From STACK.md
- Godot 4.6 with NavigationServer2D
- TileMapLayer (not TileMap)
- JSON for data, GDScript for logic

### From FEATURES.md
- P0 features: Sprites, AI, Sounds (blocking)
- 17 unit types, 20 campaign levels
- Original Z mechanics preserved

### From CONCERNS.md
- Critical: Missing factory_vehicle.tscn (crashes levels 2-20)
- Tech debt: Duplicate find_nearest_enemy(), debug prints

### From PITFALLS.md
- CharacterBody2D `owner` conflict (already fixed)
- TileMap → TileMapLayer (already fixed)
- Canvas_modulate access (planet themes)

---

## Dependencies

```
Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4 ──► Phase 5
  │            │            │            │           │
  │            │            │            │           │
 └─ Blocks    └─ Needs     └─ Needs     └─ Needs    └─ Complete
   levels      visuals      visual      audio       game
   2-20        for AI       feedback    feedback    testing
              testing      for AI                   and
                           testing                   polish
```

---

*Generated: 2026-04-06*
