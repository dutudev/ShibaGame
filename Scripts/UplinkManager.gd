#class_name  UplinkManager
extends Node2D
const uplinkLimitHeight = 7500
const uplinkLimitWidth = 7500

var uplinkScene = preload("res://Scenes/uplink_shop.tscn")
var currentTimer = 0.0
var currentState = uplinkState.idle
enum uplinkState {idle = 0, wait = 1, leave = 2}

#static var instance:

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentTimer = 5.0 # change to 30

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	currentTimer -= delta
	currentTimer = clamp(currentTimer, 0, 600)
	if currentState == 1:
		UIManager.instance.UpdateUplinkStatus(str("Next Uplink [img=24x24]res://Sprites/rss_feed.svg[/img] In : " , "%0.2f" % currentTimer , "s"), true)
	elif currentState == 2 && currentTimer <= 35:
		UIManager.instance.UpdateUplinkStatus(str("Uplink [img=24x24]res://Sprites/rss_feed.svg[/img] Leaving In : " , "%0.2f" % currentTimer , "s"), true)
	if currentTimer <= 0:
		NextState()


func NextState() -> void:
	currentState = (currentState + 1) % 3
	match currentState:
		uplinkState.idle:
			UIManager.instance.DeleteCurrentUplink()
			currentTimer = 5.0 # change to 30
			UIManager.instance.UpdateUplinkStatus(str("Uplink [img=24x24]res://Sprites/rss_feed.svg[/img] Leaving In : 0s"), false)
		uplinkState.wait:
			currentTimer = 5.0
			#change how we show text
			UIManager.instance.UpdateUplinkStatus(str("Next Uplink [img=24x24]res://Sprites/rss_feed.svg[/img] In : " , "%0.2f" % currentTimer , "s"), true)
		uplinkState.leave:
			currentTimer = 60.0 # 120
			var uplinkInstance = uplinkScene.instantiate()
			uplinkInstance.position = Vector2(randf_range(-uplinkLimitWidth, uplinkLimitWidth), randf_range(-uplinkLimitHeight, uplinkLimitHeight))
			add_child(uplinkInstance)
			UIManager.instance.SetUplink(uplinkInstance)
			#change how we show text
			UIManager.instance.UpdateUplinkStatus(str("Next Uplink [img=24x24]res://Sprites/rss_feed.svg[/img] In : 0s"), false)
