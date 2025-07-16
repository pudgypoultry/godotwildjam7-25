extends State
class_name PlayerSeen

@export var debug = false

var chase_threshold = 1
var repulsion_strength : float = 0.7
@onready var repulsion_area = $"../../RepulsionArea"


func Enter():
	navigation_agent.set_target_position(player.global_position)

# instead of beeline, trying pathfinding. 
var timer : float = 0.0
#randomizing so each agent is slightly different(?)
var stuck_time : float = 0.25 + randfn(0.1, 0.01)

func Physics_Update(_delta): 
	timer += _delta
	if navigation_agent.is_navigation_finished() or timer > stuck_time:
		navigation_agent.set_target_position(player.global_position)
		timer = 0.0

	var next_position = navigation_agent.get_next_path_position()
	var direction = next_position - nav_npc.global_position
	
	if direction.length() > chase_threshold:
		nav_npc.velocity = direction.normalized() * speed
	else:
		Transitioned.emit(self, "attackplayer")
		nav_npc.velocity = Vector3.ZERO
	
	nav_npc.move_and_slide()


#behavior for running away: remember the entrance? rememeber previously
# visited areas? 

func _on_repulsion_area_body_entered(body):
	if body.is_in_group("npc") and body != self:
		print("repulsing")
		var push_dir = (nav_npc.global_position - body.global_position).normalized()
		nav_npc.velocity += push_dir * repulsion_strength
		
