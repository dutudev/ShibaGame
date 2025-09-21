extends CPUParticles2D

var destroyTime = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emitting = true
	$AudioStreamPlayer2D.play()

func _process(delta: float) -> void:
	destroyTime -= delta
	if destroyTime <= 0:
		queue_free()
