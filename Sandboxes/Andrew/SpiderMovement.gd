extends RigidBody3D

@export var movementSpeed : float = 1.0
@export var rotationSpeed : float = 5.0
@export var jumpForce : float = 10.0
@export var camSpeedX : float = 1.0
@export var camSpeedY : float = 1.0
@export var verticalCameraClamp : float = 80
@export var moveTolerance : float = 0.2
@export var dotTolerance : float = 0.5


@export var head : Node3D
# @export var headCam : Node3D

var movementInput : Vector2 = Vector2.ZERO
var tryingToJump : bool = false
var jumping : bool = false
var shouldReset : bool = false
var collidedWithNewWall = false
var cameraX : float = 0
var cameraY : float = 0
var startPosition : Vector3
var localGravity : Vector3
var moveDirection : Vector3
var lastStrongDirection : Vector3

func _ready():
	startPosition = position


func _process(delta: float) -> void:
	HandleInput()
	if tryingToJump && !jumping:
		jumping = true


#func _physics_process(delta: float) -> void:
	#if collidedWithNewWall:
		#print("Collided")
		#OrientCharacterToDirection(localGravity.cross(moveDirection).normalized(), delta)
		#collidedWithNewWall = false


func HandleInput():
	if Input.is_action_just_pressed("Jump"):
		tryingToJump = true


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if shouldReset:
		state.transform.origin = startPosition
		shouldReset = false
	
	if collidedWithNewWall:
		print("Collided")
		OrientCharacterToDirection(localGravity.cross(moveDirection).normalized(), state.step)
		collidedWithNewWall = false
	
	localGravity = state.total_gravity.normalized()
	
	if moveDirection.length() > moveTolerance:
		lastStrongDirection = moveDirection.normalized()
		# print(moveDirection)
	
	moveDirection = GetModelOrientedInput()
	# OrientCharacterToDirection(localGravity.cross(moveDirection), state.step)
	
	
	if tryingToJump:
		print(localGravity)
		#make model jump
		apply_central_impulse(-localGravity * jumpForce)
		print("Jump Direction: " + str(-localGravity))
		tryingToJump = false
		
	if IsOnFloor(state):
		if moveDirection.length() == 0.0:
			linear_velocity = Vector3.ZERO
		elif !jumping:
			# linear_velocity = moveDirection * movementSpeed * state.step
			add_constant_central_force(moveDirection.normalized() * movementSpeed)
			# position += moveDirection * movementSpeed * state.step
		elif jumping:
			tryingToJump = false
			jumping = false
	#model.velocity = state.linear_velocity


#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
			#cameraX -= deg_to_rad(camSpeedX * event.relative.x)
			#cameraY -= deg_to_rad(camSpeedY * event.relative.y)
			#cameraY = clampf(cameraY, -verticalCameraClamp, verticalCameraClamp)
			#headCam.set_rotation(Vector3(cameraY, headCam.rotation.y, headCam.rotation.z))
			#set_rotation(Vector3(rotation.x, cameraX, rotation.z))


func GetModelOrientedInput():
	var inputLeftRight = Input.get_axis("RotateLeft","RotateRight")
	var inputForwardBack = Input.get_axis("MoveBackward","MoveForward")
	
	var rawInput = Vector2(inputLeftRight, inputForwardBack)
	var input := Vector3.ZERO
	
	#input.x = rawInput.x * sqrt(1.0 - rawInput.y * rawInput.y / 2.0)
	#input.z = rawInput.y * sqrt(1.0 - rawInput.x * rawInput.x / 2.0)
	
	input = Vector3(rawInput.x, 0, rawInput.y)
	
	#Godot 4 overloaded * for basis, it used to be "basis.xform", now it's basis * other vector
	input = transform.basis * input
	# print(input)
	return input


func OrientCharacterToDirection(direction : Vector3, delta : float):
	if direction.length_squared() > 0:
		var leftAxis := -localGravity.cross(direction)
		var rotationBasis := Basis(leftAxis, -localGravity, direction).orthonormalized()
		print("Original Basis:")
		print(basis)
		basis = basis.get_rotation_quaternion().slerp(rotationBasis, delta * rotationSpeed)


func IsJumping(state : PhysicsDirectBodyState3D) -> bool:
	return false


func ResetPosition() -> void:
	pass


func IsOnFloor(state : PhysicsDirectBodyState3D) -> bool:
	# Contacts_reported needs to be high enough to count all surfaces on body
	for contact in state.get_contact_count():
		var contactNormal = state.get_contact_local_normal(contact)
		# If the contact is below us we are on the floor
		if contactNormal.dot(-localGravity) > dotTolerance:
			return true
	return false


func OnBodyEntered(body):
	collidedWithNewWall = true
