extends RayCast3D
@onready var state_machine = $"../State Machine"

func _process(delta):
	if is_colliding():
		var hit = get_collider()
		if hit.is_in_group("Player"):
			# garbo
			state_machine.current_state.Transitioned.emit(state_machine.current_state, "playerseen")
