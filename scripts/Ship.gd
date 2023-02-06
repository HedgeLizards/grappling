extends KinematicBody2D


var speed = 250; # Changed this from 160 to 250.
var drot = 0.3;
var hunting = true;
var hunt_rotation = 1.5 # Changed this from .7 to 1.5. - Milan
var hunt_aim = 0.1
var shoot_range = 800
var shoot_cooldown = 0
var max_cooldown = .5 # Changed this from 1 to .5. - Milan

const Shot = preload("res://scenes/Shot.tscn")
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
	ai()
	shoot_cooldown -= delta
	if Input.is_action_just_pressed("hunt"):
		hunting = true
	if Input.is_action_just_pressed("idle"):
		hunting = false
	rotation += drot * delta 
	move_and_slide(Vector2(0, -speed).rotated(rotation))

func turn_towards(angle, accuracy):
	if rad_gt(angle, accuracy):
		return 1
	elif rad_lt(angle, -accuracy):
		return -1
	else:
		return 0

func shoot(angle):
	
	#for i in range(-1, 2):
	var shot = Shot.instance()
	shot.rotation = angle
	if rad_gt(angle, 0):
		$GunBarrelRight.add_child(shot)
	else:
		$GunBarrelLeft.add_child(shot)
	$Cannon.play()

func _on_AITime_timeout():
	pass
	
func ai():
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
			if abs(rad_sub(desired_angle, player_dir)) < 0.2 and shoot_cooldown <= 0:
				shoot(desired_angle)
				shoot_cooldown = max_cooldown
		else:
			drot = turn_towards(player_dir, hunt_aim) * hunt_rotation
	else:
		drot = 0#rand_range(-0.3, 0.3)
		shoot(PI/2)

func die():
	var wreck = Wreck.instance()
	wreck.transform = transform
	get_parent().add_child(wreck)
	queue_free()
