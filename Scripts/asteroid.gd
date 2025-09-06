class_name Asteroid
extends RigidBody2D


var maxDistance = 1400
var spawnCooldown = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	spawnCooldown -= delta
	
	if (Player.instance.position - position).length() > maxDistance && spawnCooldown < 0:
		spawnCooldown = 1
		#print((Player.instance.position - position).length() > maxDistance , " " , (Player.instance.position - position).length())
		var angle = randf_range(0, 360)
		freeze = true
		global_transform.origin = Player.instance.position + Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle))).normalized() * randi_range(AsteroidManager.instance.minDistance, AsteroidManager.instance.maxDistance)
		freeze = false
		linear_velocity = Vector2.ZERO
		linear_velocity = ((Player.instance.position - position +  Vector2(randf_range(-2, 2), randf_range(-2, 2))).normalized()) * randi_range(200, 300)
		#print((Player.instance.position - position).length())


func _on_tree_exiting() -> void:
	AsteroidManager.instance.RemoveAsteroid(self)


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		#removeHealth or sum
		queue_free()
