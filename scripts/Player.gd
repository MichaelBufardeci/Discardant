extends Node2D

signal card_drawn
signal deck_hovered
signal deck_unhovered

const card_scene = preload("res://scenes/card.tscn")
var deck := []
var discard := []
var hand := []
var card_back := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func draw_card():
	var card
	#if deck is empty, shuffle discarded cards into deck
	if not deck:
		reshuffle_discard()
	#make sure deck still isn't empty
	if deck:
		if Autoload.suit_to_draw:
			for c in deck:
				if c.suit == Autoload.suit_to_draw:
					card = c
					deck.erase(c)
					break
		if not card:
			card = deck.pop_front()
		card.position = $DeckSprite.position
		hand.append(card)
		card.hoverable = true
		card.clickable = true
	card_drawn.emit()
	redraw_hand()
	redraw_deck()
	return card

func reshuffle_discard():
	for card in discard:
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", $DeckSprite.position, 0.25)
		tween.parallel().tween_property(card, "scale", Vector2(1,1), 0.25)
		tween.parallel().tween_property(card, "global_rotation", self.rotation, 0.25)
		tween.tween_callback(card.hide)
	deck = discard 
	deck.shuffle()
	discard = []

func redraw_hand():
	var card_spacing := 50
	if hand.size() > 6:
		@warning_ignore("integer_division")
		card_spacing = 295/(hand.size() - 1)
	for i in hand.size():
		var tween = create_tween()
		var final_position = Vector2(55 + (card_spacing * i), 5)
		hand[i].visible = true
		tween.tween_property(hand[i], "position", final_position, 0.25)
		tween.tween_callback(hand[i].show)
	return true

func redraw_deck():
	var frame
	match deck.size():
		0:
			frame = 0 
		_:
			@warning_ignore("integer_division")
			frame = (deck.size() / 3) + 1
	$DeckSprite.frame = frame + (card_back * 7)

func create_card(card):
	var card_instance = card_scene.instantiate()
	card_instance.visible = false
	card_instance.set_card(card)
	deck.push_front(card_instance)
	add_child(card_instance)
	return card_instance

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not Autoload.touchscreen:
				draw_card()

func _on_area_2d_mouse_entered():
	deck_hovered.emit(self)

func _on_area_2d_mouse_exited():
	deck_unhovered.emit(self)
