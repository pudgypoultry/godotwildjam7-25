extends Area3D

@export_category("Game Rules")
@export var mouseSensitivity : float = 0.005

@export_category("Plugging in Nodes")
@export var head : Node3D
@export var headCamera : Camera3D
@export var spiderAnimation : Node3D

var mouseSensMulti := 1
var isActiveController = false
var parentSpider : CharacterBody3D = null

func _ready():
	var animationTree : AnimationTree
	animationTree = spiderAnimation.Anim_Tree
	var current_blend_pos : Vector2 = animationTree.get("parameters/blend_position")
	#print("current blend pos: ", current_blend_pos, " current input: ", rawInput)
	animationTree.set("parameters/blend_position", Vector2.ZERO)

func _process(delta):
	SwapBackToParentSpider()


func _input(event: InputEvent) -> void:
	if isActiveController:
		if event is InputEventMouseMotion:
			headCamera.rotation.x += -event.relative.y * mouseSensitivity 
			rotate(basis.y, -event.relative.x * mouseSensitivity * mouseSensMulti)
		
		if abs(headCamera.rotation_degrees.x) >= 360:
			headCamera.rotation_degrees.x = 0
		if abs(head.rotation_degrees.y) >= 360:
			head.rotation_degrees.y = 0
		if abs(headCamera.rotation_degrees.x) > 90:
			mouseSensMulti = -1
		else:
			mouseSensMulti = 1


func MakeActiveController():
	headCamera.current = true
	isActiveController = true


func SwapBackToParentSpider():
	if Input.is_action_just_pressed("SwapPerspective") && isActiveController:
		print("Swapping to parent")
		await get_tree().create_timer(0.05).timeout
		isActiveController = false
		parentSpider.MakeActiveController()
