class_name Asteroid
extends RigidBody2D

var asteroidParticles = preload("res://Scenes/asteroid_explosion.tscn")
var asteroidTextTag = preload("res://Scenes/asteroid_text_tag.tscn")

var maxDistance = 1400
var spawnCooldown = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	spawnCooldown -= delta
	
	if (Player.instance.position - position).length() > maxDistance && spawnCooldown < 0:
		if(get_tree().current_scene.name == "Tutorial"):
			return
		spawnCooldown = 1
		#print((Player.instance.position - position).length() > maxDistance , " " , (Player.instance.position - position).length())
		var angle # maybe change this to come in front of the player
		var randomChance = randi_range(1, 10)
		if Player.instance.velocity.length() > 50 && randomChance < 4:
			angle = rad_to_deg(atan2(Player.instance.velocity.normalized().y, Player.instance.velocity.normalized().x)) + randf_range(-45, 45)
		else:
			angle = randf_range(0, 360)
		freeze = true
		global_transform.origin = Player.instance.position + Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle))).normalized() * randi_range(AsteroidManager.instance.minDistance, AsteroidManager.instance.maxDistance)
		freeze = false
		linear_velocity = Vector2.ZERO
		var posToPlayer = Player.instance.position - position
		var posToPredict = (Player.instance.position + Player.instance.velocity * 2.0) - position
		var finalPos
		
		var scaleSize = randf_range(0.32, 0.38)
		if UIManager.instance.currentEvent != null:
			if UIManager.instance.currentEvent.name == "Big Asteroids":
				scaleSize = randf_range(0.45, 0.5)
			elif UIManager.instance.currentEvent.name == "Small Asteroids":
				scaleSize = randf_range(0.24, 0.3)
		
		if randomChance < 4:
			finalPos = posToPlayer
		else:
			finalPos = posToPredict
		linear_velocity = ((finalPos +  Vector2(randf_range(-8, 8), randf_range(-8, 8))).normalized()) * randi_range(200, 300)
		get_node("Sprite2D").scale = Vector2.ONE * scaleSize
		get_node("CollisionShape2D").scale = Vector2.ONE * (scaleSize + 0.05)
		#print((Player.instance.position - position).length())


func _on_tree_exiting() -> void:
	if(get_tree().current_scene.name == "Tutorial"):
		return
	AsteroidManager.instance.RemoveAsteroid(self)


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Shield"):
		print("yes")
		var asteroidTextInstance = asteroidTextTag.instantiate()
		asteroidTextInstance.position = body.position
		asteroidTextInstance.text = ""
		get_parent().add_child(asteroidTextInstance)
		var asteroidParticlesInstance = asteroidParticles.instantiate()
		asteroidParticlesInstance.position = body.global_position
		get_parent().add_child(asteroidParticlesInstance)
		queue_free()
	if body.is_in_group("player"):
		if !Player.instance.dashing:
			Player.instance.PlayHitSound()
			Player.instance.AffectHealth(-25)
			if UIManager.instance.currentEvent != null && UIManager.instance.currentEvent.name == "Small Asteroids":
				Player.instance.AffectHealth(-25)
			Player.instance.velocity = Player.instance.velocity.normalized() * Player.instance.velocity.length() / 2
			Player.instance.ToggleShield(true)
		var asteroidParticlesInstance = asteroidParticles.instantiate()
		asteroidParticlesInstance.position = body.position
		get_parent().add_child(asteroidParticlesInstance)
		queue_free()
	
		
