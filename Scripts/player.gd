class_name Player
extends CharacterBody2D

const rotateStrength = 250
const mapHeight = 5000
const mapWidth = 5000

var baseBullet = preload("res://Scenes/player_bullet.tscn")

var forwardSpeed = 2
var maxSpeed = 350
var rotateDir = 0.0
var forwardStrength = 0.0

static var instance: Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#handle here special input that does not relate to physics
	if Input.is_action_just_pressed("shoot"):
		var bulletInstance = baseBullet.instantiate()
		get_parent().add_child(bulletInstance)
		bulletInstance.position = position + -transform.y.normalized() * 50
		bulletInstance.SetDirection(-transform.y.normalized())
	pass
	
	if abs(position.x) >= mapWidth || abs(position.y) >= mapHeight:
		print("out of bounds")
		#implement dying

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
	
	
