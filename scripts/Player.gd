extends KinematicBody2D

const MAX_SPEED = 500
const ACCELERATION = 30
const DAMPING = 20

var velocity = Vector2(0, -100)
var speed
var clockwise
var distance
var angle
var target

onready var hook = get_parent().get_node("Hook")
onready var hook_sprite = hook.get_node("Sprite")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			hook.reset()
			var global_mouse_position = get_global_mouse_position()
			
			hook_sprite.rotation = position.angle_to_point(global_mouse_position) - 0.5 * PI
			hook.direction = position.direction_to(global_mouse_position)
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
	
	if target != null:
		angle = position.angle_to_point(target)
		
		rotation += angle - previous_angle
	
	if hook.direction == null and !hook.retracting:
		hook_sprite.rotation = position.angle_to_point(get_global_mouse_position()) - 0.5 * PI

func detach(body):
	if !hook.bodies.empty() && hook.bodies[-1] == body:
		hook.clear_bodies()
		hook.retracting = true
		
		target = null
