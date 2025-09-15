extends Panel


var progress = -0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.set_shader_parameter("progress", 0.0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += delta / 2
	material.set_shader_parameter("progress", clamp(EaseOutExpo(progress), 0.0, 1.0))
	if clamp(EaseOutExpo(progress), 0.0, 1.0) >= 1.0:
		queue_free()


func EaseOutExpo(x: float) -> float:
	if x == 1:
		return 1.0
	else:
		return 1 - pow(2, -10 * x)
