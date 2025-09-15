extends Node2D

const distanceToOpen = 400

var currentAnimStatus = animStatus.down
var canOpen = false
var duration = 1
var currentAnimDuration = 0
var posYLabel
var startPosY
var startScale

enum animStatus {animateUp, animateDown, up, down}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	posYLabel = $Label.position.y
	$Label.scale = Vector2.ZERO
	startScale = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Player.instance.position - position).length() <= distanceToOpen:
		if(!canOpen):
			#animation
			currentAnimStatus = animStatus.animateUp
			currentAnimDuration = 0
			duration = abs($Label.position.y - 255.0) / abs(-255.0  + posYLabel) * 1
			startPosY = $Label.position.y
			startScale = $Label.scale.x
			
		canOpen = true
	else:
		if canOpen:
			#animation
			currentAnimStatus = animStatus.animateDown
			currentAnimDuration = 0
			duration = abs($Label.position.y - 28.5) / abs(-255.0  + posYLabel) * 1
			startPosY = $Label.position.y
			startScale = $Label.scale.x
		canOpen = false
	
	if canOpen && currentAnimStatus == animStatus.animateUp:
		currentAnimDuration += delta
		$Label.position = Vector2($Label.position.x, lerp(startPosY, -255.0, EaseOutExpo(clamp(currentAnimDuration/duration, 0.0, 1.0))))
		var curScale = lerp(startScale, 1.0, EaseOutExpo(clamp(currentAnimDuration/duration, 0.0, 1.0)))
		$Label.scale = Vector2(curScale, curScale)
		if EaseOutExpo(clamp(currentAnimDuration/duration, 0.0, 1.0)) >= 1:
			currentAnimStatus = animStatus.up
	elif !canOpen && currentAnimStatus == animStatus.animateDown:
		currentAnimDuration += delta
		$Label.position = Vector2($Label.position.x, lerp(startPosY, -28.5, EaseOutExpo(clamp(currentAnimDuration/duration, 0.0, 1.0))))
		var curScale = lerp(startScale, 0.0, EaseOutExpo(clamp(currentAnimDuration/duration, 0.0, 1.0)))
		$Label.scale = Vector2(curScale, curScale)
		if EaseOutExpo(clamp(currentAnimDuration/duration, 0.0, 1.0)) >= 1:
			currentAnimStatus = animStatus.down
	
	
	if canOpen && Input.is_action_just_pressed("open_shop"):
		if(get_tree().current_scene.name == "Tutorial"):
			UIManager.instance.currentUplink = self
			UIManager.instance.OpenShop(true, false)
			get_tree().paused = true
			return
		UIManager.instance.OpenShop(true, true)
		get_tree().paused = true
		UIManager.instance.currentUplink = self

func EaseOutExpo(x: float) -> float:
	if x == 1:
		return 1.0
	else:
		return 1 - pow(2, -10 * x)


func _on_tree_exiting() -> void:
	if(get_tree().current_scene.name == "Tutorial"):
			return
	if get_parent().currentState == 2:
		get_parent().currentTimer = 0
