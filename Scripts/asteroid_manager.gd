class_name AsteroidManager
extends Node2D

const minDistance = 1350
const maxDistance = 1400

var asteroid = preload("res://Scenes/asteroid.tscn")
var missile = preload("res://Scenes/missile.tscn")
var ship = preload("res://Scenes/enemy_ship.tscn")

@export var asteroidSprites = Array([])

var asteroidList = Array([])
var asteroidSpawnCooldown = 0.0 # This will be set to one second so asteroids dont come piling in
var maxAsteroids = 5 # base is 5 currently
var missilesList = Array([])
var missileCooldown = 0.0
var maxMissiles = 5
var currentTimeInGameAsteroid = 0.0
var shipsList = Array([])
var shipCooldown = 15.0
var maxShips = 4
var canRemoveShipCool = false

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
	missileCooldown -= delta
	if canRemoveShipCool:
		shipCooldown -= delta
	currentTimeInGameAsteroid += delta
	
	if UIManager.instance.currentEvent != null && UIManager.instance.currentEvent.name == "Asteroid Hell":
		maxAsteroids = 45
	elif maxAsteroids == 45:
		maxAsteroids = 15
		
	if(currentTimeInGameAsteroid >= 60 && maxAsteroids < 35):
		currentTimeInGameAsteroid = 0
		maxAsteroids += 5
	if(UIManager.instance.currentEvent != null && UIManager.instance.currentEvent.name == "Homing Missiles"):
		if missilesList.size() < maxMissiles && missileCooldown <= 0:
			#print("yesok")
			missileCooldown = 2.0
			SpawnMissile()
	#print(str(shipsList.size(), " ", shipCooldown, " ", canRemoveShipCool))
	if(maxShips>shipsList.size() && shipCooldown<=0):
		shipCooldown = clampf(shipCooldown+20.0, -35, 40)
		SpawnShip()
		


func SpawnAsteroid() -> void:
	var asteroidInstance = asteroid.instantiate()
	var angle = 0
	if Player.instance.velocity.length() > 50:
		angle = atan2(Player.instance.velocity.normalized().y, Player.instance.velocity.normalized().x) + randf_range(-25, 25)
	else:
		angle = randf_range(0, 360)
	var angle2 = randf_range(0, 360)
	var positionToSet = Player.instance.position + Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle))) * randi_range(minDistance, maxDistance) # change this to min-max distance
	var spriteIndex = randi_range(0, asteroidSprites.size()-1)
	var velocityToGive = ((Player.instance.position - positionToSet +  Vector2(randf_range(-200, 200), randf_range(-200, 200))).normalized()) * randi_range(200, 400)
	var scaleSize = randf_range(0.32, 0.38)
	if UIManager.instance.currentEvent != null:
		if UIManager.instance.currentEvent.name == "Big Asteroids":
			scaleSize = randf_range(0.45, 0.5)
			velocityToGive = ((Player.instance.position - positionToSet +  Vector2(randf_range(-200, 200), randf_range(-200, 200))).normalized()) * randi_range(100, 150)
		elif UIManager.instance.currentEvent.name == "Small Asteroids":
			scaleSize = randf_range(0.24, 0.3)
			velocityToGive = ((Player.instance.position - positionToSet +  Vector2(randf_range(-200, 200), randf_range(-200, 200))).normalized()) * randi_range(450, 500)
	
	add_child(asteroidInstance)
	asteroidList.append(asteroidInstance)
	#print(asteroidList.size())
	asteroidInstance.global_position = positionToSet
	asteroidInstance.get_node("Sprite2D").texture = asteroidSprites[spriteIndex]
	asteroidInstance.get_node("Sprite2D").scale = Vector2.ONE * scaleSize
	asteroidInstance.get_node("CollisionShape2D").scale = Vector2.ONE * (scaleSize + 0.05)
	asteroidInstance.set_global_rotation_degrees(angle2)
	asteroidInstance.linear_velocity = velocityToGive

func RemoveAsteroid(toRemove: Asteroid) -> void:
	asteroidList.erase(toRemove)

func SpawnMissile() -> void:
	var missileInstance = missile.instantiate()
	var angle = randf_range(0, 360)
	var positionToSet = Player.instance.position + Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle))) * randi_range(minDistance + 100, maxDistance + 100)
	add_child(missileInstance)
	missilesList.append(missileInstance)
	missileInstance.global_position = positionToSet

func RemoveMissile(toRemove: Missile) -> void:
	missilesList.erase(toRemove)

func CanRemoveShipCoolSet(value: bool) -> void:
	print("ok")
	canRemoveShipCool = value

func SpawnShip() -> void:
	var shipInstance = ship.instantiate()
	var angle = randf_range(0.0, 360.0)
	var positionToSet = Player.instance.position + Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle))) * randi_range(minDistance + 500, maxDistance + 500)
	add_child(shipInstance)
	shipsList.append(shipInstance)
	shipInstance.global_position = positionToSet

func RemoveShip(toRemove: Ship) -> void:
	shipsList.erase(toRemove)
