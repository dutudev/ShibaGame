extends Node2D

var destroyTime = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Particle.emitting = true
	$Particle2.emitting = true
	$Particle3.emitting = true

func _process(delta: float) -> void:
	destroyTime -= delta
	if destroyTime <= 0:
		queue_free()
