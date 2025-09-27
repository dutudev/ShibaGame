extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var asteroids = get_tree().get_nodes_in_group("asteroid")
	$CPUParticles2D.emitting = true
	for asteroid in asteroids:
		asteroid.linear_velocity = Vector2.ZERO
		var directionVector = asteroid.position - position
		var power = 1.0 - clamp(directionVector.length()/900.0, 0.0, 1.0)
		asteroid.apply_impulse(directionVector.normalized() * 550 * power);


func _on_timer_timeout() -> void:
	queue_free()
