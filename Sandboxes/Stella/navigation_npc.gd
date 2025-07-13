extends CharacterBody3D

@onready var navigation_agent_3d : NavigationAgent3D = $NavigationAgent3D

@export var debug = false
var disttol : float = 0.01
var pathing = false
var speed : int = 2.5

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		pathing = true
		var random_position := Vector3.ZERO
		random_position.x = randf_range(-10.0, 10.0)
		random_position.z = randf_range(-10.0, 10.0)
		navigation_agent_3d.set_target_position(random_position)

func _physics_process(delta): 
	if debug:
		print(navigation_agent_3d.distance_to_target())
	if pathing:
		var destination = navigation_agent_3d.get_next_path_position()
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		
		
		velocity = direction * speed
		move_and_slide()


func _on_navigation_agent_3d_target_reached():
	print("target reached!")
	pathing = false
