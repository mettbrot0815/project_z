# Contributing to Z

Thank you for your interest in contributing to this recreation of the classic 1996 RTS game!

## Before You Begin

### Code of Conduct
- Be respectful to all contributors
- Focus on improving the game experience
- Credit original creators (The Bitmap Brothers)

### Project Goals
- Faithful recreation of original gameplay
- Modern code quality and architecture
- Cross-platform compatibility
- No resource grinding - pure territory conquest

## How to Contribute

### Reporting Bugs
1. Check if issue already exists
2. Describe steps to reproduce
3. Include console output if applicable
4. Mention which level/feature

### Feature Requests
1. Submit as GitHub issue
2. Explain why it improves core experience
3. Consider implementation complexity
4. Don't request: resource systems, base building

### Pull Requests
1. Fork the repository
2. Create feature branch (`feature/add-cool-feature`)
3. Make focused changes
4. Write tests if applicable
5. Update documentation
6. Submit PR with clear description

## Code Style

### Godot 4.x Best Practices
```gdscript
# Use type hints
extends Node2D
class_name Unit

# Export only needed values
@export var health: int = 100

# Use signals for events
signal unit_died()

# Clear comments, keep them brief
func take_damage(amount: int) -> bool:
	health -= amount
	if health <= 0:
		die()
		return true
	return false
```

### File Organization
```
scripts/
├── autoloads/          # Singletons
├── entities/           # Game objects
├── ui/                 # UI scripts
└── input/              # Input handlers
```

### Commit Messages
Use conventional commits:
```
feat: add sniper unit type
fix: correct production multiplier calculation
docs: update README with new features
test: add unit tests for capture logic
```

## Development Setup

### Prerequisites
- Godot Engine 4.3+
- Git
- Code editor (VS Code recommended)

### Setup
```bash
git clone <repository>
cd project_z
godot --path . --run "res://scenes/Main.tscn"
```

### Build Setup
```bash
# Install Godot
# See godotengine.org for installation

# Export game
godot --export "Windows Desktop" project_z/

# Or use export templates
godot4 --export-debug "Windows Desktop" project_z/
```

## Architecture Overview

### Core Systems
- **GameManager**: Game state, win conditions
- **SectorManager**: Territory capture, production
- **Unit**: Base class for all units
- **AIController**: Enemy AI behaviors
- **InputHandler**: Player input

### Data Flow
```
Player Input → InputHandler → Commands → Units
Units → AIController → Autonomous Actions
Sectors → SectorManager → Production Multiplier
Game State → GameManager → Win Conditions
```

## Testing

### Manual Testing
- Play through all 20 levels
- Test each unit type
- Verify AI behaviors
- Check multiplayer (if implemented)

### Automated Testing
```gdscript
# Example test structure
extends Node

class_name TestSuite

func _ready() -> void:
	run_tests()

func run_tests() -> void:
	test_capture_logic()
	test_production_multiplier()
	test_unit_damage()
```

## Performance Guidelines

### Target Metrics
- 60 FPS minimum
- < 16ms frame time
- Smooth unit movement
- Responsive input

### Optimization Tips
- Use object pooling for particles
- Batch sprite rendering
- Limit active units
- Optimize pathfinding

## Design Philosophy

### What to Implement
- Faithful recreation of original mechanics
- Quality-of-life improvements
- Bug fixes
- Performance optimizations

### What NOT to Implement
- Resource gathering systems
- Base building
- Technology trees
- Economic systems
- Anything that changes core loop

### Core Loop Must Remain
1. Start with fort + units
2. Capture territories
3. Produce units faster
4. Destroy enemy fort or eliminate units

## Known Issues

### Current Limitations
- Placeholder graphics
- Simplified AI pathfinding
- Limited vehicle mechanics
- No sound effects

### Planned Improvements
- Complete sprite art
- Original soundtrack
- Cutscenes
- Replay system
- Level editor

## Questions?

### Get Help
- Open GitHub issue
- Join Discord community
- Check existing documentation
- Review code comments

### Ask For Clarification
- Be specific about feature
- Explain use case
- Mention target platform
- Consider user experience

## Acknowledgments

- The Bitmap Brothers for the original Z
- Zod Engine for open-source inspiration
- Godot Engine for development platform
- All RTS game fans

## License

This project follows the original project license. See LICENSE file.

---

**Remember: We're preserving a classic, not reinventing it!**
