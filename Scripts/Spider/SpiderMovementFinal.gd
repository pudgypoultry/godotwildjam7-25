extends CharacterBody3D

@export_category("Game Rules")
@export var gravityForce = 3
@export var baseJumpForce : float = 50
@export var jumpForce : float = 10
@export var mouseSensitivity : float = 0.005
@export var movementSpeed : float = 5.0
@export var rotationSpeed : float = 5.0
@export var dotTolerance : float = 0.01
@export var transitionDistance : float = 0.5

@export_category("Plugging in Nodes")
@export var collisionChecker : Area3D
@export var attackChecker : Area3D
@export var head : Node3D
@export var headCamera : Camera3D
@export var spawnRay : RayCast3D
@export var spiderAnimation : Node3D
@export var spiderlingCamera : PackedScene

var animation_interp_factor := 0.3 # 1 = no interpolation, 0.1 = very slow transitions
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
var originalColliderPosition : Vector3
var justStarted = true
var currentTarget : Node3D = null
var canSpawnSpider : bool = true
var canSpawnWebbing : bool = true
var isActiveController : bool = true
var spiderlingArray : Array[Node3D]


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	velocity = Vector3.ZERO
	originalUpDirection = up_direction
	originalColliderPosition = collisionChecker.position


func BodyEntered(body) -> void:
	if body.is_in_group("Walkable"):
		if body and body != bodyOn and body is StaticBody3D:
			bodyOn = body
			up_direction = body.GetGlobalClimbDirection()
			gravityVector = -up_direction
			print("New up_direction: " + str(up_direction))
			jumpVector = Vector3.ZERO
			needsToReorient = true


func PlayerSensed(body) -> void:
	if body.is_in_group("npc"):
		print("Found Player")
		currentTarget = body
		print(currentTarget.name)


func PlayerLost(body) -> void:
	if body.is_in_group("npc"):
		print("Eew Player is missing")
		currentTarget = null


func _input(event: InputEvent) -> void:
	if isActiveController:
		if event is InputEventMouseMotion:
			headCamera.rotation.x += -event.relative.y * mouseSensitivity 
			rotate(up_direction, -event.relative.x * mouseSensitivity * mouseSensMulti)
		
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
	if up_direction == originalUpDirection:
		jumpVector = up_direction * baseJumpForce
	else:
		jumpVector = up_direction * jumpForce
		up_direction = originalUpDirection
	gravityVector = up_direction * -gravityForce
	jumping = true



func _physics_process(delta: float) -> void:
	if isActiveController:
		velocity = movementSpeed * GetModelOrientedInput()
		# checkRays()
		# stop reorienting when we're close enough to the correct angle
		if acos(basis.y.dot(up_direction)) < dotTolerance:
			needsToReorient = false
		if needsToReorient:
			print("Trying to reorient")
			OrientCharacterToDirection(up_direction, delta)
		
		if not is_on_floor():
			if !needsToReorient:
				jumpVector += gravityVector
		elif is_on_floor() && jumping:
			jumpVector = Vector3.ZERO
			jumping = false
		if Input.is_action_just_pressed("Jump"):
			jump()
			up_direction = originalUpDirection
			needsToReorient = true
			gravityVector = originalUpDirection * -gravityForce
		velocity += jumpVector
		move_and_slide()
		Attack()
		SpawnSpider()
		SwapToSpiderling()
		SpawnWebbing()


func OrientCharacterToDirection(direction : Vector3, delta : float):
	if direction.length_squared() > 0:
		var backAxis : Vector3 = basis.z
		var rightAxis := -backAxis.cross(direction)
		
		var rotationBasis := Basis(rightAxis, up_direction, backAxis).orthonormalized()
		#print("Original Basis:")
		#print(basis)
		basis = basis.get_rotation_quaternion().slerp(rotationBasis, delta * rotationSpeed)
		#print("New Basis:")
		#print(basis)
		# get dot product between forward vector and new up direction, check if transtion is concave or convex
		# alter position of collider if the new angle is convex, since otherwise gravity affects me before I'm stuck to the surface
		# switch between two static collision states?
		# Look through assets for anything that may be helpful

func GetModelOrientedInput():
	var inputLeftRight = Input.get_axis("RotateLeft","RotateRight")
	var inputForwardBack = Input.get_axis("MoveBackward","MoveForward")
	
	var rawInput = Vector2(inputLeftRight, -inputForwardBack)
	var input := Vector3.ZERO
	
	#input.x = rawInput.x * sqrt(1.0 - rawInput.y * rawInput.y / 2.0)
	#input.z = rawInput.y * sqrt(1.0 - rawInput.x * rawInput.x / 2.0)
	
	input = Vector3(rawInput.x, 0, rawInput.y)
	
	#Godot 4 overloaded * for basis, it used to be "basis.xform", now it's basis * other vector
	input = transform.basis * input
	
	# Spider Animation
	var animationTree : AnimationTree
	animationTree = spiderAnimation.Anim_Tree
	var current_blend_pos : Vector2 = animationTree.get("parameters/blend_position")
	#print("current blend pos: ", current_blend_pos, " current input: ", rawInput)
	animationTree.set("parameters/blend_position", 
		Vector2(lerp(current_blend_pos.x, rawInput.x, 0.3), lerp(current_blend_pos.y, -rawInput.y, 0.3)))
	
	return input


func ProjectVecAToPlaneWithNormalVecB(vecA : Vector3, vecB : Vector3):
	var projectedVector = vecA - (vecA.dot(vecB)/vecB.length_squared())*vecB
	return projectedVector


func Attack():
	if Input.is_action_just_pressed("Attack") && isActiveController:
		if currentTarget:
			print("Trying to kill " + currentTarget.name)
			currentTarget.KillMe()
			currentTarget = null


func SpawnSpider():
	if Input.is_action_just_pressed("SpawnSpider") && isActiveController:
		print("Spawning dude")
		if canSpawnSpider && spawnRay.is_colliding():
			canSpawnSpider = false
			var newSpiderling : Node3D = spiderlingCamera.instantiate()
			get_tree().root.add_child(newSpiderling)
			newSpiderling.global_position = spawnRay.get_collision_point()
			newSpiderling.basis = basis
			newSpiderling.parentSpider = self
			spiderlingArray.append(newSpiderling)


func SpawnWebbing():
	if Input.is_action_just_pressed("SpawnWeb") && isActiveController:
		print("Spawning webbing")
		if canSpawnWebbing && spawnRay.is_colliding():
			canSpawnSpider = false
			var newSpiderling : Node3D = spiderlingCamera.instantiate()
			get_tree().root.add_child(newSpiderling)
			newSpiderling.global_position = spawnRay.get_collision_point()
			newSpiderling.basis = basis
			newSpiderling.parentSpider = self
			spiderlingArray.append(newSpiderling)


func SwapToSpiderling():
	if Input.is_action_just_pressed("SwapPerspective") && isActiveController:
		print("Swapping from parent")
		if len(spiderlingArray) > 0:
			isActiveController = false
			# creating time since for some reason it just calls both
			await get_tree().create_timer(0.05).timeout
			spiderlingArray[0].MakeActiveController()


func MakeActiveController():
	headCamera.current = true
	isActiveController = true
