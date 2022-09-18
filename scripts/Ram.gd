extends Area2D

func _ready():
	Stats.ships_destroyed = 0

func _on_Ram_body_entered(body):
	Stats.ships_destroyed += 1
	get_parent().detach(body)
	body.die()
