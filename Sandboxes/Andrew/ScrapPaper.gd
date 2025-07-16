extends CharacterBody3D

@export_category("Game Rules")
@export var gravityForce = 3
@export var jumpForce : float = 50
@export var mouseSensitivity : float = 0.005
@export var movementSpeed : float = 5.0
@export var rotationSpeed : float = 5.0
@export var dotTolerance : float = 0.01

@export_category("Plugging in Nodes")
@export var collisionChecker : Area3D
# @export var rayContainer : Node3D
@export var head : Node3D
@export var headCamera : Camera3D
# @export var camTarget : Node3D


var jumpNum := 0
var maxJumpAmt := 10
var jumping : bool = false
var extraVel := Vector3.ZERO
var theUpDir := Vector3.UP
var jumpVector := Vector3.ZERO
var gravityVector : Vector3 = Vector3(0, -1, 0)
var bodyOn : StaticBody3D
var mouseSensMulti := 1
var needsToReorient = false
var originalUpDirection : Vector3
var justStarted = true


func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	velocity = Vector3.ZERO
	originalUpDirection = up_direction


func bodyEntered(body) -> void:
	if body.is_in_group("Walkable"):
		if body and body != bodyOn and body is StaticBody3D:
			bodyOn = body
			up_direction = body.GetGlobalClimbDirection()
			gravityVector = -up_direction
			print("New up_direction: " + str(up_direction))
			jumpVector = Vector3.ZERO
			needsToReorient = true


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



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()


func jump() -> void:
	print("Trying to jump")
	jumpVector = up_direction * jumpForce
	up_direction = originalUpDirection
	gravityVector = up_direction * -gravityForce
	jumping = true



func _physics_process(delta: float) -> void:
	velocity = movementSpeed * GetModelOrientedInput()
	# checkRays()
	# stop reorienting when we're close enough to the correct angle
	if acos(basis.y.dot(up_direction)) < dotTolerance:
		needsToReorient = false
	if needsToReorient:
		print("Trying to reorient")
		OrientCharacterToDirection(up_direction, delta)
	
	if not is_on_floor():
		jumpVector += gravityVector
	elif is_on_floor() && jumping:
		jumpVector = Vector3.ZERO
		jumping = false
	if Input.is_action_just_pressed("Jump"):
		jump()
	velocity += jumpVector
	move_and_slide()


func OrientCharacterToDirection(direction : Vector3, delta : float):
	if direction.length_squared() > 0:
		var backAxis : Vector3 = basis.z
		var rightAxis := -backAxis.cross(direction)
		print("Forward: " + str(backAxis))
		print("Left: " + str(rightAxis))
		print("Up: " + str(up_direction))
		
		var rotationBasis := Basis(rightAxis, up_direction, backAxis).orthonormalized()
		print("Original Basis:")
		print(basis)
		basis = basis.get_rotation_quaternion().slerp(rotationBasis, delta * rotationSpeed)
		print("New Basis:")
		print(basis)


func GetModelOrientedInput():
	var inputLeftRight = Input.get_axis("RotateLeft","RotateRight")
	var inputForwardBack = Input.get_axis("MoveBackward","MoveForward")
	
	var rawInput = Vector2(-inputLeftRight, inputForwardBack)
	var input := Vector3.ZERO
	
	#input.x = rawInput.x * sqrt(1.0 - rawInput.y * rawInput.y / 2.0)
	#input.z = rawInput.y * sqrt(1.0 - rawInput.x * rawInput.x / 2.0)
	
	input = Vector3(rawInput.x, 0, rawInput.y)
	
	#Godot 4 overloaded * for basis, it used to be "basis.xform", now it's basis * other vector
	input = transform.basis * input
	
	# print(input)
	#if rawInput.length() > 0:
		#print(input)
	return input
