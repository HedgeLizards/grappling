extends Node2D



const Bullet = preload("res://scenes/Bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Explosion.play("default")
	var bullet = Bullet.instance()
	bullet.global_transform = global_transform
	get_node("/root/Main").add_child(bullet)


func _on_Explosion_animation_finished():
	$Explosion.stop()
	queue_free()
