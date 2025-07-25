extends State
class_name PlayerSeen

@export var debug = false

var chase_threshold = 1
var timer : float = 0.0
#randomizing so each agent is slightly different(?)
var stuck_time : float = 0.25 + randfn(0.1, 0.01)

func Enter():
	Transitioned.emit()
	# set up the first target based on what the npc's behavior is
	if nav_npc.brave:
		navigation_agent.set_target_position(player.global_position)
	else:
		navigation_agent.set_target_position(nav_npc.home_base.global_position)


func Physics_Update(delta): 
	timer += delta
	npc_animator.anim_state = npc_animator.NPC_ANIM_STATE.Run
	if navigation_agent.is_navigation_finished() or timer > stuck_time:
		if nav_npc.brave:
			# pick the next position
			navigation_agent.set_target_position(player.global_position)
		# else: the npc may have reached home base. handle that here, maybe.
		timer = 0.0

	var next_position = navigation_agent.get_next_path_position()
	var direction = next_position - nav_npc.global_position
	var norm_dir = direction.normalized()
	
	if direction.length() > chase_threshold:
		nav_npc.velocity = norm_dir * speed
	else:
		Transitioned.emit(self, "attackplayer") 
		nav_npc.velocity = Vector3.ZERO

	norm_dir.y = 0  # keep rotation flat

	# handling look rotation
	# to make this work, had to flip the npc's mesh
	var current_rotation = nav_npc.rotation.y
	var target_rotation = atan2(-norm_dir.x, -norm_dir.z)
	var new_rotation = lerp_angle(current_rotation, target_rotation, 5.0 * delta)

	nav_npc.rotation.y = new_rotation

	nav_npc.move_and_slide()


#behavior for running away: remember the entrance? rememeber previously
# visited areas? 

#func _on_repulsion_area_body_entered(body):
	## this doesn't work, so right now they are not running into one another.
	#if body.is_in_group("npc") and body != self:
		#print("repulsing")
		#var push_dir = (nav_npc.global_position - body.global_position).normalized()
		#nav_npc.velocity += push_dir * repulsion_strength
		#
