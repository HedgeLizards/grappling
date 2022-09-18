extends KinematicBody2D

const MAX_HEALTH = 25
const MAX_SPEED = 1500
const ACCELERATION = 60
const DAMPING = 30

var velocity = Vector2(0, -250)
var speed
var clockwise
var distance
var angle
var target

onready var health = MAX_HEALTH setget set_health
onready var hook = get_parent().get_node("Hook")
onready var hook_rope = hook.get_node("Line2D")
onready var hook_sprite = hook.get_node("Sprite")
onready var low_pass_filter = AudioServer.get_bus_effect(0, 0)

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

func _physics_process(delta):
	var previous_angle = angle
	
	if target != null:
		speed = min(speed + ACCELERATION * delta, MAX_SPEED)
		angle += speed * clockwise / distance * delta
		
		velocity = (target + Vector2(cos(angle), sin(angle)) * distance - position) / delta
	else:
		velocity = velocity.limit_length(max(velocity.length() - DAMPING * delta, 0))
	
	velocity = move_and_slide(velocity)
	
	$Camera2D.target_zoom = velocity.length() / MAX_SPEED
	
	if target != null:
		angle = position.angle_to_point(target)
		
		rotation += angle - previous_angle
	
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
		AudioServer.set_bus_effect_enabled(0, 0, false)
		
		var wreck = preload("res://scenes/Wreck.tscn").instance()
		
		wreck.transform = transform
		
		get_parent().add_child(wreck)
		
		set_process_unhandled_input(false)
		set_physics_process(false)
		
		visible = false
		
		hook.visible = false
		
		$DieTimer.start()
	
	health = new_value

func _on_DieTimer_timeout():
	get_tree().change_scene_to(load("res://scenes/Menu.tscn"))
