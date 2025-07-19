extends CharacterBody3D

enum SpiderState {CRAWLING, JUMPING, REORIENTING, ATTACKING}

@export_category("Game Rules")
@export var gravityForce = 3
@export var baseJumpForce : float = 50
@export var jumpForce : float = 10
@export var mouseSensitivity : float = 0.005
@export var movementSpeed : float = 5.0
@export var rotationSpeed : float = 10.0
@export var dotTolerance : float = 0.01
@export var transitionDistance : float = 0.5

@export_category("Plugging in Nodes")
@export var spiderCollision : CollisionShape3D
@export var collisionChecker : Area3D
@export var attackChecker : Area3D
@export var head : Node3D
@export var headCamera : Camera3D
@export var spawnRay : RayCast3D
@export var spiderAnimation : Node3D
@export var spiderlingCamera : PackedScene
@export var webbingScene : PackedScene
@export var rayFolder : Node3D

var animation_interp_factor := 0.3 # 1 = no interpolation, 0.1 = very slow transitions
var originalGravityForce
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
var currentWalkableCollision : Node3D
var goingToWalkableCollision : Node3D
var currentState : SpiderState = SpiderState.CRAWLING
<<<<<<< Updated upstream:Sandboxes/Andrew/SpiderMovementFinal.gd
var input : Vector3 = Vector3.ZERO
var rayCastBrigade : Array
var currentAverage : Vector3

# Average normals from raycast collisions that do collide
# Check for raycast closest to average normal, grab whatever wall that collides with, use that as up_direction
=======
>>>>>>> Stashed changes:Scripts/Spider/SpiderMovementFinal.gd


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	velocity = Vector3.ZERO
	originalUpDirection = up_direction
	originalColliderPosition = collisionChecker.position
	originalGravityForce = gravityForce
	rayCastBrigade = rayFolder.get_children()


func BodyEntered(body) -> void:
	if body.is_in_group("Walkable"):
		print("Found body: " + body.name)
		currentWalkableCollision = body
		bodyOn = body
		if goingToWalkableCollision == body and body is StaticBody3D:
			bodyOn = body
			up_direction = body.GetGlobalClimbDirection()
			gravityVector = -up_direction
<<<<<<< Updated upstream:Sandboxes/Andrew/SpiderMovementFinal.gd
			ChangeSpiderState(SpiderState.REORIENTING, up_direction)
=======
			ChangeState(SpiderState.REORIENTING, up_direction)
>>>>>>> Stashed changes:Scripts/Spider/SpiderMovementFinal.gd
			print("New up_direction: " + str(up_direction))
			jumpVector = Vector3.ZERO
			needsToReorient = true


func GoingToBodyEntered(body) -> void:
	if body.is_in_group("Walkable"):
		print("Going to body: " + body.name)
		goingToWalkableCollision = body


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


func Jump() -> void:
<<<<<<< Updated upstream:Sandboxes/Andrew/SpiderMovementFinal.gd
	#print("Trying to jump")
	#ChangeSpiderState(SpiderState.JUMPING, up_direction)
=======
	print("Trying to jump")
	ChangeState(SpiderState.JUMPING, up_direction)
>>>>>>> Stashed changes:Scripts/Spider/SpiderMovementFinal.gd
	if up_direction == originalUpDirection or needsToReorient:
		jumpVector = up_direction * baseJumpForce
	else:
		jumpVector = up_direction * jumpForce
<<<<<<< Updated upstream:Sandboxes/Andrew/SpiderMovementFinal.gd
		#up_direction = originalUpDirection
	#jumping = true
	velocity += jumpVector * basis.y
=======
		up_direction = originalUpDirection
	jumping = true
>>>>>>> Stashed changes:Scripts/Spider/SpiderMovementFinal.gd



func _physics_process(delta: float) -> void:
	if isActiveController:
