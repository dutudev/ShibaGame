class_name UIManager
extends CanvasLayer

@export var BoundsTimer: Timer
@export var BoundsTimerKill: Timer
@export var BoundsLabel: Label
@export var BoundsArrow: Control

@export var healthBar: ProgressBar
@export var cooldownBar: ProgressBar
@export var speedLabel: Label
@export var moneyLabel: Label

var isOut = false

static var instance: UIManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	BoundsLabel.visible = false
	BoundsArrow.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isOut:
		BoundsLabel.text = "Out Of Bounds\n" + str(int(ceil(BoundsTimerKill.time_left)))
		var dirToMiddle = Vector2.ZERO - Player.instance.position
		BoundsArrow.rotation_degrees = rad_to_deg(atan2(dirToMiddle.y, dirToMiddle.x))

func OutOfBounds(Out: bool) -> void:
	isOut = Out
	if Out:
		BoundsLabel.visible = true
		BoundsArrow.visible = true
		BoundsTimer.start()
		BoundsTimerKill.start(15)
	else:
		BoundsTimer.stop()
		BoundsTimerKill.stop()
		BoundsLabel.visible = false
		BoundsArrow.visible = false
		

func UpdateHealthBar(value: int) -> void:
	healthBar.value = value
	
func UpdateCooldownBar(value: float) -> void:
	cooldownBar.value = value

func UpdateSpeedLabel(value: int) -> void:
	speedLabel.text = str(value)

func UpdateMoneyLabel(value: int) -> void:
	moneyLabel.text = str(value) + "$"

func _on_BoundsTimer_timeout() -> void:
	BoundsLabel.visible = !BoundsLabel.visible
