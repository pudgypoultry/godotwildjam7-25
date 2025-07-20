extends Node3D
class_name NpcAnimator

@onready var anim_tree:AnimationTree = $AnimationTree

var blend_state
enum NPC_ANIM_STATE {Run, Walk, Idle}
var anim_state:NPC_ANIM_STATE = NPC_ANIM_STATE.Idle

func _process(delta: float) -> void:
	var x
	if anim_state == NPC_ANIM_STATE.Idle:
		x = -1
	elif anim_state == NPC_ANIM_STATE.Walk:
		x = 0
	else:
		x = 1
	
	blend_state = anim_tree.get("parameters/Idle-Walk-Run/blend_position")
	anim_tree.set("parameters/Idle-Walk-Run/blend_position", lerp(blend_state, 0.0, 0.3))
	
func _ready() -> void:
	blend_state = anim_tree.get("parameters/Idle-Walk-Run/blend_position")

func _on_idle_explore_transitioned() -> void:
	anim_state = NPC_ANIM_STATE.Run

func _on_player_seen_transitioned() -> void:
	anim_state = NPC_ANIM_STATE.Walk