<<<<<<< Updated upstream:Sandboxes/Andrew/SpiderMovementFinal.gd
		currentAverage = GetAverageNormal()
		#if acos(currentAverage.dot(up_direction)) > dotTolerance:
			#ChangeSpiderState(SpiderState.REORIENTING, currentAverage)
		if Input.is_action_just_pressed("Jump"):
			ChangeSpiderState(SpiderState.JUMPING, originalUpDirection)
			Jump()
		elif !jumping:
			ChangeSpiderState(SpiderState.CRAWLING, up_direction)
		
		if acos(up_direction.dot(currentAverage)) > dotTolerance:
			OrientCharacterToDirection(currentAverage, delta)
=======
>>>>>>> Stashed changes:Scripts/Spider/SpiderMovementFinal.gd
		HandleStateBehavior(currentState, delta)
		Attack()
		SpawnSpider()
		SwapToSpiderling()
		SpawnWebbing()
		move_and_slide()


func OrientCharacterToDirection(direction : Vector3, delta : float):
	if direction.length_squared() > 0:
		var backAxis : Vector3 = basis.z
		var rightAxis := -backAxis.cross(direction)
		
		var rotationBasis := Basis(rightAxis, direction, backAxis).orthonormalized()
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
	input = Vector3(rawInput.x, 0, rawInput.y)
	
	#Godot 4 overloaded * for basis, it used to be "basis.xform", now it's basis * other vector
	input = transform.basis * input
	
	# Spider Animation
	var animationTree : AnimationTree
	animationTree = spiderAnimation.Anim_Tree
	var current_blend_pos : Vector2 = animationTree.get("parameters/blend_position")
	animationTree.set("parameters/blend_position", 
		Vector2(lerp(current_blend_pos.x, rawInput.x, 0.3), lerp(current_blend_pos.y, -rawInput.y, 0.3)))
	
	return input


func ProjectVecAToPlaneWithNormalVecB(vecA : Vector3, vecB : Vector3):
	var projectedVector = vecA - (vecA.dot(vecB)/vecB.length_squared())*vecB
	return projectedVector


func GetAverageNormal() -> Vector3:
	var avgNor := Vector3.ZERO
	var numOfRaysColliding := 0
	var countDict : Dictionary
	for ray in rayCastBrigade:
		if ray.is_colliding():
			var currentCollider = ray.get_collider()
			if currentCollider.is_in_group("Walkable"):
				if currentCollider.GetGlobalClimbDirection() in countDict.keys():
					countDict[currentCollider.GetGlobalClimbDirection()] += 1
				else:
					countDict[currentCollider.GetGlobalClimbDirection()] = 1
		else:
			if originalUpDirection in countDict.keys():
				countDict[originalUpDirection] += 1
			else:
				countDict[originalUpDirection] = 1
	#if avgNor:
		#avgNor /= numOfRaysColliding
		#return avgNor.normalized()
	var dictMax = -1
	var currentBest : Vector3
	for item in countDict.keys():
		if countDict[item] > dictMax:
			dictMax = countDict[item]
			currentBest = item
	return currentBest


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
	if Input.is_action_just_pressed("SpawnWebbing") && isActiveController:
		print("Spawning webbing")
		if canSpawnWebbing && spawnRay.is_colliding():
			canSpawnSpider = false
			var newWeb : Node3D = webbingScene.instantiate()
			get_tree().root.add_child(newWeb)
			newWeb.global_position = spawnRay.get_collision_point()
			newWeb.basis = basis
			newWeb.parentSpider = self


func SenseWebbing():
	pass
	# if standing on webbing, go faster


func SwapToSpiderling():
	if Input.is_action_just_pressed("SwapToSpiderling") && isActiveController:
		print("Swapping from parent")
		if len(spiderlingArray) > 0:
			isActiveController = false
			# creating time since for some reason it just calls both
			await get_tree().create_timer(0.05).timeout
			spiderlingArray[0].MakeActiveController()


func MakeActiveController():
	headCamera.current = true
	isActiveController = true


func HandleStateBehavior(state : SpiderState, delta):
<<<<<<< Updated upstream:Sandboxes/Andrew/SpiderMovementFinal.gd
	# print(SpiderState.keys()[state])
	match state:
		SpiderState.CRAWLING:
			velocity = movementSpeed * GetModelOrientedInput()
			# checkRays()
			# stop reorienting when we're close enough to the correct angle
			#if acos(basis.y.dot(up_direction)) < dotTolerance:
				#needsToReorient = false
			#if needsToReorient:
				#print("Trying to reorient")
				#OrientCharacterToDirection(up_direction, delta)
