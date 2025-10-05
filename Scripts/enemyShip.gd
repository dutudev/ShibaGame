extends RigidBody2D

var health = 100.0
var hitMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitMaterial = $Sprite2D.material
	hitMaterial.set_shader_parameter("progress", 0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
