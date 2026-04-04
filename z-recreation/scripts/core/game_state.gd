extends Node

# Singleton Game State manager
# Tracks win conditions, player state, global game data

signal game_won(winner: int)
signal game_lost

var player_owner: int = 1 # RED
var game_running: bool = true
var game_time: float = 0.0


func _physics_process(delta: float) -> void:
	if not game_running:
		return
	
	game_time += delta
	
	# Check win conditions
	check_victory_conditions()


func check_victory_conditions() -> void:
	# Check if enemy fort is destroyed
	var enemy_forts = get_tree().get_nodes_in_group("fort")
	for fort in enemy_forts:
		if fort.owner == TerritoryManager.Owner.BLUE and fort.hp <= 0:
			game_won.emit(TerritoryManager.Owner.RED)
			game_running = false
			return
	
	# Check if all enemy units are destroyed
	var enemy_units = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.owner == TerritoryManager.Owner.BLUE and unit.hp > 0
	)
	
	if enemy_units.size() == 0:
		game_won.emit(TerritoryManager.Owner.RED)
		game_running = false


func pause_game() -> void:
	get_tree().paused = true


func resume_game() -> void:
	get_tree().paused = false
