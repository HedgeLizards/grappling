extends Area2D


func _on_Ram_body_entered(body):
	if body == get_parent():
		return
	if body.has_method("die"):
		body.die()
