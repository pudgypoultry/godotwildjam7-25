extends StaticBody3D

class_name ClimbableWall

@export var climbDirection : Node3D

func _ready():
	print(name + ":	" + str(GetGlobalClimbDirection()))

func GetGlobalClimbDirection():
	return (climbDirection.global_position - global_position).normalized()
