extends Node2D


# Declare member variables here. Examples:
# var a = 2
export var nrocks = 100

const Rocks = [preload("res://scenes/Rock.tscn")]

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(nrocks):
		var rock = Rocks[i%len(Rocks)].instance()
		rock.position.x = rand_range($Sea.margin_left, $Sea.margin_right)
		rock.position.y = rand_range($Sea.margin_top, $Sea.margin_bottom)
		rock.rotation = rand_range(-PI, PI)
		add_child(rock)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
