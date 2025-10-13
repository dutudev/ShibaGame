#class_name  UplinkManager
extends Node2D
const uplinkLimitHeight = 7500
const uplinkLimitWidth = 7500

var uplinkScene = preload("res://Scenes/uplink_shop.tscn")
var anchorPointScene = preload("res://Scenes/anchor_point.tscn")
var currentTimer = 0.0
var currentEventTimer = 0.0

@export var allEvents: Array[Event]
@export var anchorPointEvent : Event

var currentUplinkState = uplinkState.idle
var currentEventState = eventState.wait
var firstSfxEvent = false
var nextEvent
enum uplinkState {idle = 0, wait = 1, leave = 2}
enum eventState {wait = 0, show = 1, happen = 2}
var textFlickerTimer = 0.0
var isTextOn = true

#static var instance:

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentTimer = 10.0 # change to 30
	currentEventTimer = 30.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if UIManager.instance.currentEvent == null || (UIManager.instance.currentEvent.name != "Uplink Outage" && UIManager.instance.currentEvent.name != "Anchor Point"):
		currentTimer -= delta
	currentTimer = clamp(currentTimer, 0, 600)
	if currentUplinkState == 1:
		UIManager.instance.UpdateUplinkStatus(str("Next Uplink [img=24x24]res://Sprites/rss_feed.svg[/img] In : " , "%0.2f" % currentTimer , "s"), true)
	elif currentUplinkState == 2 && currentTimer <= 35:
		UIManager.instance.UpdateUplinkStatus(str("Uplink [img=24x24]res://Sprites/rss_feed.svg[/img] Leaving In : " , "%0.2f" % currentTimer , "s"), true)
	if currentTimer <= 0:
		NextState()
	
	currentEventTimer -= delta
	currentEventTimer = clamp(currentEventTimer,0, 600)
	if currentEventState == 0 && currentEventTimer <= 10:
		if !firstSfxEvent:
			Music.PlayEventSound()
			firstSfxEvent = true
		UIManager.instance.UpdateEventStatus(str("Random Event Starting In : ", "%0.2f" % currentEventTimer , "s"), true)
	elif currentEventState == 2 && currentEventTimer <= 30:
		UIManager.instance.UpdateEventStatus(str(nextEvent.name, " Stops In : ", "%0.2f" % currentEventTimer , "s"), true)
	if currentEventTimer <= 0:
		NextStateEvents()
		firstSfxEvent = false
	
	if UIManager.instance.uplinksOpened == 3 && textFlickerTimer < 2.5:
		textFlickerTimer -= delta
		if textFlickerTimer <= 0.0:
			textFlickerTimer = 0.5
			isTextOn = !isTextOn
			if isTextOn:
				UIManager.instance.UpdateUplinkStatus(str("! Enemy Ships Incoming !"), true)
				#print(AsteroidManager.instance.canRemoveShipCool)
			else:
				UIManager.instance.UpdateUplinkStatus(str(""), true)


func NextState() -> void:
	currentUplinkState = (currentUplinkState + 1) % 3
	match currentUplinkState:
		uplinkState.idle:
			UIManager.instance.DeleteCurrentUplink()
			currentTimer = 5.0 # change to 30
			if UIManager.instance.uplinksOpened == 3:
				UIManager.instance.UpdateUplinkStatus(str("! Enemy Ships Incoming !"), true)
				AsteroidManager.instance.canRemoveShipCool = true
				#print(AsteroidManager.instance.canRemoveShipCool)
				currentTimer = 15.0
				textFlickerTimer = 1.0
				isTextOn = true
				return
			UIManager.instance.UpdateUplinkStatus(str("Uplink [img=24x24]res://Sprites/rss_feed.svg[/img] Leaving In : 0s"), false)
		uplinkState.wait:
			currentTimer = 5.0
			textFlickerTimer = 5.0
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


func NextStateEvents() -> void:
	currentEventState = (currentEventState + 1) % 3
	match currentEventState:
		eventState.wait:
			currentEventTimer = 25.0
			if nextEvent != null:
				UIManager.instance.UpdateEventStatus(str(nextEvent.name, " Stops In : 0s"), false)
			else:
				UIManager.instance.UpdateEventStatus(str("Event Stops In : 0s"), false)
			UIManager.instance.ResetCurrentEvent()
		eventState.show:
			nextEvent = allEvents[randi_range(0, allEvents.size() - 1)]
			while(nextEvent == UIManager.instance.currentEvent): #fix this as the uimanager current event gets deleted after event finish
				nextEvent = allEvents[randi_range(0, allEvents.size() - 1)]
			#UIManager.instance.ChangeCurrentEvent(nextEvent)
			#currentTimer = nextEvent.duration
			if Player.instance.hasAnchorKey:
				nextEvent = anchorPointEvent
			currentEventTimer = 6.0
			UIManager.instance.UpdateEventStatus(str("Event Chosen : ", nextEvent.name), true)
		eventState.happen:
			UIManager.instance.ChangeCurrentEvent(nextEvent)
			currentEventTimer = nextEvent.duration
			if nextEvent.name == "Uplink Outage" || nextEvent.name == "Anchor Point":
				currentUplinkState = 2
				NextState()
			if nextEvent.name == "Anchor Point":
				var uplinkInstance = anchorPointScene.instantiate()
				uplinkInstance.position = Vector2(randf_range(-uplinkLimitWidth, uplinkLimitWidth), randf_range(-uplinkLimitHeight, uplinkLimitHeight))
				add_child(uplinkInstance)
				UIManager.instance.SetUplink(uplinkInstance)
			UIManager.instance.UpdateEventStatus(str("Event Chosen : ", nextEvent.name), false)
			

func ChangeEventAnchorKey() -> void:
	currentEventState = 0
	NextStateEvents()
