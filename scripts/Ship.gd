extends KinematicBody2D


var speed = 80;
var drot = 0.3;
var hunting = true;
var hunt_rotation = 0.4
var hunt_aim = 0.3
var shoot_range = 400
var shoot_cooldown = 0

const Bullet = preload("res://scenes/Bullet.tscn")


func rad_gt(a, b):
	var d = fposmod(a - b, 2*PI)
	return d < PI

func rad_lt(a, b):
	return rad_gt(b, a)

func rad_sub(a, b):
	var d = fposmod(a - b, 2*PI)
	if d > PI:
		d -= 2 * PI
	return d

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	shoot_cooldown -= delta
	if Input.is_action_just_pressed("hunt"):
		hunting = true
	if Input.is_action_just_pressed("idle"):
		hunting = false
	rotation += drot * delta 
	move_local_y(-delta * speed)

func turn_towards(angle, accuracy):
	if rad_gt(angle, accuracy):
		return 1
	elif rad_lt(angle, -accuracy):
		return -1
	else:
		return 0

func shoot(angle):
	
	#for i in range(-1, 2):
	var bullet = Bullet.instance()
	bullet.global_transform = global_transform
	bullet.rotation += angle
	get_node("/root/Main").add_child(bullet)

func _on_AITime_timeout():
	if hunting:
		var player_pos = get_node("/root/Main/Player").position
		#var player_dir = rel_player_pos.y / rel_player_pos.x
		var player_dir = get_angle_to(player_pos) + PI / 2
		
		if position.distance_to(player_pos) < shoot_range:
			var desired_angle = PI / 2
			if rad_lt(player_dir, 0):
				desired_angle *= -1
			drot = turn_towards(player_dir - desired_angle, hunt_aim) * hunt_rotation
			if abs(rad_sub(desired_angle, player_dir)) < 0.2 and shoot_cooldown <= 0:
				shoot(player_dir)
				shoot_cooldown = 2
		else:
			drot = turn_towards(player_dir, hunt_aim) * hunt_rotation
	else:
		drot = rand_range(-0.3, 0.3)
