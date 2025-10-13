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
@export var eventStatus: RichTextLabel
@export var eventPauseTitle: Label
@export var eventPauseDesc: Label
@export var anchorTexture: Texture2D

@export var balanceText: RichTextLabel
@export var chooseImages: Array[TextureRect]
@export var chooseTitles: Array[Label]
@export var chooseDesc: Array[Label]
@export var chooseButtons: Array[Button]

@export var endScreen : Control
@export var smallStats : RichTextLabel
@export var transScreen : Control


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
var animateEventStatus = false
var eventAnimateProgress = 0.0
var eventVisible = false

var currentUplink: Node = null
var cardChoice1: Card
var cardChoice2: Card
var cardChoice3: Card
var rerollPrice = 6
var currentCard: Card = null
var shopsLeftAnchor = 5 #5

var currentEvent: Event = null

var gameOver = false
var uplinksOpened = 0 # 0

var specialCardMat = preload("res://Shaders/SpecialCard.tres")

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
	if Input.is_action_just_pressed("pause") && !gameOver:
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
		deckTextStartPos = $"MainHud/Deck&Status/StatusContainer".position.y
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
			uplinkStatus.custom_minimum_size = Vector2(0, lerp(0, 30, clamp(EaseOutExpo(uplinkAnimateProgress), 0, 1)))
			uplinkStatus.self_modulate = Color(1, 1, 1, lerp(0, 1, clamp(EaseOutExpo(uplinkAnimateProgress - 0.2), 0, 1)))
		else:
			uplinkStatus.custom_minimum_size = Vector2(0, lerp(30, 0, clamp(EaseOutExpo(uplinkAnimateProgress - 0.2), 0, 1)))
			uplinkStatus.self_modulate = Color(1, 1, 1, lerp(1, 0, clamp(EaseOutExpo(uplinkAnimateProgress), 0, 1)))
		if clamp(EaseOutExpo(uplinkAnimateProgress - 0.2), 0, 1) == 1:
			animateUplinkStatus = false
	
	if animateEventStatus:
		eventAnimateProgress += delta
		if eventVisible:
			eventStatus.custom_minimum_size = Vector2(0, lerp(0, 30, clamp(EaseOutExpo(eventAnimateProgress), 0, 1)))
			eventStatus.self_modulate = Color(1, 1, 1, lerp(0, 1, clamp(EaseOutExpo(eventAnimateProgress - 0.2), 0, 1)))
		else:
			eventStatus.custom_minimum_size = Vector2(0, lerp(30, 0, clamp(EaseOutExpo(eventAnimateProgress - 0.2), 0, 1)))
			eventStatus.self_modulate = Color(1, 1, 1, lerp(1, 0, clamp(EaseOutExpo(eventAnimateProgress), 0, 1)))
		if clamp(EaseOutExpo(eventAnimateProgress - 0.2), 0, 1) == 1:
			animateEventStatus = false
	
	
	if currentUplink != null && !isOut:
		var dirToUplink = currentUplink.position - Player.instance.position
		if currentUplink.name == "AnchorPoint":
			$"MiddleHud(NotHideable)/Arrow/uplinkTooltip".text = "[img=24x24]res://Sprites/anchor.svg[/img]"
		else:
			$"MiddleHud(NotHideable)/Arrow/uplinkTooltip".text = "[img=24x24]res://Sprites/rss_feed.svg[/img]"
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
		$"MainHud/Deck&Status/StatusContainer".position.y = lerp(deckTextStartPos, 110.0, EaseOutExpo(clamp(deckProgress, 0 , 1)))
		if EaseOutExpo(clamp(deckProgress, 0 , 1)) == 1:
			isDeckHidden = true
			isDeckAnimating = false
	else:
		deckProgress += delta / deckDuration
		$"MainHud/Deck&Status".position.y = lerp(deckStartPos, 0.0, EaseOutExpo(clamp(deckProgress, 0 , 1)))
		$"MainHud/Deck&Status/StatusContainer".position.y = lerp(deckTextStartPos, 80.0, EaseOutExpo(clamp(deckProgress, 0 , 1)))
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
		rerollPrice = 6
		$ShopUi/Exit.text = "Leave Uplink"
		UpdateRerollText(rerollPrice)
		UpdateBalanceText()
		PrepareShop()
	$ShopUi/Choose/buy1.disabled = false
	$ShopUi/Choose2/buy2.disabled = false
	$ShopUi/Choose3/buy3.disabled = false
	if get_tree().current_scene.name == "Tutorial":
		$ShopUi/Choose/buy1.disabled = true
		$ShopUi/Choose3/buy3.disabled = true
		rerollPrice = 1000
		$ShopUi/Exit.text = "Leave Uplink"
		UpdateRerollText(rerollPrice)
		if currentUplink.name == "UplinkShop":
			cardChoice2 = Player.instance.allCards[2]
		else:
			cardChoice2 = Player.instance.allCards[3]
		for i in range(3):
				var cardChoiceCur: Card
				match i:
					0:
						cardChoiceCur = null
					1:
						cardChoiceCur = cardChoice2
					2:
						cardChoiceCur = null
				if cardChoiceCur == null:
					chooseImages[i].texture = null
					chooseTitles[i].text = ""
					chooseDesc[i].text = ""
					chooseButtons[i].text = ""
				else:
					chooseImages[i].texture = cardChoiceCur.cardIcon
					chooseTitles[i].text = cardChoiceCur.cardName
					chooseDesc[i].text = cardChoiceCur.cardDesc
					chooseButtons[i].text = str("Buy : " , cardChoiceCur.cardPrice, "$")
	$ShopUi.visible = open
	

