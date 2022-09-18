extends VBoxContainer

func _on_Button_pressed():
	get_tree().change_scene_to(preload("res://scenes/Main.tscn"))
