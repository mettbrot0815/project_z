extends Control

# Original Z sidebar UI implementation

@onready var unit_roster: GridContainer = $UnitRoster
@onready var factory_panel: VBoxContainer = $FactoryPanel
@onready var territory_count: Label = $Status/TerritoryCount
@onready var multiplier_label: Label = $Status/ProductionMultiplier

var selected_factory: Node2D = null


func _ready() -> void:
	SelectionManager.selection_changed.connect(_on_selection_changed)
	TerritoryManager.production_multiplier_updated.connect(_on_multiplier_updated)
	update_status()


func _on_selection_changed(selected_units: Array) -> void:
	if selected_units.size() == 1 and selected_units[0].name.begins_with("Factory"):
		selected_factory = selected_units[0]
		factory_panel.visible = true
		update_factory_panel()
	else:
		factory_panel.visible = false
		selected_factory = null


func update_factory_panel() -> void:
	if not selected_factory:
		return
	
	var build_types = ["grunt", "psycho", "tough", "sniper", "jeep", "light_tank"]
	
	for i in factory_panel.get_child_count():
		factory_panel.get_child(i).queue_free()
	
	for unit_type in build_types:
		var btn = Button.new()
		btn.text = unit_type.capitalize()
		btn.pressed.connect(func(type=unit_type): selected_factory.start_production(type))
		factory_panel.add_child(btn)


func update_status() -> void:
	var player_territories = TerritoryManager.get_territory_count(1)  # RED team
	territory_count.text = "Territories: %d" % player_territories
	multiplier_label.text = "Speed: x%.2f" % TerritoryManager.production_multiplier


func _on_multiplier_updated(_multiplier: float) -> void:
	update_status()