func PrepareShop() -> void:
	
	#choose cards
	$ShopUi/Choose/buy1.disabled = false
	$ShopUi/Choose2/buy2.disabled = false
	$ShopUi/Choose3/buy3.disabled = false
	var anchokey = false
	var anchospot = 0
	
	if shopsLeftAnchor > 0:
		
		$ShopUi/anchorpointinfo.text = str("Anchor point [img=24x24]res://Sprites/anchor.svg[/img] available in " , shopsLeftAnchor , " shops")
	else:
		#print(shopsLeftAnchor)
		$ShopUi/anchorpointinfo.text = str("Anchor point key available in shop")
		anchospot = randi_range(0, 2)
		if randi_range(0, 5) == 0:
			anchokey = true
		#print(anchokey)
	if Player.instance.hasAnchorKey == true:
		$ShopUi/anchorpointinfo.text = str("You have Anchor point key")
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
		if Player.instance.CheckCardInDeck("Black Friday"):
			chooseButtons[i].text = str("Buy : " , cardChoiceCur.cardPrice * 3/4, "$")
		else:
			chooseButtons[i].text = str("Buy : " , cardChoiceCur.cardPrice, "$")
		if cardChoiceCur.special:
			chooseImages[i].material = specialCardMat
		else:
			chooseImages[i].material = null
	if anchokey && Player.instance.hasAnchorKey == false:
		chooseImages[anchospot].texture = anchorTexture
		chooseTitles[anchospot].text = "Anchor Key"
		chooseDesc[anchospot].text = "!This item does not store in deck!\nUse this item to open anchor points"
		chooseButtons[anchospot].text = str("Buy : 250$")
		chooseImages[anchospot].material = null
func _on_reroll_pressed() -> void:
	if Player.instance.money >= rerollPrice:
		Music.PlaySelectSound()
		Player.instance.AffectMoney(-rerollPrice)
		rerollPrice += 2
		UpdateBalanceText()
		UpdateRerollText(rerollPrice)
		PrepareShop()

func UpdateRerollText(price: int) -> void:
	$ShopUi/Reroll.text = str("Reroll : ", price, "$")

func UpdateBalanceText() -> void:
	balanceText.text = str("Balance : ", Player.instance.money , "$")

