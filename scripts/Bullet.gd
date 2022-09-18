extends Area2D

const DAMAGE = 6

export var speed = 400
export var distance = 1600

onready var player = get_parent().get_node("Player")

func _physics_process(delta):
	move_local_y(-speed * delta)
	distance -= speed * delta
	if distance < 0:
		queue_free()



func _on_Bullet_body_entered(body):
	if body == player:
		player.health -= DAMAGE
		player.detach(self)
		queue_free()
