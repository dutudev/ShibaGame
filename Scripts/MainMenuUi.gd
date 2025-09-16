extends Node2D

var logoAnimProgress = -1.0
var buttonsAnimProgress = -1.0
var animLogo = true
var animTrans = false
var transAnimProgress = 0.0
var sceneToGoTo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/buttons.modulate = Color(1, 1, 1, 0)
	$UI/Logo.material.set_shader_parameter("progress", 0.42)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animLogo:
		logoAnimProgress += delta / 1.5
		$UI/Logo.material.set_shader_parameter("progress", lerp(0.42, 0.58, clamp(logoAnimProgress, 0.0, 1.0)))
		if logoAnimProgress >= 1.0:
			animLogo = false
	elif buttonsAnimProgress <= 1:
		buttonsAnimProgress += delta / 0.8
		$UI/buttons.modulate = Color(1, 1, 1, lerp(0.0, 1.0, clamp(buttonsAnimProgress, 0.0, 1.0)))
	
	if animTrans:
		transAnimProgress += delta / 2
		$UI/Transition.material.set_shader_parameter("progress", lerp(0.0, 1.0, clamp(transAnimProgress, 0.0, 1.0)))
		if(transAnimProgress >= 1.5):
			get_tree().change_scene_to_file(str("res://Scenes/", sceneToGoTo , ".tscn"))
		

func _on_play_pressed() -> void:
	GoToScene("main")


func GoToScene(scene: String) -> void:
	if buttonsAnimProgress < 1:
		return
	sceneToGoTo = scene
	animTrans = true
	$UI/Transition.visible = true


func _on_tutorial_pressed() -> void:
	GoToScene("Tutorial")
