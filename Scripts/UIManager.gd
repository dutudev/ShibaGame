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
var hideDeck = false
var isDeckHidden = false
var isDeckAnimating = false
var deckDuration = 0.0
var deckProgress = 0.0
var deckStartPos = 0.0
var deckTextStartPos = 0.0
var animateUplinkStatus = false
var uplinkAnimateProgress = 0.0
var uplinkVisible = false

var currentUplink: Node = null
var cardChoice1: Card
var cardChoice2: Card
var cardChoice3: Card
var rerollPrice = 10
var currentCard: Card = null


static var instance: UIManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	BoundsLabel.visible = false
	BoundsArrow.visible = false
	UpdateTopDeck()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isOut:
		BoundsLabel.text = "Out Of Bounds\n" + str(int(ceil(BoundsTimerKill.time_left)))
		var dirToMiddle = Vector2.ZERO - Player.instance.position
		BoundsArrow.rotation_degrees = rad_to_deg(atan2(dirToMiddle.y, dirToMiddle.x))
	if Input.is_action_just_pressed("pause"):
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
	if Input.is_action_just_pressed("hide_deck") && !get_tree().paused:
		hideDeck = !hideDeck
		deckStartPos = $"MainHud/Deck&Status".position.y
		deckTextStartPos = $"MainHud/Deck&Status/uplinkStatus".position.y
		if hideDeck:
			deckDuration = 1 - deckStartPos / -85.0 * 0.5
		else:
			deckDuration = deckStartPos / -85.0 * 0.5
		deckProgress = 0.0
		isDeckAnimating = true
	
	if isDeckAnimating && !get_tree().paused:
		HideDeck(delta)
	if animateUplinkStatus:
		uplinkAnimateProgress += delta
		if uplinkVisible:
			uplinkStatus.self_modulate = Color(1, 1, 1, lerp(0, 1, clamp(EaseOutExpo(uplinkAnimateProgress), 0, 1)))
		else:
			uplinkStatus.self_modulate = Color(1, 1, 1, lerp(1, 0, clamp(EaseOutExpo(uplinkAnimateProgress), 0, 1)))
		if clamp(EaseOutExpo(uplinkAnimateProgress), 0, 1) == 1:
			animateUplinkStatus = false
	
	if currentUplink != null && !isOut:
		var dirToUplink = currentUplink.position - Player.instance.position
		if dirToUplink.length() <= 750:
			BoundsArrow.visible = false
			$"MiddleHud(NotHideable)/Arrow/uplinkTooltip".visible = false
		else:
			BoundsArrow.visible = true
			$"MiddleHud(NotHideable)/Arrow/uplinkTooltip".visible = true
		BoundsArrow.rotation_degrees = rad_to_deg(atan2(dirToUplink.y, dirToUplink.x))
		$"MiddleHud(NotHideable)/Arrow/uplinkTooltip".rotation_degrees = -BoundsArrow.rotation_degrees

func HideDeck(delta: float) -> void:
	if hideDeck:
		deckProgress += delta / deckDuration
		$"MainHud/Deck&Status".position.y = lerp(deckStartPos, -85.0, EaseOutExpo(clamp(deckProgress, 0 , 1)))
		$"MainHud/Deck&Status/uplinkStatus".position.y = lerp(deckTextStartPos, 110.0, EaseOutExpo(clamp(deckProgress, 0 , 1)))
		if EaseOutExpo(clamp(deckProgress, 0 , 1)) == 1:
			isDeckHidden = true
			isDeckAnimating = false
	else:
		deckProgress += delta / deckDuration
		$"MainHud/Deck&Status".position.y = lerp(deckStartPos, 0.0, EaseOutExpo(clamp(deckProgress, 0 , 1)))
		$"MainHud/Deck&Status/uplinkStatus".position.y = lerp(deckTextStartPos, 80.0, EaseOutExpo(clamp(deckProgress, 0 , 1)))
		if EaseOutExpo(clamp(deckProgress, 0 , 1)) == 1:
			isDeckHidden = false
			isDeckAnimating = false

func OutOfBounds(Out: bool) -> void:
	isOut = Out
	if Out:
		BoundsLabel.visible = true
		BoundsArrow.visible = true
		$"MiddleHud(NotHideable)/Arrow/uplinkTooltip".visible = false
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
		rerollPrice = 10
		$ShopUi/Exit.text = "Leave Uplink"
		UpdateRerollText(rerollPrice)
		PrepareShop()
	$ShopUi/Choose/buy1.disabled = false
	$ShopUi/Choose2/buy2.disabled = false
	$ShopUi/Choose3/buy3.disabled = false
	$ShopUi.visible = open
	

func PrepareShop() -> void:
	
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


func _on_reroll_pressed() -> void:
	if Player.instance.money >= rerollPrice:
		Player.instance.AffectMoney(-rerollPrice)
		rerollPrice += 5
		UpdateRerollText(rerollPrice)
		PrepareShop()

func UpdateRerollText(price: int) -> void:
	$ShopUi/Reroll.text = str("Reroll : ", price, "$")

