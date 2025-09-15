extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.instance.AffectMoney(30)
	Player.instance.AffectHealth(-25)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_timer_timeout() -> void:
	UIManager.instance.UpdateUplinkStatus(str("Tutorial"), true)
