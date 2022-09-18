extends Camera2D

const SHAKE_DURATION = 0.25
const SHAKE_INTENSITY = 3

var duration

func _ready():
	set_process(false)

func shake():
	set_process(true)
	
	duration = SHAKE_DURATION

func _process(delta):
	duration -= delta
	
	if duration <= 0:
		set_process(false)
	
	offset = Vector2(randf(), randf()) * SHAKE_INTENSITY