func _on_exit_pressed() -> void:
	Music.PlaySelectSound()
	if $ShopUi/Exit.text == "Leave Uplink":
		$ShopUi/Exit.text = "sure?"
	elif$ShopUi/Exit.text == "sure?":
		if get_tree().current_scene.name == "Tutorial":
			if currentUplink.name == "UplinkShop" && !Player.instance.CheckCardInDeck("Cannon Upgrade"):
				return
			if currentUplink.name == "UplinkShop2" && !Player.instance.CheckCardInDeck("Reinforced Metal"):
				return
		Player.instance.AffectHealth(25)
		shopsLeftAnchor -= 1
		get_tree().paused = false
		uplinksOpened += 1
		OpenShop(false, false)
		currentUplink.queue_free()
		currentUplink = null
		BoundsArrow.visible = false
		Player.instance.AffectHealth(0)
		$"MiddleHud(NotHideable)/Arrow/uplinkTooltip".visible = false

func OpenPause(open: bool) -> void:
	if open:
		$PauseMenu.visible = true
		if currentEvent != null:
			if currentEvent.difficulty == Event.diff.hard:
				eventPauseTitle.text = str("Current Event : ", currentEvent.name, " (hard)")
			else:
				eventPauseTitle.text = str("Current Event : ", currentEvent.name, " (easy)")
			eventPauseDesc.text = currentEvent.desc
		else:
			eventPauseTitle.text = "Current Event : None"
			eventPauseDesc.text = "There is no event taking place right now (womp womp)"
		currentCard = null
		$PauseMenu/Panel/Inventory/TextureRect.texture = null
		$PauseMenu/Panel/Inventory/cardTitle.text = "Click on item"
		$PauseMenu/Panel/Inventory/cardTitle2.text = "to see description or to sell it"
		$PauseMenu/Panel/Inventory/sellBtn.visible = false
		$PauseMenu/Panel/Inventory/card1/Image1.texture = getCardIcon(Player.instance.card1)
		$PauseMenu/Panel/Inventory/card2/Image1.texture = getCardIcon(Player.instance.card2)
		$PauseMenu/Panel/Inventory/card3/Image1.texture = getCardIcon(Player.instance.card3)
		if Player.instance.card1 != null && Player.instance.card1.special:
			$PauseMenu/Panel/Inventory/card1.material = specialCardMat
		else:
			$PauseMenu/Panel/Inventory/card1.material = null
		if Player.instance.card2 != null && Player.instance.card2.special:
			$PauseMenu/Panel/Inventory/card2.material = specialCardMat
		else:
			$PauseMenu/Panel/Inventory/card2.material = null
		if Player.instance.card3 != null && Player.instance.card3.special:
			$PauseMenu/Panel/Inventory/card3.material = specialCardMat
		else:
			$PauseMenu/Panel/Inventory/card3.material = null
	else :
		$PauseMenu.visible = false

func getCardIcon(target: Card) -> Texture2D:
	if target && target.cardIcon:
		return target.cardIcon
	return null

func SetUplink(uplink: Node) -> void:
	currentUplink = uplink

func _on_return_btn_pressed() -> void:
	Music.PlaySelectSound()
	if $ShopUi.visible:
		isPaused = false
		OpenPause(false)
	elif !$ShopUi.visible:
		isPaused = false
		get_tree().paused = false
		OpenPause(false)


func _on_exit_btn_pressed() -> void:
	Music.PlaySelectSound()
	transScreen.StartOutro("mainMenu")

func UpdateTopDeck() -> void:
	if Player.instance.card1 != null && Player.instance.card1.special:
		deckImages[0].get_parent().material = specialCardMat
	else:
		deckImages[0].get_parent().material = null
	if Player.instance.card2 != null && Player.instance.card2.special:
		deckImages[1].get_parent().material = specialCardMat
	else:
		deckImages[1].get_parent().material = null
	if Player.instance.card3 != null && Player.instance.card3.special:
		deckImages[2].get_parent().material = specialCardMat
	else:
		deckImages[2].get_parent().material = null
	deckImages[0].texture = getCardIcon(Player.instance.card1)
	deckImages[1].texture = getCardIcon(Player.instance.card2)
	deckImages[2].texture = getCardIcon(Player.instance.card3)
	
