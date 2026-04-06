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
	var enemy_forts = get_tree().get_nodes_in_group("fort").filter(func(fort):
		return fort.get_team_id() == TerritoryManager.Owner.BLUE
	)

	for fort in enemy_forts:
		if fort.hp <= 0:
			game_won.emit(TerritoryManager.Owner.RED)
			game_running = false
			return

	# Check if all enemy units are destroyed
	var enemy_units = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.get_team_id() == TerritoryManager.Owner.BLUE and unit.hp > 0
	)

	if enemy_units.size() == 0:
		game_won.emit(TerritoryManager.Owner.RED)
		game_running = false
		return

	# Check player fort destruction (loss condition)
	var player_forts = get_tree().get_nodes_in_group("fort").filter(func(fort):
		return fort.get_team_id() == TerritoryManager.Owner.RED
	)

	for fort in player_forts:
		if fort.hp <= 0:
			game_lost.emit()
			game_running = false
			return


func pause_game() -> void:
	get_tree().paused = true


func resume_game() -> void:
	get_tree().paused = false

