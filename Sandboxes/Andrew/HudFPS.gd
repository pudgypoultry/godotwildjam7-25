extends Control

@export var healthBar : TextureProgressBar
@export var staminaBar : TextureProgressBar
@export var debugLabel : Label

func SetHealth(newHPAmount : float):
	healthBar.value = newHPAmount

func SetStamina(newStaminaAmount : float):
	staminaBar.value = newStaminaAmount

func SetHUDDebug(message : String):
	debugLabel.text = message
