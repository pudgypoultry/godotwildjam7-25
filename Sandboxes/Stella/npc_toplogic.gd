extends CharacterBody3D

@export var brave : bool
var home_base : Vector3 = Vector3(-10, 0, 0)

func KillMe():
	self.queue_free()
