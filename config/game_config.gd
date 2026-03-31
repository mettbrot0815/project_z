extends Node

# Game Configuration - Central configuration for all game settings
# This file controls all game-wide settings

# Game settings
@export_group("General")
var game_name: String = "Z"
var version: String = "0.1.0"
var developer: String = "Bitmap Brothers Tribute"

@export_group("Performance")
var target_fps: int = 60
var unit_limit: int = 200
var max_particles: int = 100
var quality_level: String = "high"  # "low", "medium", "high"

@export_group("Gameplay")
var god_mode: bool = false
var infinite_ammo: bool = false
var slow_motion: float = 1.0
var god_mode_team: int = 0  # 0 = off, 1 = red, 2 = blue, 3 = all

@export_group("Audio")
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.7
var music_enabled: bool = true
var sfx_enabled: bool = true

@export_group("Visual")
var screen_shake: float = 0.3
var bloom_enabled: bool = true
var anti_aliasing: int = 4
var shadow_quality: String = "high"

@export_group("AI")
var ai_enabled: bool = true
var ai_difficulty: String = "normal"  # "easy", "normal", "hard"
var ai_reaction_time: float = 1.0
var ai_pathfinding: String = "a_star"  # "a_star", "bfs", "simple"

@export_group("Network")
var server_ip: String = ""
var server_port: int = 7777
var max_players: int = 4
var tick_rate: int = 30

@export_group("Input")
var mouse_sensitivity: float = 1.0
var camera_smooth: bool = true
var camera_zoom_speed: float = 2.0
var camera_min_zoom: float = 0.5
var camera_max_zoom: float = 2.0

# Runtime configuration
var config_hash: String = ""
var last_modified: Time = Time.get_ticks_fsys()

func _ready() -> void:
	print("[Config] Configuration loaded")
	_load_from_file()

func _load_from_file() -> void:
	# Would load from config file
	# For now, use default values
	pass

# Helper functions
func get_player_team() -> int:
	return 1  # Red team is player

func get_enemy_team() -> int:
	return 2  # Blue team is enemy

func is_slow_motion_active() -> bool:
	return slow_motion != 1.0

func apply_slow_motion(delta: float) -> float:
	return delta * slow_motion

func is_god_mode_active() -> bool:
	return god_mode or god_mode_team != 0

func apply_god_mode(unit: Unit) -> bool:
	if not is_god_mode_active():
		return false
	return god_mode_team == 3 or god_mode_team == unit.team

func get_quality_multiplier() -> float:
	match quality_level:
		"low":
			return 0.5
		"medium":
			return 1.0
		"high":
			return 1.5
	return 1.0

# Configuration management
func save_config() -> bool:
	# Would save to file
	return true

func reset_to_defaults() -> void:
	# Reset all values to defaults
	god_mode = false
	infinite_ammo = false
	slow_motion = 1.0
	master_volume = 1.0
	music_volume = 0.8
	sfx_volume = 0.7
	ai_difficulty = "normal"

# Utility functions
func toggle_god_mode() -> void:
	god_mode = not god_mode
	print("[Config] God mode:", god_mode)

func toggle_slow_motion(factor: float) -> void:
	slow_motion = factor
	print("[Config] Slow motion:", factor)

func set_difficulty(difficulty: String) -> void:
	ai_difficulty = difficulty
	print("[Config] Difficulty set to:", difficulty)

func get_difficulty_multiplier() -> float:
	match ai_difficulty:
		"easy":
			return 0.5
		"normal":
			return 1.0
		"hard":
			return 1.5
	return 1.0
