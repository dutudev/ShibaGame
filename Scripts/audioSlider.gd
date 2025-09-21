extends HSlider

var busIndex: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.get_bus_index(name)
	value_changed.connect(ChangeVolume)
	value = db_to_linear(AudioServer.get_bus_volume_db(busIndex))


func ChangeVolume(amount: float) -> void:
	AudioServer.set_bus_volume_db(
		busIndex,
		linear_to_db(amount)
	)