func BuyCard(cardToBuy: Card) -> bool:
	var x = 1
	if Player.instance.CheckCardInDeck("Black Friday"):
		x = 3.0/4.0
	if Player.instance.money >= cardToBuy.cardPrice * x:
		
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
			Player.instance.AffectMoney(-cardToBuy.cardPrice * x)
			Music.PlayBuySound()
			UpdateBalanceText()
			match card:
				0:
					Player.instance.card1 = cardToBuy
				1:
					Player.instance.card2 = cardToBuy
				2:
					Player.instance.card3 = cardToBuy
			UpdateTopDeck()
			if get_tree().current_scene.name != "Tutorial":
				Player.instance.RemoveAvailableCard(cardToBuy)
			return true
		else:
			return false
	else:
		return false


func _on_buy_1_pressed() -> void:
	if chooseTitles[0].text == "Anchor Key":
		if Player.instance.money >= 250:
			Player.instance.AffectMoney(-250)
			Music.PlayBuySound()
			UpdateBalanceText()
			Player.instance.hasAnchorKey = true
			get_tree().call_group("UplinkManager", "ChangeEventAnchorKey")
			$ShopUi/Choose/buy1.disabled = true
			return
	if BuyCard(cardChoice1):
		$ShopUi/Choose/buy1.disabled = true


func _on_buy_2_pressed() -> void:
	if chooseTitles[1].text == "Anchor Key":
		if Player.instance.money >= 250:
			Player.instance.AffectMoney(-250)
			Music.PlayBuySound()
			UpdateBalanceText()
			Player.instance.hasAnchorKey = true
			get_tree().call_group("UplinkManager", "ChangeEventAnchorKey")
			$ShopUi/Choose2/buy2.disabled = true
			return
	if BuyCard(cardChoice2):
		$ShopUi/Choose2/buy2.disabled = true
		if get_tree().current_scene.name == "Tutorial" && cardChoice2.cardName == "Reinforced Metal":
			get_tree().paused = false
			get_tree().change_scene_to_file("res://Scenes/main.tscn")
			#make anim here

func _on_buy_3_pressed() -> void:
	if chooseTitles[2].text == "Anchor Key":
		if Player.instance.money >= 250:
			Player.instance.AffectMoney(-250)
			Music.PlayBuySound()
			UpdateBalanceText()
			Player.instance.hasAnchorKey = true
			get_tree().call_group("UplinkManager", "ChangeEventAnchorKey")
			$ShopUi/Choose3/buy3.disabled = true
			#get_node("root/Main/UplinkManager").ChangeEventAnchorKey()
			return
	if BuyCard(cardChoice3):
		$ShopUi/Choose3/buy3.disabled = true


func _on_card_1_pressed() -> void:
	if Player.instance.card1 == null:
		return
	Music.PlaySelectSound()
	$PauseMenu/Panel/Inventory/TextureRect.texture = getCardIcon(Player.instance.card1)
	$PauseMenu/Panel/Inventory/cardTitle.text = Player.instance.card1.cardName
	$PauseMenu/Panel/Inventory/cardTitle2.text = Player.instance.card1.cardDesc
	if get_tree().current_scene.name == "Tutorial":
		$PauseMenu/Panel/Inventory/sellBtn.text = str("Sell (+", 40 ,"$)")
	else:
		$PauseMenu/Panel/Inventory/sellBtn.text = str("Sell (+", Player.instance.card1.cardPrice/3 ,"$)")
	$PauseMenu/Panel/Inventory/sellBtn.visible = true
	currentCard = Player.instance.card1


func _on_card_2_pressed() -> void:
	if Player.instance.card2 == null:
		return
	Music.PlaySelectSound()
	$PauseMenu/Panel/Inventory/TextureRect.texture = getCardIcon(Player.instance.card2)
	$PauseMenu/Panel/Inventory/cardTitle.text = Player.instance.card2.cardName
	$PauseMenu/Panel/Inventory/cardTitle2.text = Player.instance.card2.cardDesc
	if get_tree().current_scene.name == "Tutorial":
		$PauseMenu/Panel/Inventory/sellBtn.text = str("Sell (+", 40 ,"$)")
	else:
		$PauseMenu/Panel/Inventory/sellBtn.text = str("Sell (+", Player.instance.card2.cardPrice/3 ,"$)")
	$PauseMenu/Panel/Inventory/sellBtn.visible = true
	currentCard = Player.instance.card2