func _on_exit_pressed() -> void:
	if $ShopUi/Exit.text == "Leave Uplink":
		$ShopUi/Exit.text = "sure?"
	elif$ShopUi/Exit.text == "sure?":
		Player.instance.AffectHealth(25)
		get_tree().paused = false
		OpenShop(false, false)
		currentUplink.queue_free()
		currentUplink = null
		BoundsArrow.visible = false
		$"MiddleHud(NotHideable)/Arrow/uplinkTooltip".visible = false

func OpenPause(open: bool) -> void:
	if open:
		$PauseMenu.visible = true
		currentCard = null
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

func SetUplink(uplink: Node) -> void:
	currentUplink = uplink

func _on_return_btn_pressed() -> void:
	if $ShopUi.visible:
		isPaused = false
		OpenPause(false)
	elif !$ShopUi.visible:
		isPaused = false
		get_tree().paused = false
		OpenPause(false)

func UpdateTopDeck() -> void:
	deckImages[0].texture = getCardIcon(Player.instance.card1)
	deckImages[1].texture = getCardIcon(Player.instance.card2)
	deckImages[2].texture = getCardIcon(Player.instance.card3)
	
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
			Player.instance.AffectMoney(-cardToBuy.cardPrice)
			match card:
				0:
					Player.instance.card1 = cardToBuy
				1:
					Player.instance.card2 = cardToBuy
				2:
					Player.instance.card3 = cardToBuy
			UpdateTopDeck()
			Player.instance.RemoveAvailableCard(cardToBuy)
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


func _on_card_1_pressed() -> void:
	if Player.instance.card1 == null:
		return
	$PauseMenu/Panel/Inventory/TextureRect.texture = getCardIcon(Player.instance.card1)
	$PauseMenu/Panel/Inventory/cardTitle.text = Player.instance.card1.cardName
	$PauseMenu/Panel/Inventory/cardTitle2.text = Player.instance.card1.cardDesc
	$PauseMenu/Panel/Inventory/sellBtn.text = str("Sell (+", Player.instance.card1.cardPrice/3 ,"$)")
	$PauseMenu/Panel/Inventory/sellBtn.visible = true
	currentCard = Player.instance.card1


func _on_card_2_pressed() -> void:
	if Player.instance.card2 == null:
		return
	$PauseMenu/Panel/Inventory/TextureRect.texture = getCardIcon(Player.instance.card2)
	$PauseMenu/Panel/Inventory/cardTitle.text = Player.instance.card2.cardName
	$PauseMenu/Panel/Inventory/cardTitle2.text = Player.instance.card2.cardDesc
	$PauseMenu/Panel/Inventory/sellBtn.text = str("Sell (+", Player.instance.card2.cardPrice/3 ,"$)")
	$PauseMenu/Panel/Inventory/sellBtn.visible = true
	currentCard = Player.instance.card2


func _on_card_3_pressed() -> void:
	if Player.instance.card3 == null:
		return
	$PauseMenu/Panel/Inventory/TextureRect.texture = getCardIcon(Player.instance.card3)
	$PauseMenu/Panel/Inventory/cardTitle.text = Player.instance.card3.cardName
	$PauseMenu/Panel/Inventory/cardTitle2.text = Player.instance.card3.cardDesc
	$PauseMenu/Panel/Inventory/sellBtn.text = str("Sell (+", Player.instance.card3.cardPrice/3 ,"$)")
	$PauseMenu/Panel/Inventory/sellBtn.visible = true
	currentCard = Player.instance.card3


func _on_sell_btn_pressed() -> void:
	if currentCard != null && $PauseMenu/Panel/Inventory/sellBtn.text == "sure?":
		Player.instance.ChangeCardFromDeckToAvailable(currentCard)
		UpdateTopDeck()
		Player.instance.AffectMoney(currentCard.cardPrice/3)
		currentCard = null
		$PauseMenu/Panel/Inventory/TextureRect.texture = null
		$PauseMenu/Panel/Inventory/cardTitle.text = "Click on item"
		$PauseMenu/Panel/Inventory/cardTitle2.text = "to see description or to sell it"
		$PauseMenu/Panel/Inventory/sellBtn.visible = false
		$PauseMenu/Panel/Inventory/card1/Image1.texture = getCardIcon(Player.instance.card1)
		$PauseMenu/Panel/Inventory/card2/Image1.texture = getCardIcon(Player.instance.card2)
		$PauseMenu/Panel/Inventory/card3/Image1.texture = getCardIcon(Player.instance.card3)
	elif currentCard != null:
		$PauseMenu/Panel/Inventory/sellBtn.text = "sure?"

func UpdateUplinkStatus(text: String, visible: bool):
	uplinkStatus.text = text
	if uplinkVisible != visible:
		uplinkAnimateProgress = 0.0
		if visible:
			uplinkStatus.self_modulate = Color(1, 1, 1, 0)
		else:
			uplinkStatus.self_modulate = Color(1, 1, 1, 1)
		animateUplinkStatus = true
		uplinkVisible = visible
	 # maybe add anim


func DeleteCurrentUplink() -> void:
	if currentUplink != null:
		currentUplink.queue_free()
		currentUplink = null
		BoundsArrow.visible = false
		$"MiddleHud(NotHideable)/Arrow/uplinkTooltip".visible = false

func EaseOutExpo(x: float) -> float:
	if x == 1:
		return 1.0
	else:
		return 1 - pow(2, -10 * x)