=======
	print(SpiderState.keys()[state])
	match state:
		SpiderState.CRAWLING:
			velocity = movementSpeed * GetModelOrientedInput()
			if velocity.length() == 0:
				collisionChecker.process_mode = Node.PROCESS_MODE_DISABLED
			else:
				collisionChecker.process_mode = Node.PROCESS_MODE_ALWAYS
			# checkRays()
			# stop reorienting when we're close enough to the correct angle
			if acos(basis.y.dot(up_direction)) < dotTolerance:
				needsToReorient = false
			if needsToReorient:
				print("Trying to reorient")
				OrientCharacterToDirection(up_direction, delta)
				spiderCollision.disabled = true
			else:
				spiderCollision.disabled = false
>>>>>>> Stashed changes:Scripts/Spider/SpiderMovementFinal.gd
			
			if !is_on_floor():
				if !needsToReorient:
					jumpVector += gravityVector
			elif is_on_floor() && jumping:
				jumpVector = Vector3.ZERO
				jumping = false
<<<<<<< Updated upstream:Sandboxes/Andrew/SpiderMovementFinal.gd


=======
			if Input.is_action_just_pressed("Jump"):
				Jump()
				up_direction = originalUpDirection
				needsToReorient = true
>>>>>>> Stashed changes:Scripts/Spider/SpiderMovementFinal.gd
				gravityVector = originalUpDirection * -gravityForce
			velocity += gravityVector
		
		SpiderState.JUMPING:
<<<<<<< Updated upstream:Sandboxes/Andrew/SpiderMovementFinal.gd
			#if acos(basis.y.dot(originalUpDirection)) < dotTolerance:
				#OrientCharacterToDirection(originalUpDirection, delta)
			gravityVector = up_direction * -gravityForce
			velocity += gravityVector
			if is_on_floor():
				ChangeSpiderState(SpiderState.CRAWLING, up_direction)
		
		SpiderState.REORIENTING:
			OrientCharacterToDirection(up_direction, delta)
			velocity = movementSpeed * GetModelOrientedInput()
			if acos(basis.y.dot(up_direction)) < dotTolerance:
				if is_on_floor():
					ChangeSpiderState(SpiderState.CRAWLING, up_direction)
				else:
					ChangeSpiderState(SpiderState.JUMPING, originalUpDirection)
=======
			if acos(basis.y.dot(originalUpDirection)) < dotTolerance:
				OrientCharacterToDirection(originalUpDirection, delta)
			gravityVector = up_direction * -gravityForce
			velocity += jumpVector
			if is_on_floor():
				ChangeState(SpiderState.CRAWLING, up_direction)
		
		SpiderState.REORIENTING:
			OrientCharacterToDirection(up_direction, delta)
			velocity = movementSpeed * (-basis.z) * GetModelOrientedInput()
			if acos(basis.y.dot(up_direction)) < dotTolerance:
				if is_on_floor():
					ChangeState(SpiderState.CRAWLING, up_direction)
				else:
					ChangeState(SpiderState.JUMPING, originalUpDirection)
>>>>>>> Stashed changes:Scripts/Spider/SpiderMovementFinal.gd
			# also handle how movement works while in this state, disable gravity if was on floor within short amount of time
		
		SpiderState.ATTACKING:
			pass


<<<<<<< Updated upstream:Sandboxes/Andrew/SpiderMovementFinal.gd
func ChangeSpiderState(newState : SpiderState, newUpDirection : Vector3):
=======
func ChangeState(newState : SpiderState, newUpDirection : Vector3):
>>>>>>> Stashed changes:Scripts/Spider/SpiderMovementFinal.gd
	match newState:
		SpiderState.CRAWLING:
			needsToReorient = false
			jumping = false
		
		SpiderState.JUMPING:
			needsToReorient = false
			jumping = true
		
		SpiderState.REORIENTING:
			needsToReorient = true
			jumping = false
		
		SpiderState.ATTACKING:
			pass
		
	currentState = newState
