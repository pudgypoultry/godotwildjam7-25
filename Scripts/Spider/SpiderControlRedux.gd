extends CharacterBody3D

@export_category("Game Rules")
@export var rotationSpeed : float = 5.0
@export var verticalCameraClamp : float = 75
@export var speed : float = 5.0
@export var runSpeed : float = 10.0

@export_category("Plugging in Nodes")
@export var head : Node3D
@export var camera : Node3D
@export var camTarget : Node3D
@export var rayFolder : Node3D
@export var spiderAnimation : Node3D
@export var spawnRay : RayCast3D
@export var spiderlingScene : PackedScene
@export var webbingScene : Array[PackedScene]


var gravity := Vector3(0,-3,0)
var jumpVec := Vector3(0, 75, 0)
var avgNormal : Vector3 = Vector3.ZERO
var MOUSE_SENS := 0.005
var baseSpeed
var jumpNum := 0
var maxJumpAmt := 10
var extravelocity := Vector3.ZERO
var theUpDir := Vector3.UP
var jumpVectors := Vector3.ZERO
var bodyOn : StaticBody3D
var currentTarget : Node3D = null
var mouseSensMulti := 1
var isActiveController : bool = true
var canSpawnSpider : bool = true
var canSpawnWebbing : bool = true
var spiderlingArray : Array = []
var health := 10

var overWebbing : bool = false
var webbings : Array = []

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	velocity = Vector3.ZERO
	baseSpeed = speed


func bodyEntered(body) -> void:
	if body and body != bodyOn and body is StaticBody3D:
		bodyOn = body
		jumpVectors = Vector3.ZERO

func AreaEntered(body):
	if body.is_in_group("Webbing"):
		overWebbing = true
		webbings.append(body)

func AreaExited(body) -> void:
	if body.is_in_group("Webbing"):
		webbings.erase(body)
		if len(webbings) == 0:
			overWebbing = false


func _input(event: InputEvent) -> void:
	if isActiveController:
		if event is InputEventMouseMotion:
			camera.rotation.x += -event.relative.y * MOUSE_SENS 
			camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(verticalCameraClamp), deg_to_rad(verticalCameraClamp))
			head.rotation.y += -event.relative.x * MOUSE_SENS * mouseSensMulti
			spiderAnimation.rotation.y += -event.relative.x * MOUSE_SENS * mouseSensMulti
		if abs(camera.rotation_degrees.x) >= 360:
			camera.rotation_degrees.x = 0
		if abs(head.rotation_degrees.y) >= 360:
			head.rotation_degrees.y = 0
		if abs(camera.rotation_degrees.x) > 90:
			mouseSensMulti = -1
		else:
			mouseSensMulti = 1


func checkRays() -> void:
	var avgNor := Vector3.ZERO
	var numOfRaysColliding := 0
	for ray in rayFolder.get_children():
		var r : RayCast3D = ray
		if r.is_colliding():
			numOfRaysColliding += 1
			avgNor += r.get_collision_normal()
	if avgNor:
		avgNor /= numOfRaysColliding
		avgNormal = avgNor.normalized()
		jumpVec = avgNormal * 50
		gravity = avgNormal * -3
	else: # come back and showcase this
		avgNormal = Vector3.UP
		jumpVec = avgNormal * 50
		gravity = avgNormal * -3

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()
	if overWebbing:
		speed = runSpeed
	else:
		speed = baseSpeed
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func jump() -> void:
	jumpVectors += jumpVec
	avgNormal = Vector3.UP
	jumpVec = avgNormal * 50
	gravity = avgNormal * -3


func _physics_process(delta: float) -> void:
	if isActiveController:
		OrientCharacterToDirection(up_direction, delta)
		velocity = speed * get_dir()
		checkRays()
		if not is_on_floor():
			jumpVectors += gravity
	#		avgNormal = Vector3.UP
		elif is_on_floor():
			jumpVectors = Vector3.ZERO
		if Input.is_action_just_pressed("Jump"):
			jump() 
		velocity += jumpVectors
		up_direction = avgNormal.normalized()
		move_and_slide()
		Attack()
		SpawnSpider()
		SwapToSpiderling()
		SpawnWebbing()


func get_dir() -> Vector3:
	var dir : Vector3 = Vector3.ZERO
	var fowardDir : Vector3 = ( camTarget.global_transform.origin - head.global_transform.origin  ).normalized()
	var dirBase :Vector3= avgNormal.cross( fowardDir ).normalized()
	var inputLeftRight = Input.get_axis("RotateLeft","RotateRight")
	var inputForwardBack = Input.get_axis("MoveBackward","MoveForward")
		# Spider Animation
	var animationTree : AnimationTree
	animationTree = spiderAnimation.Anim_Tree
	var current_blend_pos : Vector2 = animationTree.get("parameters/blend_position")
	var rawInput = Vector2(inputLeftRight, -inputForwardBack)
	var input = Vector3(rawInput.x, 0, rawInput.y)
	animationTree.set("parameters/blend_position", 
		Vector2(lerp(current_blend_pos.x, rawInput.x, 0.3), lerp(current_blend_pos.y, -rawInput.y, 0.3)))
	if Input.is_action_pressed("MoveForward"):
		dir += dirBase.rotated( avgNormal.normalized(), -PI/2 )
	if Input.is_action_pressed("MoveBackward"):
		dir += dirBase.rotated( avgNormal.normalized(), PI/2 )
	if Input.is_action_pressed("RotateLeft"):
		dir += dirBase
	if Input.is_action_pressed("RotateRight"):
		dir += dirBase.rotated(avgNormal.normalized(), PI)
	return dir.normalized()


func OrientCharacterToDirection(direction : Vector3, delta : float):
	if direction.length_squared() > 0:
		var backAxis : Vector3 = basis.z
		var rightAxis := -backAxis.cross(direction)
		
		var rotationBasis := Basis(rightAxis, direction, backAxis).orthonormalized()
		#print("Original Basis:")
		#print(basis)
		basis = basis.get_rotation_quaternion().slerp(rotationBasis, delta * rotationSpeed)


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
			var newSpiderling : Node3D = spiderlingScene.instantiate()
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
			var newWeb : Node3D = webbingScene.pick_random().instantiate()
			get_tree().root.add_child(newWeb)
			newWeb.global_position = spawnRay.get_collision_point()
			newWeb.basis = basis


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
	camera.current = true
	isActiveController = true


func Harm():
	health -= 1
	print("SPIDER HARMED!")
	
