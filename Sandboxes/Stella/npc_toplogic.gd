extends CharacterBody3D

@export var brave : bool
@export var home_base : Area3D

func KillMe():
	self.queue_free()
