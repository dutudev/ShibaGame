class_name Missile
extends RigidBody2D

var explosion = preload("res://Scenes/missile_explosion.tscn")
var target
var speed = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = Player.instance


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_rotation_degrees = rad_to_deg(atan2(linear_velocity.y, linear_velocity.x)) + 90

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var direction = target.position - position
	$AudioStreamPlayer2D.set_volume_linear(linear_to_db(lerp(0.0, 0.8, clamp(direction.length(), 400.0, 1400.0)/1400.0)))
	linear_velocity += direction.normalized() * speed
	if linear_velocity.length() >= 300 :
		linear_velocity = linear_velocity.normalized() * 300


func _on_tree_exiting() -> void:
	AsteroidManager.instance.RemoveMissile(self)


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		if !Player.instance.dashing:
			Player.instance.PlayHitSound()
			Player.instance.AffectHealth(-25)
			Player.instance.velocity = Player.instance.velocity.normalized() * Player.instance.velocity.length() / 2
			Player.instance.ToggleShield(true)
			var explosionInstance = explosion.instantiate()
			explosionInstance.global_position = position
			get_parent().add_child(explosionInstance)
		queue_free()
