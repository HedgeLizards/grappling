extends Area2D

func _on_Ram_body_entered(body):
	get_parent().detach(body)
	body.die()
