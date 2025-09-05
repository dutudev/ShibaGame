extends CharacterBody2D

const rotateStrength = 250
const forwardSpeed = 2
const maxSpeed = 150

var rotateDir = 0.0
var forwardStrength = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#print(rotateDir)

func _physics_process(delta: float) -> void:
	#velocity = Vector2.ZERO
	rotateDir = Input.get_action_strength("rotate_right") - Input.get_action_strength("rotate_left")
	forwardStrength = Input.get_action_strength("go_forward")
	
	velocity += -transform.y.normalized() * forwardSpeed * forwardStrength
	if velocity.length() > maxSpeed:
		velocity = velocity.normalized() * maxSpeed
	#print(transform.y.normalized())
	rotate(deg_to_rad(rotateDir * rotateStrength) * delta)
	
	if velocity.length() > 0:
		move_and_slide()
	
	