func _on_card_3_pressed() -> void:
	if Player.instance.card3 == null:
		return
	Music.PlaySelectSound()
	$PauseMenu/Panel/Inventory/TextureRect.texture = getCardIcon(Player.instance.card3)
	$PauseMenu/Panel/Inventory/cardTitle.text = Player.instance.card3.cardName
	$PauseMenu/Panel/Inventory/cardTitle2.text = Player.instance.card3.cardDesc
	if get_tree().current_scene.name == "Tutorial":
		$PauseMenu/Panel/Inventory/sellBtn.text = str("Sell (+", 40 ,"$)")
	else:
		$PauseMenu/Panel/Inventory/sellBtn.text = str("Sell (+", Player.instance.card3.cardPrice/3 ,"$)")
	$PauseMenu/Panel/Inventory/sellBtn.visible = true
	currentCard = Player.instance.card3


func _on_sell_btn_pressed() -> void:
	if currentCard != null && $PauseMenu/Panel/Inventory/sellBtn.text == "sure?":
		Player.instance.ChangeCardFromDeckToAvailable(currentCard)
		Music.PlaySelectSound()
		UpdateTopDeck()
		
		if get_tree().current_scene.name == "Tutorial":
			Player.instance.AffectMoney(40)
		else:
			Player.instance.AffectMoney(currentCard.cardPrice/3)
		currentCard = null
		UpdateBalanceText()
		$PauseMenu/Panel/Inventory/TextureRect.texture = null
		$PauseMenu/Panel/Inventory/cardTitle.text = "Click on item"
		$PauseMenu/Panel/Inventory/cardTitle2.text = "to see description or to sell it"
		$PauseMenu/Panel/Inventory/sellBtn.visible = false
		$PauseMenu/Panel/Inventory/card1/Image1.texture = getCardIcon(Player.instance.card1)
		$PauseMenu/Panel/Inventory/card2/Image1.texture = getCardIcon(Player.instance.card2)
		$PauseMenu/Panel/Inventory/card3/Image1.texture = getCardIcon(Player.instance.card3)
		Player.instance.AffectHealth(0)
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

func UpdateEventStatus(text: String, visible: bool):
	eventStatus.text = text
	if eventVisible != visible:
		eventAnimateProgress = 0.0
		if visible:
			eventStatus.self_modulate = Color(1, 1, 1, 0)
		else:
			eventStatus.self_modulate = Color(1, 1, 1, 1)
		animateEventStatus = true
		eventVisible = visible
	 # maybe add anim

func ResetCurrentEvent() -> void:
	currentEvent = null

func ChangeCurrentEvent(ev: Event) -> void:
	currentEvent = ev

func DeleteCurrentUplink() -> void:
	if currentUplink != null:
		currentUplink.queue_free()
		currentUplink = null
		BoundsArrow.visible = false
		$"MiddleHud(NotHideable)/Arrow/uplinkTooltip".visible = false


func GameOver() -> void:
	gameOver = true
	get_tree().paused = true
	endScreen.visible = true
	smallStats.text = str("Final score - " , Player.instance.money , "$\nUplinks [img=24x24]res://Sprites/rss_feed.svg[/img] opened - ", uplinksOpened)
func GameWin() -> void:
	Music.PlayWinSound()
	gameOver = true
	get_tree().paused = true
	$WinScreen.visible = true
	$WinScreen/smallStats.text = str("Final score - " , Player.instance.money , "$\nUplinks [img=24x24]res://Sprites/rss_feed.svg[/img] opened - ", uplinksOpened)

func _on_retry_pressed() -> void:
	Music.PlaySelectSound()
	transScreen.StartOutro("main")

func _on_main_menu_pressed() -> void:
	Music.PlaySelectSound()
	transScreen.StartOutro("mainMenu")



func EaseOutExpo(x: float) -> float:
	if x >= 0.95:
		return 1.0
	else:
		return 1 - pow(2, -10 * x)


func _on_exit_set_btn_pressed() -> void:
	Music.PlaySelectSound()
	$PauseMenu/SettingsMenu.visible = false


func _on_settings_btn_pressed() -> void:
	Music.PlaySelectSound()
	$PauseMenu/SettingsMenu.visible = true
