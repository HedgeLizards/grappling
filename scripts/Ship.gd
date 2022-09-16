extends KinematicBody2D


var speed = 80;
var drot = 0.3;
var hunting = false;
var hunt_rotation = 0.4
var hunt_aim = 0.3
var shoot_range = 400


func rad_gt(a, b):
	var d = fposmod(a - b, 2*PI)
	return d < PI

func rad_lt(a, b):
	return rad_gt(b, a)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if Input.is_action_just_pressed("hunt"):
		hunting = true
	if Input.is_action_just_pressed("idle"):
		hunting = false
	rotation += drot * delta 
	move_local_y(-delta * speed)


func _on_AITime_timeout():
	if hunting:
		var player_pos = get_node("/root/Main/Player").position
		#var player_dir = rel_player_pos.y / rel_player_pos.x
		var player_dir = get_angle_to(player_pos) + PI / 2
		#while player_dir > PI:
			#player_dir -= 2 * PI
		#while player_dir < -PI:
			#player_dir += 2*PI 
		
		if false and position.direction_to(player_pos) < shoot_range:
			pass
		else:
			if rad_gt(player_dir, hunt_aim):
				drot = hunt_rotation
			elif rad_lt(player_dir, -hunt_aim):
				drot = -hunt_rotation
			else:
				drot = 0
	else:
		drot = rand_range(-0.3, 0.3)
