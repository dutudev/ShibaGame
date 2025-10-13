extends Area2D

var asteroidTextTag = preload("res://Scenes/asteroid_text_tag.tscn")
var asteroidParticles = preload("res://Scenes/asteroid_explosion.tscn")
var explosion = preload("res://Scenes/missile_explosion.tscn")

var directionVec = Vector2.ZERO
var speed = 1000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setDir(vec: Vector2) -> void:
	directionVec = vec

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = global_position + directionVec * delta * speed


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("player")):
		Player.instance.PlayHitSound()
		Player.instance.AffectHealth(-10)
		#Player.instance.velocity = Player.instance.velocity.normalized() * Player.instance.velocity.length() / 2
		Player.instance.ToggleShield(true)
		var explosionInstance = explosion.instantiate()
		explosionInstance.global_position = position
		get_parent().add_child(explosionInstance)
		queue_free()
	elif body.is_in_group("asteroid"):
		var asteroidTextInstance = asteroidTextTag.instantiate()
		var asteroidParInstance = asteroidParticles.instantiate()
		asteroidTextInstance.position = body.position
		asteroidParInstance.position = body.position
		asteroidTextInstance.text = ""
		get_parent().add_child(asteroidTextInstance)
		get_parent().add_child(asteroidParInstance)
		body.queue_free()
		queue_free()
