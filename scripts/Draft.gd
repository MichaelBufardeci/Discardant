extends Node2D

const card_scene = preload("res://scenes/card.tscn")
var deck := []
var selected := false
var card_size := Vector2(0.95, 0.95)
var hovered

# Called when the node enters the scene tree for the first time.
func _ready():
	if Autoload.touchscreen:
		$Confirm.visible = true
	#create starting deck
	for card in Autoload.standard_deck:
		deck.append(card.duplicate())
	#add uncommons
	for i in range(Autoload.bought_cards.size()):
		deck.append(Autoload.bought_cards[i])
	offer_decks()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func offer_decks():
	var card
	var x = 40
	deck.shuffle()
	for n in range(13):
		for i in range(4):
			card = create_card(deck.pop_front())
			card.position = Vector2(x, 100 + (75 * i))
			card.add_to_group("deck" + str(i))
		x += 48

func create_card(card):
	var card_instance = card_scene.instantiate()
	card_instance.scale = card_size
	card_instance.set_card(card)
	add_child(card_instance)
	if not Autoload.touchscreen:
		card_instance.card_clicked.connect(deck_selected)
	card_instance.card_hovered.connect(card_hovered)
	card_instance.card_unhovered.connect(card_unhovered)
	return card_instance

func deck_selected(selected_card):
	if not selected:
		selected = true
		var selected_deck = selected_card.get_groups()[0]
		for card in get_tree().get_nodes_in_group(selected_deck):
			Autoload.player_deck.append(card.shortcode())
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func card_hovered(card):
	hovered = card
	$CardName.text = card.card_name
	$CardDescription.text = card.description
	card.z_index = 2
	card.scale = Vector2(1, 1)
	
func card_unhovered(card):
	if $CardName.text == card.card_name:
		$CardName.text = ""
	if $CardDescription.text == card.description:
		$CardDescription.text = ""
	card.z_index = 1
	card.scale = card_size

func _on_confirm_pressed():
	print(hovered.card_name)
	if hovered:
		deck_selected(hovered)
