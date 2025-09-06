class_name Player
extends CharacterBody2D

const rotateStrength = 250
const mapHeight = 8000
const mapWidth = 8000

var baseBullet = preload("res://Scenes/player_bullet.tscn")

var forwardSpeed = 2
var maxSpeed = 350
var rotateDir = 0.0
var forwardStrength = 0.0

var isInBounds = true
var health = 100
var cooldownSet = 1
var money = 0

var currentCooldown = 0

static var instance: Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#handle here special input that does not relate to physics
	if Input.is_action_just_pressed("shoot"):
		if currentCooldown >= cooldownSet:
			currentCooldown = 0
			var bulletInstance = baseBullet.instantiate()
			get_parent().add_child(bulletInstance)
			bulletInstance.position = position + -transform.y.normalized() * 50
			bulletInstance.SetDirection(-transform.y.normalized())
	
	
	if abs(position.x) >= mapWidth || abs(position.y) >= mapHeight:
		#print("out of bounds")
		if isInBounds:
			UIManager.instance.OutOfBounds(true)
		isInBounds = false
		#implement dying
		
	elif !isInBounds:
		isInBounds = true
		UIManager.instance.OutOfBounds(false)
	
	if currentCooldown <= cooldownSet:
		UIManager.instance.UpdateCooldownBar(currentCooldown/cooldownSet*100)
	else:
		UIManager.instance.UpdateCooldownBar(100)
	
	currentCooldown += delta
	
	UIManager.instance.UpdateSpeedLabel(int(velocity.length()))

func _physics_process(delta: float) -> void:
	#Handle here everything physics related
	rotateDir = Input.get_action_strength("rotate_right") - Input.get_action_strength("rotate_left")
	forwardStrength = Input.get_action_strength("go_forward")
	
	velocity += -transform.y.normalized() * forwardSpeed * forwardStrength
	if velocity.length() > maxSpeed:
		velocity = velocity.normalized() * maxSpeed
	#print(transform.y.normalized())
	rotate(deg_to_rad(rotateDir * rotateStrength) * delta)
	
	if velocity.length() > 0:
		move_and_slide()

func AffectHealth(value: int) -> void:
	health += value
	UIManager.instance.UpdateHealthBar(health)
	if health<=0:
		pass # implement dying

func AffectMoney(value: int) -> void:
	money += value
	UIManager.instance.UpdateMoneyLabel(money)
