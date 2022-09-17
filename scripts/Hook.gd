extends Node2D

const MAX_LENGTH = 1000
const GRAPPLE_SPEED = 750
const RETRACT_SPEED = 750

var retracting = false
var direction
var bodies = []
var polygon
var segment

onready var player = get_parent().get_node("Player")

func _ready():
	$RayCast2D.add_exception(player)

func _physics_process(delta):
	var points = $Line2D.points
	
	if direction == null:
		position = player.position
	else:
		points[0] = player.position - position
	
	if retracting:
		var remaining_retraction = RETRACT_SPEED * delta
		var index = points.size() - 1
		var previous_point = points[index]
		
		while true:
			var point = points[index - 1]
			var distance = point.distance_to(previous_point)
			
			remaining_retraction -= distance
			
			if remaining_retraction >= 0:
				if index > 0:
					points.remove(index)
				else:
					reset()
					
					return
			else:
				points[index] = point - point.direction_to(previous_point) * remaining_retraction
				
				$Sprite.rotation = point.angle_to_point(previous_point) - 0.5 * PI
				
				break
			
			index -= 1
			previous_point = point
	elif !bodies.empty():
		var next_segment = fposmod(segment + player.clockwise, polygon.size())
		
		if Geometry.segment_intersects_segment_2d(polygon[segment], polygon[next_segment], position + points[0], position + points[1]) != null:
			points.insert(1, polygon[segment] - position)
			
			player.distance = points[0].distance_to(points[1])
			player.angle = points[0].angle_to_point(points[1])
			player.target = position + points[1]
			
			segment = next_segment
		else:
			$RayCast2D.position = points[0]
			$RayCast2D.cast_to = points[1] - points[0]
			$RayCast2D.force_raycast_update()
			
			var collider = $RayCast2D.get_collider()
			
			if collider != null:
				var collision_point = $RayCast2D.get_collision_point()
				
				points.insert(1, collision_point - position)
				
				player.distance = points[0].distance_to(points[1])
				player.angle = points[0].angle_to_point(points[1])
				player.target = position + points[1]
				
				polygon = Transform2D(collider.rotation, collider.position).xform(collider.get_node("CollisionPolygon2D").polygon)
				
				var previous_vertex = polygon[polygon.size() - 1]
				var min_distance = INF
				
				for i in polygon.size():
					var vertex = polygon[i]
					var closest_point = Geometry.get_closest_point_to_segment_2d(collision_point, previous_vertex, vertex)
					var distance = collision_point.distance_to(closest_point)
					
					if distance < min_distance:
						min_distance = distance
						
						segment = i
					
					previous_vertex = vertex
				
				$RayCast2D.add_exception(collider)
				
				collider.set_physics_process(false)
				
				bodies.push_back(collider)
	elif direction != null:
		points[1] += direction * GRAPPLE_SPEED * delta
		
		$RayCast2D.position = points[0]
		$RayCast2D.cast_to = points[1] - points[0]
		$RayCast2D.force_raycast_update()
		
		var collider = $RayCast2D.get_collider()
		
		if collider != null:
			var collision_point = $RayCast2D.get_collision_point()
			
			points[1] = collision_point - position
			
			player.speed = player.velocity.length()
			player.clockwise = sign(points[1].tangent().dot(points[0] - points[1]))
			
			if player.clockwise == 0:
				player.clockwise = sign($RayCast2D.get_collision_normal().tangent().dot(points[0] - points[1]))
			
			player.distance = points[0].distance_to(points[1])
			player.angle = points[0].angle_to_point(points[1])
			player.target = position + points[1]
			
			polygon = Transform2D(collider.rotation, collider.position).xform(collider.get_node("CollisionPolygon2D").polygon)
			
			var previous_vertex = polygon[polygon.size() - 1]
			var min_distance = INF
			
			for i in polygon.size():
				var vertex = polygon[i]
				var closest_point = Geometry.get_closest_point_to_segment_2d(collision_point, previous_vertex, vertex)
				var distance = collision_point.distance_to(closest_point)
				
				if distance < min_distance:
					min_distance = distance
					
					segment = i
				
				previous_vertex = vertex
			
			if player.clockwise == -1:
				segment = fposmod(segment - 1, polygon.size())
			
			$RayCast2D.add_exception(collider)
				
			collider.set_physics_process(false)
				
			bodies.push_back(collider)
		elif points[0].distance_to(points[1]) >= MAX_LENGTH:
			retracting = true
	
	$Line2D.points = points
	$Sprite.position = points[points.size() - 1]

func reset():
	$Line2D.points = [Vector2.ZERO, Vector2.ZERO]
	$Sprite.position = Vector2.ZERO
	
	position = player.position
	
	retracting = false
	direction = null

func clear_bodies():
	for body in bodies:
		if is_instance_valid(body):
			$RayCast2D.remove_exception(body)
			print(body)
			body.set_physics_process(true)
	
	bodies.clear()
