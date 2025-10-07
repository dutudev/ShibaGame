extends RigidBody2D

var health = 100.0
var hitMaterial
var rotationSpeed = 45.0
var maxSpeed = 375
var forwardSpeed = 4.0
var shootCooldown = 5.0
var moveForward = false
var playanim=0.0

var bulletScene = preload("res://Scenes/enemy_bullet.tscn")
var explosion = preload("res://Scenes/missile_explosion.tscn")
var asteroidParticles = preload("res://Scenes/asteroid_explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitMaterial = $Sprite2D.material.duplicate()
	$Sprite2D.material = hitMaterial
	hitMaterial.set_shader_parameter("progress", 0.0)


func _process(delta: float) -> void:
	shootCooldown -= delta
	if playanim > 0:
		hitMaterial.set_shader_parameter("progress", clamp(playanim,0.0,1.0))
		playanim -= delta/1.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	lookAtPlayerAndShoot(delta)
	

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var dist = Player.instance.position - position
	#print(moveForward)
	if dist.length() > 400.0 && moveForward:
		var forwardVec = -transform.y.normalized() * forwardSpeed
		linear_velocity += forwardVec
		if linear_velocity.length() > maxSpeed:
			linear_velocity = linear_velocity.normalized() * maxSpeed

func lookAtPlayerAndShoot(delta: float) -> void:
	var lookDir = Player.instance.position + Player.instance.velocity*0.5 - position
	var angleTarget = rad_to_deg(atan2(lookDir.y, lookDir.x))
	var angleDif = rad_to_deg(angle_difference(deg_to_rad(rotation_degrees - 90.0), deg_to_rad(angleTarget)))
	
	#print(lookDir.length())
	var angleDir = angleDif/abs(angleDif)
	if abs(angleDif) > 2:
		#print(angleDif)
		global_rotation_degrees = global_rotation_degrees + angleDir * rotationSpeed * delta
	
	moveForward = abs(angleDif) < 5
	$CPUParticles2D.emitting = moveForward
	
	if abs(angleDif) < 6 && lookDir.length() <= 950 && shootCooldown <= 0:
		Shoot()

func Shoot() -> void:
	shootCooldown = 5.0
	var bulInstance = bulletScene.instantiate()
	bulInstance.position = global_position + -transform.y.normalized() * 50
	get_parent().add_child(bulInstance)
	bulInstance.setDir(-transform.y.normalized())

func GetHit(hitHp: int) -> void:
	health-=hitHp
	
	if health<=0:
		var asteroidParInstance = asteroidParticles.instantiate()
		var explosionInstance = explosion.instantiate()
		asteroidParInstance.position = position
		explosionInstance.global_position = position
		explosionInstance.scale = Vector2(1.5, 1.5)
		explosionInstance.get_child(0).pitch_scale = 0.7
		get_parent().add_child(explosionInstance)
		get_parent().add_child(asteroidParInstance)
		queue_free()
	else:
		$MissileExplosion.emitting = false
		$MissileExplosion.emitting = true
		$AudioStreamPlayer2D.play()
		playanim=1.0
