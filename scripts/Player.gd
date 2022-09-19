extends KinematicBody2D

const MAX_HEALTH = 25
const MAX_SPEED = 1500
const ACCELERATION = 75
const DAMPING = 25

var velocity = Vector2(0, -250)
var speed
var clockwise
var distance
var angle
var target
var bounds
var cheats = false

onready var health = MAX_HEALTH setget set_health
onready var hook = get_parent().get_node("Hook")
onready var hook_rope = hook.get_node("Line2D")
onready var hook_sprite = hook.get_node("Sprite")
onready var low_pass_filter = AudioServer.get_bus_effect(0, 0)

func _ready():
	var sea = get_parent().get_node("Environment/Sea")
	
	bounds = Rect2(sea.rect_position, sea.rect_size * sea.rect_scale)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			hook.reset()
			
			var global_mouse_position = get_global_mouse_position()
			
			hook_sprite.rotation = position.angle_to_point(global_mouse_position) - 0.5 * PI
			hook.direction = position.direction_to(global_mouse_position)
			
			$HookShot.play()
		else:
			hook.clear_bodies()
			hook.retracting = true
			
			target = null

func cheat(delta):
	if Input.is_action_just_pressed("enable_cheats"):
		cheats = true
	if cheats:
		var inp = Vector2(
			int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
			int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		)
		if inp != Vector2(0,0):
			velocity = inp.normalized() * 5000
			# position += delta * inp * 1000
		if Input.is_action_just_pressed("slow"):
			velocity = velocity.normalized() * 200

func _physics_process(delta):
	cheat(delta)
	var previous_angle = angle
	var previous_speed
	
	if target != null:
		speed = min(speed + ACCELERATION * delta, MAX_SPEED)
		angle += speed * clockwise / distance * delta
		
		velocity = (target + Vector2(cos(angle), sin(angle)) * distance - position) / delta
		previous_speed = velocity.length()
	else:
		velocity = velocity.limit_length(max(velocity.length() - DAMPING * delta, 0))
	
	velocity = move_and_slide(velocity)
	
	$Camera2D.target_zoom = velocity.length() / MAX_SPEED
	
	if target != null:
		speed *= previous_speed / velocity.length()
		angle = position.angle_to_point(target)
		
		rotation += angle - previous_angle
	elif $DieTimer.is_stopped() and (position.x < bounds.position.x or position.y < bounds.position.y or position.x >= bounds.end.x or position.y >= bounds.end.y):
		var tween = get_tree().create_tween().set_parallel()
		
		tween.tween_property(self, "scale", Vector2.ZERO, 3)
		tween.tween_property(hook, "scale", Vector2.ZERO, 3)
		
		die()
	
	if hook.direction == null and !hook.retracting:
		hook_sprite.rotation = position.angle_to_point(get_global_mouse_position()) - 0.5 * PI
		
		$Harpoon.global_rotation = hook_sprite.rotation
	else:
		$Harpoon.global_rotation = hook_rope.points[0].angle_to_point(hook_rope.points[1]) - 0.5 * PI
	
	self.health = min(self.health + delta, MAX_HEALTH)

func detach(body):
	if !hook.bodies.empty() and hook.bodies[-1] == body:
		hook.clear_bodies()
		hook.retracting = true
		
		target = null

func set_health(new_value):
	if new_value > 0:
		low_pass_filter.cutoff_hz = 250 + (new_value / MAX_HEALTH) * 4000
		
		AudioServer.set_bus_effect_enabled(0, 0, new_value < MAX_HEALTH / 2.0)
	elif health > 0:
		if cheats:
			return
		AudioServer.set_bus_effect_enabled(0, 0, false)
		
		var wreck = preload("res://scenes/Wreck.tscn").instance()
		
		wreck.transform = transform
		wreck.get_node("Ship").visible = false
		
		get_parent().add_child(wreck)
		
		set_physics_process(false)
		
		hook.clear_bodies()
		hook.visible = false
		
		visible = false
		
		die()
	
	health = new_value

func die():
	set_process_unhandled_input(false)
	
	$Shape.set_deferred("disabled", true)
	$Ram.set_deferred("monitoring", false)
	
	$DieTimer.start()

func _on_DieTimer_timeout():
	get_tree().change_scene_to(load("res://scenes/Menu.tscn"))
