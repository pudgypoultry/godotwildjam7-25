extends State
class_name HumanExplore

@export var debug = false
@onready var navigation_agent_3d = $"../../NavigationAgent3D"
@onready var nav_npc = $"../.."


var pathing = false
var idle_time : float = 1.0
var speed : int = 2.5

var timer : float = 0.0

func Physics_Update(delta): 
	if debug:
		print(navigation_agent_3d.distance_to_target())
	if pathing:
		var destination = navigation_agent_3d.get_next_path_position()
		var local_destination = destination - nav_npc.global_position
		var direction = local_destination.normalized()
		
		
		nav_npc.velocity = direction * speed
		nav_npc.move_and_slide()
	
	else:
		# not pathing. have character wait for a bit before picking new dest
		timer += delta
		if timer > idle_time:
			timer = 0
			pathing = true
			var random_position := Vector3.ZERO
			random_position.x = randf_range(-10.0, 10.0)
			random_position.z = randf_range(-10.0, 10.0)
			navigation_agent_3d.set_target_position(random_position)


func _on_navigation_agent_3d_target_reached():
	print("target reached!")
	pathing = false


func _on_area_3d_body_entered(body):
	print("3d body entered!")
	Transitioned.emit(self, "playerseen")
