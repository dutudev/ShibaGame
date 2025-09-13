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

@export var deckStatus: Control
@export var deckImages: Array[TextureRect]
@export var uplinkStatus: RichTextLabel

@export var chooseImages: Array[TextureRect]
@export var chooseTitles: Array[Label]
@export var chooseDesc: Array[Label]
@export var chooseButtons: Array[Button]


var isOut = false
var isPaused = false

var cardChoice1: Card
var cardChoice2: Card
var cardChoice3: Card
var rerollPrice = 10

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
	if Input.is_action_pressed("pause"):
		if $ShopUi.visible && !isPaused:
			isPaused = true
			get_tree().paused = true
			OpenPause(true)
		elif $ShopUi.visible && isPaused:
			isPaused = false
			OpenPause(false)
		elif !$ShopUi.visible && !isPaused:
			isPaused = true
			get_tree().paused = true
			OpenPause(true)
		elif !$ShopUi.visible && isPaused:
			isPaused = false
			get_tree().paused = false
			OpenPause(false)

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

func _on_bounds_timer_kill_timeout() -> void:
	Player.instance.AffectHealth(-999)

func OpenShop(open: bool, prepareShop: bool) -> void:
	if prepareShop:
		PrepareShop()
	$ShopUi.visible = open

func PrepareShop() -> void:
	rerollPrice = 10
	$ShopUi/Exit.text = "Leave Uplink"
	UpdateRerollText(rerollPrice)
	#choose cards
	var cardToChooseFrom: Array
	cardToChooseFrom = Player.instance.availableCards.duplicate()
	var randomChoice = randi_range(0, cardToChooseFrom.size() - 1)
	cardChoice1 = cardToChooseFrom[randomChoice]
	cardToChooseFrom.remove_at(randomChoice)
	randomChoice = randi_range(0, cardToChooseFrom.size() - 1)
	cardChoice2 = cardToChooseFrom[randomChoice]
	cardToChooseFrom.remove_at(randomChoice)
	randomChoice = randi_range(0, cardToChooseFrom.size() - 1)
	cardChoice3 = cardToChooseFrom[randomChoice]
	cardToChooseFrom.remove_at(randomChoice)
	#SetShop
	for i in range(3):
		var cardChoiceCur: Card
		match i:
			0:
				cardChoiceCur = cardChoice1
			1:
				cardChoiceCur = cardChoice2
			2:
				cardChoiceCur = cardChoice3
		chooseImages[i].texture = cardChoiceCur.cardIcon
		chooseTitles[i].text = cardChoiceCur.cardName
		chooseDesc[i].text = cardChoiceCur.cardDesc
		chooseButtons[i].text = str("Buy : " , cardChoiceCur.cardPrice, "$")

func UpdateRerollText(price: int) -> void:
	$ShopUi/Reroll.text = str("Reroll : ", price, "$")

func _on_exit_pressed() -> void:
	if $ShopUi/Exit.text == "Leave Uplink":
		$ShopUi/Exit.text = "sure?"
	elif$ShopUi/Exit.text == "sure?":
		get_tree().paused = false
		OpenShop(false, false)
		#tell uplink to despawn

func OpenPause(open: bool) -> void:
	if open:
		$PauseMenu.visible = true
		$PauseMenu/Panel/Inventory/TextureRect.texture = null
		$PauseMenu/Panel/Inventory/cardTitle.text = "Click on item"
		$PauseMenu/Panel/Inventory/cardTitle2.text = "to see description or to sell it"
		$PauseMenu/Panel/Inventory/sellBtn.visible = false
		$PauseMenu/Panel/Inventory/card1/Image1.texture = getCardIcon(Player.instance.card1)
		$PauseMenu/Panel/Inventory/card2/Image1.texture = getCardIcon(Player.instance.card2)
		$PauseMenu/Panel/Inventory/card3/Image1.texture = getCardIcon(Player.instance.card3)
	else :
		$PauseMenu.visible = false

func getCardIcon(target: Card) -> Texture2D:
	if target && target.cardIcon:
		return target.cardIcon
	return null


func _on_return_btn_pressed() -> void:
	if $ShopUi.visible:
		isPaused = false
		OpenPause(false)
	elif !$ShopUi.visible:
		isPaused = false
		get_tree().paused = false
		OpenPause(false)




func BuyCard(cardToBuy: Card) -> bool:
	if Player.instance.money >= cardToBuy.cardPrice:
		
		var haveSpace = false
		var card = -1
		if Player.instance.card1 == null:
			haveSpace = true
			card = 0
		elif Player.instance.card2 == null:
			haveSpace = true
			card = 1
		elif Player.instance.card3 == null:
			haveSpace = true
			card = 2
		
		if haveSpace:
			Player.instance.money -= cardToBuy
			match card:
				0:
					Player.instance.card1 = cardToBuy
				1:
					Player.instance.card2 = cardToBuy
				2:
					Player.instance.card3 = cardToBuy
			return true
		else:
			return false
	else:
		return false


func _on_buy_1_pressed() -> void:
	if BuyCard(cardChoice1):
		$ShopUi/Choose/buy1.disabled = true


func _on_buy_2_pressed() -> void:
	if BuyCard(cardChoice2):
		$ShopUi/Choose2/buy2.disabled = true


func _on_buy_3_pressed() -> void:
	if BuyCard(cardChoice3):
		$ShopUi/Choose3/buy3.disabled = true
