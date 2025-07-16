extends Node

# if i was cleverer this would be a more abstract state machine
# but right now it has some hardcoded stuff for specifically the npcs...
# luckily i dont think we need other state machines in this tiny game :P

#consider moving this script to the top level navnpc
#then could actually call move_and_slide in the navnpc itself
@export var initial_state : State
var player : CharacterBody3D
var current_state : State
var states : Dictionary = {}
# random so that hopefully if two npcs are overlapping, they will move
# away from each other soon
var speed : float = 2 + randf_range(0.0, 0.5)

func _ready(): 
	# here we can assign some of the child variables like references to the player
	player = get_tree().get_first_node_in_group("Player")
	if !player:
		print("Error: player not found.")
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			child.player = player
			child.nav_npc = $".."
			child.navigation_agent = $"../NavigationAgent3D"
			child.speed = speed

	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.Update(delta)
		
func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)


func on_child_transition(state, new_state_name):
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.Exit()
		
	new_state.Enter()
	current_state = new_state
