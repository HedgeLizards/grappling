extends Area2D

const DAMAGE = 7

export var speed = 800
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
