extends Area2D

const DAMAGE = 20 # I changed this value from 7 to 20. - Milan

export var speed = 1500 # I changed this value from 800 to 1500. - Milan
export var distance = 3200

var impact_sound = 1

onready var player = get_parent().get_node("Player")

func _physics_process(delta):
	move_local_y(-speed * delta)
	distance -= speed * delta
	if distance < 0:
		queue_free()

func _on_Bullet_body_entered(body):
	if body == player:
		player.health -= DAMAGE
		player.get_node("Camera2D").shake(20)
		player.detach(self)
		get_node("CannonImpact%d" % impact_sound).play()
		impact_sound = 2 if impact_sound == 1 else 1
		set_deferred("monitoring", false)
		set_physics_process(false)
		visible = false
	else:
		queue_free()

func _on_CannonImpact_finished():
	queue_free()
