extends CharacterBody3D

var speed = 2.5
@export var char_to_kill : CharacterBody3D

var timer = 0
var timelimit = 5
var havent_killed = false

func _physics_process(delta):
	timer += delta
	if timer > timelimit and havent_killed:
		char_to_kill.KillMe()
		havent_killed = false
		
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction3 := Vector3(direction.x, 0, direction.y)
	
	velocity.x = direction3.x * speed
	velocity.z = direction3.z * speed
	
	move_and_slide()
