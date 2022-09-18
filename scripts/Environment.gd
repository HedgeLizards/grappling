extends Node2D


# Declare member variables here. Examples:
# var a = 2
export var nrocks = 200

const Rocks = [preload("res://scenes/Rock.tscn"),preload("res://scenes/Rock.tscn")]
const Ship = preload("res://scenes/Ship.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(nrocks):
		var rock = Rocks[i%len(Rocks)].instance()
		rock.position.x = rand_range($Sea.margin_left, $Sea.margin_right)
		rock.position.y = rand_range($Sea.margin_top, $Sea.margin_bottom)
		rock.rotation = rand_range(-PI, PI)
		var rscale = rand_range(0.6, 2)
		rock.scale *= rscale
		
		add_child(rock)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SpawnTimer_timeout():
	var ship = Ship.instance()
	ship.position = Vector2(
		rand_range($Sea.margin_left, $Sea.margin_right),
		rand_range($Sea.margin_top, $Sea.margin_bottom)
	)
	ship.rotation = rand_range(-PI, PI)
	get_parent().add_child(ship)
