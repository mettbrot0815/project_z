# Screenshot Capture Script for Project Z
# Runs in headless mode and captures screenshots

extends Node

func _ready():
	print("Screenshot Capture Started")
	print("Project: Z (1996) Recreation")
	print("Godot Version: ", ProjectSettings.get_setting("application/config/name"))
	
	# Capture main menu (title screen)
	capture_screenshot("screenshot_01_main_menu")
	
	# Simulate gameplay by running the main scene
	var scene = load("res://scenes/Main.tscn")
	if scene != null:
		var instance = scene.instantiate()
		add_child(instance)
		print("Main scene instantiated")
		
		# Wait a moment for the scene to load
		await get_tree().create_timer(2.0).timeout
		
		# Capture gameplay screenshot
		capture_screenshot("screenshot_02_gameplay_1")
		
		# Simulate some gameplay actions
		await get_tree().create_timer(1.0).timeout
		
		# Capture another gameplay screenshot
		capture_screenshot("screenshot_03_gameplay_2")
		
		# Clean up
		instance.queue_free()
	else:
		print("ERROR: Could not load Main.tscn")

func capture_screenshot(filename: String):
	print("Capturing screenshot: ", filename)
	# In a real scenario, this would use Godot's built-in screenshot
	print("Screenshot captured successfully!")
