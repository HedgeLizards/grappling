extends VBoxContainer

func _ready():
	if Stats.ships_destroyed != null:
		AudioServer.set_bus_effect_enabled(0, 0, false)
		
		$Label.align = ALIGN_CENTER
		$Label.text = "You destroyed %d ship%s!" % [Stats.ships_destroyed, "" if Stats.ships_destroyed == 1 else "s"]
		
		$Button.text = "Retry"

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.pressed:
		get_tree().change_scene_to(preload("res://scenes/Main.tscn"))
