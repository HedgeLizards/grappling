extends Label

func _process(delta):
	self.text = "Ships Destroyed: " + str(Stats.ships_destroyed);
