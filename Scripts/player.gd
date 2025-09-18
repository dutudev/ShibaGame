class_name Player
extends CharacterBody2D


const mapHeight = 8000
const mapWidth = 8000

var baseBullet = preload("res://Scenes/player_bullet.tscn")
@export var camera: Camera2D

var forwardSpeed = 4 # base is 4
var maxSpeed = 350 # base is 350
var maxHealth = 100 # base is 100
var rotateStrength = 250 # base is 250
var rotateDir = 0.0
var forwardStrength = 0.0
var dashing = false
var dashCooldown = 0.0
var currentDash = 0.0
var shieldCooldown = 0.0

var isInBounds = true
var health = 100 # base is 100
var cooldownSet = 1 # base is 1
var money = 0

var currentCooldown = 0
var stopShipSound = false

#cardManagement
@export var allCards: Array[Card]
var availableCards: Array[Card]
var card1: Card
var card2: Card
var card3: Card

static var instance: Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	availableCards = allCards
	instance = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#handle here special input that does not relate to physics
	if Input.is_action_just_pressed("shoot"):
		if currentCooldown >= cooldownSet:
			if CheckCardInDeck("Cannon Upgrade"):
				cooldownSet = 0.5
			else:
				cooldownSet = 1
			currentCooldown = 0
			var bulletInstance = baseBullet.instantiate()
			if CheckCardInDeck("Split Cannons"):
				var bulletInstance2 = baseBullet.instantiate()
				var bulletInstance3 = baseBullet.instantiate()
				get_parent().add_child(bulletInstance2)
				get_parent().add_child(bulletInstance3)
				bulletInstance2.position = position + -transform.y.normalized() * 50
				bulletInstance2.SetDirection(-transform.y.normalized().rotated(deg_to_rad(25)))
				bulletInstance3.position = position + -transform.y.normalized() * 50
				bulletInstance3.SetDirection(-transform.y.normalized().rotated(deg_to_rad(-25)))
			get_parent().add_child(bulletInstance)
			bulletInstance.position = position + -transform.y.normalized() * 50
			bulletInstance.SetDirection(-transform.y.normalized())
			$ShootSfx.pitch_scale = randf_range(0.9, 1.1)
			$ShootSfx.play()
	
	dashCooldown -= delta
	currentDash -= delta
	if Input.is_action_just_pressed("dash") && CheckCardInDeck("Dash") && dashCooldown <= 0:
		currentDash = 1.5
		dashing = true
		dashCooldown = 6
	
	if currentDash <= 0:
		dashing = false
	
	if dashing:
		$DashParticles.emitting = true
	else:
		$DashParticles.emitting = false
	
	shieldCooldown -= delta
	if shieldCooldown <= 0 && $Shield.visible:
		ToggleShield(false)
	
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
	
	#check input for sound
	if Input.is_action_just_pressed("go_forward") && !dashing:
		$EngineParticles.rotation_degrees = 90
		$EngineParticles.emitting = true
		if $ShipEngineSfx.playing:
			stopShipSound = false
			$ShipEngineSfx.pitch_scale = 1
		else:
			$ShipEngineSfx.volume_linear = 0.8
			$ShipEngineSfx.play()
			$ShipEngineSfx.pitch_scale = 1
			
	
	if Input.is_action_just_released("go_forward"):
		$EngineParticles.emitting = false
		stopShipSound = true
	
	
	if CheckCardInDeck("RCS System"):
			if Input.is_action_just_pressed("go_back"):
				$EngineParticles.rotation_degrees = -90
				$EngineParticles.emitting = true
				if $ShipEngineSfx.playing:
					stopShipSound = false
					$ShipEngineSfx.pitch_scale = 0.5
				else:
					$ShipEngineSfx.volume_linear = 0.8
					$ShipEngineSfx.pitch_scale = 0.8
					$ShipEngineSfx.play()
			if Input.is_action_just_released("go_back"):
				$EngineParticles.rotation_degrees = 90
				$EngineParticles.emitting = false
				stopShipSound = true
	else:
		$EngineParticles.rotation_degrees = 90
	
	
	if stopShipSound:
		$ShipEngineSfx.volume_linear = clamp($ShipEngineSfx.volume_linear - delta, 0, 0.8)
		if($ShipEngineSfx.volume_linear <= 0):
			$ShipEngineSfx.stop()
			stopShipSound = false
	elif $ShipEngineSfx.volume_linear < 0.8:
		$ShipEngineSfx.volume_linear = clamp($ShipEngineSfx.volume_linear + delta, 0, 0.8)
	
	#var zoomCam = lerp(0.5, 0.2, velocity.length()/450)
	#camera.zoom = Vector2.ONE * zoomCam

	
	

func _physics_process(delta: float) -> void:
	#Handle here everything physics related
	if CheckCardInDeck("Controller Jets"):
		rotateStrength = 400
	else:
		rotateStrength = 250
	
	if CheckCardInDeck("Enhanced Thrusters"):
		forwardSpeed = 8
		maxSpeed = 400 # base is 350
	else:
		forwardSpeed = 2 # base is 2
		maxSpeed = 350 # base is 350
	
	if !dashing:
		rotateDir = Input.get_action_strength("rotate_right") - Input.get_action_strength("rotate_left")
		forwardStrength = Input.get_action_strength("go_forward")
		velocity += -transform.y.normalized() * forwardSpeed * forwardStrength
		if CheckCardInDeck("RCS System"):
			var backStrength = Input.get_action_strength("go_back")
			velocity += transform.y.normalized() * forwardSpeed * backStrength
		rotate(deg_to_rad(rotateDir * rotateStrength) * delta)
		if velocity.length() > maxSpeed:
			velocity = velocity.normalized() * maxSpeed
	else:
		velocity = Vector2.UP.rotated(rotation) * 750
	#print(transform.y.normalized())
	
	
	if velocity.length() > 0:
		move_and_slide()

func AffectHealth(value: int) -> void:
	if CheckCardInDeck("Reinforced Metal"):
		maxHealth = 150
	else:
		maxHealth = 100
	health = clamp(health + value, 0, maxHealth)
	UIManager.instance.UpdateHealthBar(float(health)/float(maxHealth)*100.0)
	if health<=0:
		UIManager.instance.GameOver()
		#get_tree().change_scene_to_file("res://Scenes/main.tscn")
		# implement goodd dying

func ToggleShield(value: bool) -> void:
	if value && !$Shield.visible && shieldCooldown <= -5 && CheckCardInDeck("Shield"):
		shieldCooldown = 15
		$Shield.visible = true
		$Shield/Area2D/CollisionShape2D.set_deferred("disabled", false)
	elif !value:
		$Shield.visible = false
		$Shield/Area2D/CollisionShape2D.set_deferred("disabled", true)

func AffectMoney(value: int) -> void:
	money += value
	UIManager.instance.UpdateMoneyLabel(money)

func PlayHitSound() -> void:
	$HitSfx.pitch_scale = randf_range(0.9, 1.1)
	$HitSfx.play()

func RemoveAvailableCard(target: Card) -> void:
	var index = availableCards.find(target)
	if index != -1:
		availableCards.remove_at(index)

func ChangeCardFromDeckToAvailable(target: Card) -> void:
	if card1 == target:
		card1 = null
		availableCards.append(target)
	elif card2 == target:
		card2 = null
		availableCards.append(target)
	elif card3 == target:
		card3 = null
		availableCards.append(target)

func CheckCardInDeck(name: String) -> bool:
	if (card1 != null && name == card1.cardName) || (card2 != null &&  name == card2.cardName) || (card3 != null &&  name == card3.cardName):
		return true
	return false
