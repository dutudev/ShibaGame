extends Panel


var progress = -0.2
var initAnim = false
var outroAnim = false
var sceneNext

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.set_shader_parameter("progress", 0.0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#change this script to support transition out?
	if !initAnim:
		ShaderManager.set_process(true)
		progress += delta / 2
		material.set_shader_parameter("progress", clamp(EaseOutExpo(progress), 0.0, 1.0))
		if clamp(EaseOutExpo(progress), 0.0, 1.0) >= 1.0:
			visible = false
			initAnim = true
			ShaderManager.set_process(false)
			set_process(false)
	
	if outroAnim:
		ShaderManager.set_process(true)
		progress += delta / 2
		material.set_shader_parameter("progress", 1.0 - clamp(EaseOutExpo(progress), 0.0, 1.0))
		if clamp(EaseOutExpo(progress), 0.0, 1.0) >= 1.0:
			get_tree().paused = false
			get_tree().change_scene_to_file(str("res://Scenes/", sceneNext , ".tscn"))
			#var status = ResourceLoader.load_threaded_get_status(str("res://Scenes/", sceneNext, ".tscn"))
			#if status == ResourceLoader.THREAD_LOAD_LOADED:
			#	var scenePacked = ResourceLoader.load_threaded_get(str("res://Scenes/", sceneNext, ".tscn"))
				
			#	get_tree().change_scene_to_packed(scenePacked)


func StartOutro(scene: String) -> void:
	progress = 0.0
	outroAnim = true
	visible = true
	sceneNext = scene
	set_process(true)
	#ResourceLoader.load_threaded_request(str("res://Scenes/", sceneNext, ".tscn"))

func EaseOutExpo(x: float) -> float:
	if x >= 0.95:
		return 1.0
	else:
		return 1 - pow(2, -10 * x)
