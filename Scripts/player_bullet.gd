extends Area2D

var asteroidTextTag = preload("res://Scenes/asteroid_text_tag.tscn")
var asteroidParticles = preload("res://Scenes/asteroid_explosion.tscn")

var directionVector = Vector2.ZERO
var speed = 1500

var maxAsteroidMoney = 2 # maybe change this to player var

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	#get max asteroidmoney

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
		if(UIManager.instance.currentEvent != null && UIManager.instance.currentEvent.name == "Bouncy Asteroids"):
			body.linear_velocity = Vector2.ZERO
			body.apply_impulse(directionVector * 250);
			if !Player.instance.CheckCardInDeck("Piercing Bullets"):
				queue_free()
			return
		var asteroidTextInstance = asteroidTextTag.instantiate()
		var asteroidParticlesInstance = asteroidParticles.instantiate()
		asteroidTextInstance.position = body.position
		asteroidParticlesInstance.position = body.position
		if Player.instance.CheckCardInDeck("Gold Asteroids"):
			maxAsteroidMoney = 4
		else:
			maxAsteroidMoney = 2
		var money = randi_range(1, maxAsteroidMoney) # make 3 able to change to more
		Player.instance.AffectMoney(money)
		if Player.instance.CheckCardInDeck("Life Insurance"):
			Player.instance.AffectHealth(money * 5)
			asteroidTextInstance.text = "+" + str(money) + "$ +" + str(money * 5) + "hp"
		else:
			if(randi_range(1, 10) <= 3):
				Player.instance.AffectHealth(money * 5)
				asteroidTextInstance.text = "+" + str(money) + "$ +" + str(money * 5) + "hp"
			else:
				asteroidTextInstance.text = "+" + str(money) + "$"
		get_parent().add_child(asteroidTextInstance)
		get_parent().add_child(asteroidParticlesInstance)
		body.queue_free()
		#add particles
		if !Player.instance.CheckCardInDeck("Piercing Bullets"):
			queue_free()
		
