extends Node2D


# Declare member variables here. Examples:
# var a = 2
export var nrocks = 200

const Rocks = [
	preload("res://scenes/Rock.tscn"),
	preload("res://scenes/Rock2.tscn"),
	preload("res://scenes/Rock_large.tscn"),
	preload("res://scenes/Rock2_large.tscn")
]
const Ship = preload("res://scenes/Ship.tscn")
const Edge = preload("res://scenes/Edge.tscn")
const edge_segment_width = 2000
onready var maxpos = $Sea.rect_position + $Sea.rect_size * $Sea.rect_scale
onready var xmin = $Sea.rect_position.x
onready var xmax = maxpos.x
onready var ymin = $Sea.rect_position.y
onready var ymax = maxpos.y

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for i in range(nrocks):
		var rock = Rocks[i%len(Rocks)].instance()
		rock.position.x = rand_range(xmin, xmax)
		rock.position.y = rand_range(ymin, ymax)
		rock.rotation = rand_range(-PI, PI)
		# var rscale = rand_range(0.6, 2)
		# rock.scale *= rscale
		
		add_child(rock)
	for x in range(xmin+edge_segment_width/2, xmax, edge_segment_width):
		var top = Edge.instance()
		top.position = Vector2(x, ymin)
		add_child(top)
		var bottom = Edge.instance()
		bottom.position = Vector2(x, ymax)
		bottom.rotation = PI
		add_child(bottom)
	for y in range(ymin+edge_segment_width/2, ymax, edge_segment_width):
		var left = Edge.instance()
		left.position = Vector2(xmin, y)
		left.rotation = -PI/2
		add_child(left)
		var right = Edge.instance()
		right.position = Vector2(xmax, y)
		right.rotation = PI/2
		add_child(right)


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
