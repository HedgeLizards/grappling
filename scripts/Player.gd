extends KinematicBody2D

var speed = 100;



func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var control = int(Input.is_action_pressed('right')) - int(Input.is_action_pressed('left'))
	rotation += control * delta * PI
	if !Input.is_action_pressed("backwards"):
		move_local_y(-delta * speed)
