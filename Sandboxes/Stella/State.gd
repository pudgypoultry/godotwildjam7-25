extends Node
# skeleton of this code comes from this tutorial:
# https://www.youtube.com/watch?v=ow_Lum-Agbs&ab_channel=Bitlytic
class_name State
var player : CharacterBody3D
var nav_npc : CharacterBody3D
var navigation_agent : NavigationAgent3D
var speed : float
var npc_animator:NpcAnimator

# abstract base State, more or less. 

signal Transitioned

func Enter():
	# called when the state is entered
	pass
	
func Exit():
	# called when the state is exited
	pass
	
func Update(_delta):
	pass

func Physics_Update(_delta):
	pass
