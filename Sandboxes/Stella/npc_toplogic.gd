extends CharacterBody3D

@export var brave : bool
@export var home_base : Area3D
@export var spiderDetector : Area3D
@export var lineOfSightRay : RayCast3D
@export var ammo : int = 24

var currentTarget : Node3D


func KillMe():
	self.queue_free()


func _physics_process(delta: float) -> void:
	if currentTarget != null:
		# if there exists a current spider to look at, look at it
		lineOfSightRay.target_position = currentTarget.global_position - lineOfSightRay.global_position


func DetectSpider(body):
	if body.is_in_group("Spider"):
		currentTarget = body


func LoseSpider(body):
	if body.is_in_group("Spider"):
		if body == currentTarget:
			currentTarget = null


func AttackSpider(body):
	if body.is_in_group("Spider") && brave:
		pass
		# Start Attacking
