extends State
class_name PlayerSeen

@export var debug = false
@onready var navigation_agent_3d = $"../../NavigationAgent3D"
@onready var nav_npc = $"../.."


var run_speed = 3.5
var chase_threshold = 2
var player : CharacterBody3D

func Enter():
	player = get_tree().get_first_node_in_group("Player")

func Physics_Update(_delta): 
	var direction = player.global_position - nav_npc.global_position
	
	if direction.length() > chase_threshold:
		nav_npc.velocity = direction.normalized() * run_speed
		
	else:
		nav_npc.velocity = Vector3.ZERO
			
	nav_npc.move_and_slide()
