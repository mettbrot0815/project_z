# Phase 2: Visual Assets - Context

**Gathered:** 2026-04-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Add sprite assets so units are visible and game is playable. Uses original Z (1996) assets from zod_engine repository. This phase covers visual assets only — audio is Phase 4.

</domain>

<decisions>
## Implementation Decisions

### Asset Source
- **Use zod_engine repository** — https://github.com/a-sf-mirror/zod_engine
- Contains complete original Z (1996) pixel art assets
- Assets already organized: units/robots, units/vehicles, units/cannons, buildings, teams

### Unit Sprites to Import
- **Robots:** grunt, psycho, tough, sniper, laser, commander (in assets/units/robots/)
- **Vehicles:** jeep, light_tank, medium_tank, heavy_tank, apc, crane, missile_launcher, howitzer, gatling
- **Animation frames:** Each unit has multiple animation frames (n00-n09) per team color

### Team Color Handling
- **Red team:** *_red_*.png files
- **Blue team:** *_blue_*.png files  
- **Green team:** *_green_*.png files
- **Yellow team:** *_yellow_*.png files
- Implementation: Swap sprite texture based on unit.team

### Damage State Visualization
- Frame switching based on HP percentage
- 0-30% HP: smoking (frame changes)
- 30-60% HP: light damage visible
- 60-90% HP: moderate damage
- 90-100% HP: clean/pristine

### Building Assets
- Flags: 4 team colors
- Factories: factory_robot, factory_vehicle
- Forts/defenses

### Claude's Discretion
- Sprite pivot point positioning (center of mass for each unit type)
- Animation frame timing (original Z used ~10 FPS)
- Import format: convert PNG to Godot-compatible texture

</decisions>

<specifics>
## Specific Ideas

- Reference: zod_engine/assets/units/robots/ contains animation frames like `grunt_blue_n00.png` through `grunt_blue_n09.png`
- Reference: zod_engine/assets/units/vehicles/ has tank and vehicle sprites
- Reference: zod_engine/assets/buildings/ has factory and flag sprites
- Goal: Faithful recreation of original Z visual style (1996 pixel art)

</specifics>

<deferred>
## Deferred Ideas

- Sound effects — Phase 4 (Audio & Polish)
- Voice barks — Phase 4
- Particle effects — Phase 4

</deferred>

---

*Phase: 02-visual-assets*
*Context gathered: 2026-04-06*