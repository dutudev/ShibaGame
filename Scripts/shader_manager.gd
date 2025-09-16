extends Node2D

var vec2: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	vec2.x += delta / 15
	vec2.y += delta / 18
	RenderingServer.global_shader_parameter_set("positionOffset", vec2)
