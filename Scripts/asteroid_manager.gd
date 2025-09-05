class_name AsteroidManager
extends Node2D

const maxAsteroids = 10
const minDistance = 1300
const maxDistance = 1350

var asteroid = preload("res://Scenes/asteroid.tscn")

@export var asteroidSprites = Array([])

var asteroidList = Array([])
var asteroidSpawnCooldown = 0.0 # This will be set to one second so asteroids dont come piling in

static var instance:AsteroidManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	instance = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if asteroidList.size() < maxAsteroids && asteroidSpawnCooldown <= 0:
		asteroidSpawnCooldown = 1.5
		SpawnAsteroid()
	asteroidSpawnCooldown -= delta


func SpawnAsteroid() -> void:
	var asteroidInstance = asteroid.instantiate()
	var angle = randf_range(0, 360)
	var positionToSet = Player.instance.position + Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle))) * randi_range(minDistance, maxDistance) # change this to min-max distance
	var spriteIndex = randi_range(0, asteroidSprites.size()-1)
	var scaleSize = randf_range(0.2, 0.4)
	var velocityToGive = ((Player.instance.position - positionToSet +  Vector2(randf_range(-2, 2), randf_range(-2, 2))).normalized()) * randi_range(200, 400)
	add_child(asteroidInstance)
	asteroidList.append(asteroidInstance)
	print(asteroidList.size())
	asteroidInstance.global_position = positionToSet
	asteroidInstance.get_node("Sprite2D").texture = asteroidSprites[spriteIndex]
	asteroidInstance.get_node("Sprite2D").scale = Vector2.ONE * scaleSize
	asteroidInstance.get_node("CollisionShape2D").scale = Vector2.ONE * (scaleSize + 0.05)
	asteroidInstance.linear_velocity = velocityToGive
	
