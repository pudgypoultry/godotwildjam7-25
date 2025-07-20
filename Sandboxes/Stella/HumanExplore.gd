extends State
class_name HumanExplore

@export var debug = false


var pathing = false
var idle_time : float = 6.0

var timer : float = 0.0

func Physics_Update(delta):
	timer += delta 
	if debug:
		print(navigation_agent.distance_to_target())
	if pathing and timer < idle_time:
		var destination = navigation_agent.get_next_path_position()
		var local_destination = destination - nav_npc.global_position
		var direction = local_destination.normalized()
		
		nav_npc.velocity = direction * speed
				
		direction.y = 0  # keep rotation flat

		# handle rotation
		var current_rotation = nav_npc.rotation.y
		var target_rotation = atan2(-direction.x, -direction.z)
		var new_rotation = lerp_angle(current_rotation, target_rotation, 5.0 * delta)

		nav_npc.rotation.y = new_rotation
				
		nav_npc.move_and_slide()
	
	else:
		timer = 0
		pathing = true
		
		# select new position offset.
		# this could be changed to have further exploration
		var current_position = nav_npc.global_position
		current_position.x += randf_range(-20.0, 20.0)
		current_position.z += randf_range(-20.0, 20.0)
		navigation_agent.set_target_position(current_position)


func _on_navigation_agent_3d_target_reached():
	print("target reached!")
	pathing = false


func _on_area_3d_body_entered(body):
	# this is not really being used right now
	if body.is_in_group("Player"):
		print("player detected!")
		Transitioned.emit(self, "playerseen")
