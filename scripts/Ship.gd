extends KinematicBody2D


var speed = 80;
var drot = 0.3;
var hunting = true;
var hunt_rotation = 0.7
var hunt_aim = 0.1
var shoot_range = 400
var shoot_cooldown = 0

const Bullet = preload("res://scenes/Bullet.tscn")
const Wreck = preload("res://scenes/Wreck.tscn")

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

func rad_abs(a):
	var d = fposmod(a, 2*PI)
	return min(a, 2*PI - a)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AITime.wait_time = randf() * 0.5


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
	$Cannon.play()

func _on_AITime_timeout():
	var possible_dangers = $DangerZone.get_overlapping_bodies()
	var balance = 0
	for body in possible_dangers:
		if body.position == position:
			continue
		#var local_pos = to_local(body.position)
		var db = 100/position.distance_to(body.position)
		if rad_gt(get_angle_to(body.position)-PI/2, 0):
			balance += db
		else:
			balance -= db
	if balance > 0:
		drot = hunt_rotation
		return
	elif balance < 0:
		drot = -hunt_rotation
		return
	if hunting:
		var player_pos = get_node("/root/Main/Player").position
		#var player_dir = rel_player_pos.y / rel_player_pos.x
		var player_dir = get_angle_to(player_pos) + PI / 2
		
		if position.distance_to(player_pos) < shoot_range:
			var desired_angle = PI / 2
			if rad_lt(player_dir, 0):
				desired_angle *= -1
			drot = turn_towards(player_dir - desired_angle, hunt_aim) * hunt_rotation
			if abs(rad_sub(desired_angle, player_dir)) < 0.1 and shoot_cooldown <= 0:
				shoot(desired_angle)
				shoot_cooldown = 2
		else:
			drot = turn_towards(player_dir, hunt_aim) * hunt_rotation
	else:
		drot = 0#rand_range(-0.3, 0.3)

func die():
	var wreck = Wreck.instance()
	wreck.transform = transform
	get_parent().add_child(wreck)
	queue_free()
