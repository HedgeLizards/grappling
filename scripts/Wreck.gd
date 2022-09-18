extends Node2D

func _ready():
	$Explosion.play("default")


func _on_AnimatedSprite_animation_finished():
	$Explosion.stop()
	$Explosion.visible = false
	pass


func _on_Explosion_frame_changed():
	if $Explosion.frame == 6:
		$Ship.visible = false
		$Rubble.visible = true
