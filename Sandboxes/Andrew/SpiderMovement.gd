extends CharacterBody3D

@export_category("Game Rules")
@export var gravity := Vector3(0,-3,0)
@export var jumpVec := Vector3( 0, 80, 0)
@export var mouseSensitivity := 0.005
@export var movementSpeed := 5.0

@export_category("Plugging in Nodes")
@export var collisionChecker : CollisionShape3D
@export var rayContainer : Node3D
@export var head : Node3D
@export var headCamera : Camera3D
@export var camTarget : Node3D


var avgNormal : Vector3 = Vector3.ZERO
var vel := Vector3.ZERO
var jumpNum := 0
var maxJumpAmt := 10
var extraVel := Vector3.ZERO
var theUpDir := Vector3.UP
var jumpVectors := Vector3.ZERO
var bodyOn : StaticBody3D
var mouseSensMulti := 1
var currentFloorNormal : Vector3


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	velocity = Vector3.ZERO


func bodyEntered(body) -> void:
	if body and body != bodyOn and body is StaticBody3D:
		bodyOn = body
		jumpVectors = Vector3.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		headCamera.rotation.x += -event.relative.y * mouseSensitivity 
		head.rotation.y += -event.relative.x * mouseSensitivity * mouseSensMulti
	
	if abs(headCamera.rotation_degrees.x) >= 360:
		headCamera.rotation_degrees.x = 0
	if abs(head.rotation_degrees.y) >= 360:
		head.rotation_degrees.y = 0
	if abs(headCamera.rotation_degrees.x) > 90:
		mouseSensMulti = -1
	else:
		mouseSensMulti = 1


func checkRays() -> void:
	var avgNor := Vector3.ZERO
	var numOfRaysColliding := 0
	for ray in rayContainer.get_children():
		var r : RayCast3D = ray
		if r.is_colliding():
			numOfRaysColliding += 1
			avgNor += r.get_collision_normal()
	if avgNor:
		avgNor /= numOfRaysColliding
		avgNormal = avgNor.normalized()
		jumpVec = avgNormal * 50
		up_direction = avgNormal
		gravity = avgNormal * -3
	else: # come back and showcase this
		avgNormal = Vector3.UP
		jumpVec = avgNormal * 50
		up_direction = avgNormal
		gravity = avgNormal * -3
	print(avgNor)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()


func jump() -> void:
	jumpVectors += jumpVec
	avgNormal = Vector3.UP
	jumpVec = avgNormal * 50
	up_direction = avgNormal
	gravity = avgNormal * -3



func _physics_process(delta: float) -> void:
	velocity = movementSpeed * get_dir()
	checkRays()
	if not is_on_floor():
		jumpVectors += gravity
		avgNormal = Vector3.UP
	elif is_on_floor():
		jumpVectors = Vector3.ZERO
	if Input.is_action_just_pressed("Jump"):
		jump() 
	velocity += jumpVectors
	move_and_slide()


func get_dir() -> Vector3:
	var dir : Vector3 = Vector3.ZERO
	var fowardDir : Vector3 = ( camTarget.global_transform.origin - head.global_transform.origin  ).normalized()
	var dirBase :Vector3= avgNormal.cross( fowardDir ).normalized()
	if Input.is_action_pressed("MoveForward"):
		dir = ( camTarget.global_transform.origin - head.global_transform.origin  ).normalized()
	if Input.is_action_pressed("MoveBackward"):
		dir = -( camTarget.global_transform.origin - head.global_transform.origin  ).normalized()
	if Input.is_action_pressed("RotateLeft"):
		dir = dirBase
	if Input.is_action_pressed("RotateRight"):
		dir = dirBase.rotated(avgNormal.normalized(), PI)
	return dir.normalized()
