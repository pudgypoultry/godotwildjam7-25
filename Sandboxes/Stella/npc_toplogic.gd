extends CharacterBody3D

@export var brave : bool
@export var home_base : Area3D
@export var spiderDetector : Area3D
@export var lineOfSightRay : RayCast3D
@export var ammo : int = 24
@onready var state_machine = $"State Machine"

var reload_time : float = 1

var currentTarget : Node3D


func KillMe():
	self.queue_free()


func _physics_process(delta: float) -> void:
	if currentTarget != null:
		# if there exists a current spider to look at, look at it
		# changed to local coords
		lineOfSightRay.target_position = lineOfSightRay.to_local(currentTarget.global_position)


func DetectSpider(body):
	if body.is_in_group("Player"):
		currentTarget = body
		state_machine.current_state.Transitioned.emit(state_machine.current_state, "playerseen")


func LoseSpider(body):
	if body.is_in_group("Player"):
		if body == currentTarget:
			currentTarget = null


func AttackSpider(body):
	if body.is_in_group("Player") && brave:
		var hit = lineOfSightRay.get_collider()
		# double check that the player can actually be seen by the npc
		if hit and hit.is_in_group("Player"):
			print("attacking spider.")
			if ammo > 0:
				ammo -= 1
				body.Harm()
				await Reload()
				
				# WATCH THIS! dangerous mayhaps
				if currentTarget: AttackSpider(currentTarget)

func Reload():
	await get_tree().create_timer(reload_time).timeout
