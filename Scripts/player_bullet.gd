extends Area2D

var asteroidTextTag = preload("res://Scenes/asteroid_text_tag.tscn")

var directionVector = Vector2.ZERO
var speed = 1500


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


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("asteroid"):
		var asteroidTextInstance = asteroidTextTag.instantiate()
		asteroidTextInstance.position = body.position
		var money = randi_range(1, 3) # make 3 able to change to more
		Player.instance.AffectMoney(money)
		asteroidTextInstance.text = "+" + str(money) + "$"
		get_parent().add_child(asteroidTextInstance)
		body.queue_free()
		#add particles
		queue_free()
