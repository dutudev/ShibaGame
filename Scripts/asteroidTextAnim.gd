extends Label

var duration = 3
var progress = 0
var lerpProgress = 0
var posy = 0

@export var asteroidExplodeSfx = Array([])
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	posy = position.y
	$AsteroidHitSfx.stream = asteroidExplodeSfx[randi_range(0, 2)]
	$AsteroidHitSfx.pitch_scale = randf_range(0.9, 1.1)
	$AsteroidHitSfx.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if lerpProgress<=1:
		position = Vector2(position.x, posy + lerp(0.0, -40.0, lerpProgress))
	if progress-duration>=1:
		queue_free()
	progress += delta
	lerpProgress = EaseOutExpo(progress/duration)

func EaseOutExpo(x: float) -> float:
	if x == 1:
		return 1.0
	else:
		return 1 - pow(2, -10 * x)
