extends CharacterBody3D

var speed = 2.5

func _physics_process(delta):
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction3 := Vector3(direction.x, 0, direction.y)
	
	velocity.x = direction3.x * speed
	velocity.z = direction3.z * speed
	
	move_and_slide()
