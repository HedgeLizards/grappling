extends Area2D

export var speed = 400
export var distance = 1600


func _physics_process(delta):
	move_local_y(-speed * delta)
	distance -= speed * delta
	if distance < 0:
		queue_free()



func _on_Bullet_body_entered(body):
	get_parent().get_node("Player").detach(self)
	queue_free()
