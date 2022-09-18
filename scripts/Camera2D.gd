extends Camera2D

const SHAKE_DURATION = 0.25
const SHAKE_INTENSITY = 3
const MIN_ZOOM = 0.75
const MAX_ZOOM = 1.5
const ZOOM_SPEED = 3

var duration = 0

onready var target_zoom = zoom setget set_target_zoom

func shake():
	duration = SHAKE_DURATION

func _process(delta):
	if duration > 0:
		duration = max(delta - duration, 0)
		
		offset = Vector2(randf(), randf()) * SHAKE_INTENSITY * (duration / SHAKE_DURATION)
	
	zoom += (target_zoom - zoom).limit_length(ZOOM_SPEED * delta)

func set_target_zoom(ratio):
	target_zoom = Vector2.ONE * (MIN_ZOOM + (MAX_ZOOM - MIN_ZOOM) * ratio)
