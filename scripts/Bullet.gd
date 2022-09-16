extends Area2D

export var speed = 400
export var distance = 1600


func _physics_process(delta):
	move_local_y(-speed * delta)
	distance -= speed * delta
	if distance < 0:
		queue_free()



func _on_Bullet_body_entered(body):
	if body.has_method("is_enemy") and body.is_enemy():
		body.health -= 5
		if body.health <= 0:
			body.die(self.global_rotation)
	queue_free()

func daychange(is_night):
	queue_free()
