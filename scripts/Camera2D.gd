extends Camera2D

const SHAKE_DURATION = 0.5
const SHAKE_INTENSITY = 60
const MIN_ZOOM = 1.4
const MAX_ZOOM = 4.4
const ZOOM_SPEED = 5

var duration = 0

onready var target_zoom = zoom setget set_target_zoom

func shake():
	duration = SHAKE_DURATION

func _process(delta):
	if duration > 0:
		duration = max(duration - delta, 0)
		
		offset = Vector2(randf(), randf()) * SHAKE_INTENSITY * (duration / SHAKE_DURATION)
	
	zoom += (target_zoom - zoom).limit_length(ZOOM_SPEED * delta)

func set_target_zoom(ratio):
	target_zoom = Vector2.ONE * (MIN_ZOOM + (MAX_ZOOM - MIN_ZOOM) * ratio)
