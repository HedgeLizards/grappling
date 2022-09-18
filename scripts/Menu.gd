extends VBoxContainer

func _ready():
	if Stats.ships_destroyed != null:
		$Label.align = ALIGN_CENTER
		$Label.text = "You destroyed %d ships!" % Stats.ships_destroyed
		$Button.text = "Retry"

func _on_Button_pressed():
	get_tree().change_scene_to(preload("res://scenes/Main.tscn"))
