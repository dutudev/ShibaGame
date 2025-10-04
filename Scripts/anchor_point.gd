extends Node2D

@export var sprite: Sprite2D
@export var speed = 0.0

func _process(delta: float) -> void:
	sprite.global_rotation_degrees = sprite.rotation_degrees + delta * speed
	if (Player.instance.position - position).length() <= 300:
		UIManager.instance.GameWin()
