extends Node2D

const deck_scene = preload("res://scenes/deck.tscn")
const options_scene = preload("res://scenes/options.tscn")
var commons := []
var uncommons := []
var rares := [['*', '*'], ['*', '*'], ['*', '*'], ['D', '*']]
var hovered

# Called when the node enters the scene tree for the first time.
func _ready():
	Autoload.in_game = false
	#play music
	$Music.play(randf())
	#enable touchscreen button
	if Autoload.touchscreen:
		$Confirm.visible = true
	#populate shop
	var common_values = ['R', 'S', 'D']
	var suits = ["clubs", "hearts", "spades", "diamonds"]
	for v in common_values:
		for s in suits:
			commons.append([v, s])
	for card in Autoload.special_cards:
		uncommons.append(card)
	commons.shuffle()
	uncommons.shuffle()
	rares.shuffle()
	update_card(commons[0], $Common)
	update_card(uncommons[0], $Uncommon)
	update_card(rares[0], $Rare)
	update_bank()
	update_deck()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func update_deck():
	$Deck.frame = 6 + (Autoload.player_card_back * 7)

func update_card(card, rarity):
	rarity.set_card(card)

func update_bank():
	$Bank/Amount.text = "x" + str(Autoload.player_gold)

func deck_menu(delete):
	Autoload.delete_card = delete
	var menu = deck_scene.instantiate()
	add_child(menu)
	menu.position = Vector2(0, 500)
	menu.deck_exited.connect(func(): self.set_position(Vector2(0, 0)))
	self.position = Vector2(0, -500)

func options_menu_exit():
	self.set_position(Vector2(0, 0))
	update_deck()

func trash_card():
	if Autoload.player_gold >= 5:
		$Blip.play()
		Autoload.player_gold -= 5
		deck_menu(true)
		update_bank()
		$Trash.queue_free()

func _on_card_hovered(card):
	hovered = card
	$CardName.text = card.card_name
	$CardDescription.text = card.description

func _on_card_unhovered(card):
	if $CardName.text == card.card_name:
		$CardName.text = ""
	if $CardDescription.text == card.description:
		$CardDescription.text = ""

func _on_trash_hovered():
	hovered = $Trash
	$CardName.text = "Trash"
	$CardDescription.text = "Select a card to remove from your deck."

func _on_trash_unhovered():
	if $CardName.text == "Trash":
		$CardName.text = ""
	if $CardDescription.text == "Select a card to remove from your deck.":
		$CardDescription.text = ""

func _on_trash_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not Autoload.touchscreen:
				trash_card()

func _on_card_clicked(card):
	var cost = 0
	if card == get_node_or_null("Common"):
		cost = 2
	elif card == get_node_or_null("Uncommon"):
		cost = 3
	elif card == get_node_or_null("Rare"):
		cost = 4
	if cost and Autoload.player_gold >= cost:
		$Blip.play()
		Autoload.player_gold -= cost
		Autoload.player_deck.append(card.shortcode())
		if cost == 3 and card.shortcode() not in Autoload.bought_cards:
			Autoload.bought_cards.append(card.shortcode())
			Autoload.save_game()
		update_bank()
		card.queue_free()
		_on_card_unhovered(card)

func _on_deck_hovered():
	$CardName.text = "Your Deck"
	$CardDescription.text = "View all the cards in your deck."

func _on_deck_unhovered():
	if $CardName.text == "Your Deck":
		$CardName.text = ""
	if $CardDescription.text == "View all the cards in your deck.":
		$CardDescription.text = ""

func _on_deck_clicked(_viewport, event, _shape_idx):
	var clicked = false
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clicked = true
	elif event is InputEventScreenTouch:
		if event.pressed and event.double_tap:
			clicked = true
	if clicked:
		deck_menu(false)

func _on_skip_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_skip_mouse_entered():
	$CardName.text = "Play Next Game"
	match Autoload.difficulty:
		0:
			$CardDescription.text = "Play against one opponent."
		1:
			$CardDescription.text = "Play against one hard opponent."
		2:
			$CardDescription.text = "Play against two opponents."
		3:
			$CardDescription.text = "Play against two opponents, one of which is hard."
		4:
			$CardDescription.text = "Play against two hard opponents."
		5:
			$CardDescription.text = "Play against three opponents."
		6:
			$CardDescription.text = "Play against three opponents, one of which is hard."
		7:
			$CardDescription.text = "Play against three opponents, two of which are hard."
		8:
			$CardDescription.text = "Play against three hard opponents."
		9:
			$CardDescription.text = "Play against the final boss. Good luck!"

func _on_skip_mouse_exited():
	if $CardName.text == "Play Next Game":
		$CardName.text = ""
		$CardDescription.text = ""

func _on_confirm_pressed():
	if hovered == $Trash:
		trash_card()
	else:
		_on_card_clicked(hovered)
	hovered = null

func _on_options_pressed():
	var options = options_scene.instantiate()
	add_child(options)
	options.get_node("Delete").queue_free()
	options.position = Vector2(0, 500)
	options.options_exited.connect(options_menu_exit)
	self.position = Vector2(0, -500)
