extends Area2D

var directionVector = Vector2.ZERO
var speed = 500


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += directionVector * speed * delta
	pass

func SetDirection(direction: Vector2) -> void:
	directionVector = direction
	pass


func _on_timer_timeout() -> void:
	queue_free()
