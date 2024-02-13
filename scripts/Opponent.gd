extends "res://scripts/Player.gd"

signal card_played

var hard_mode := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func create_card(card):
	var c = super.create_card(card)
	c.set_sprite(get_card_back_name())
	c.clickable = false
	c.hoverable = false

func take_turn(active):
	var wait_time = randfn(Autoload.game_speed, 0.05)
	if wait_time < 0:
		wait_time = 0
	await get_tree().create_timer(wait_time).timeout
	var card_to_play
	if hard_mode:
		#if the active isn't a wild...
		if active.suit.size() == 1:
			#..try to play a card of the same suit that isn't wild...
			for card in hand:
				if card.suit.size() == 1:
					if card.suit[0] in active.suit:
						card_to_play = card
						break
			#..then try to play a card with the same value that isn't wild
			if not card_to_play:
				for card in hand:
					if card.value.size() == 1:
						if card.value[0] in active.value:
							card_to_play = card
							break
		#if the active card is a wild, try to play a non-wild on it
		else:
			for card in hand:
				if card.suit.size() == 1 and card.value.size() == 1:
					if not active or card.compare(active):
						card_to_play = card
						break
	#finally try to play any card
	if not card_to_play:
		for card in hand:
			if active == null or card.compare(active):
				card_to_play = card
				break
	#play a card if we can...
	if card_to_play:
		card_played.emit(card_to_play)
	#...otherwise draw a card
	else:
		draw_card()

func draw_card():
	var card = super.draw_card()
	card.set_sprite(get_card_back_name())
	card.hoverable = false
	card.clickable = false

func get_card_back_name():
	match card_back:
		0:
			return "Blue Back"
		1:
			return "Red Back"
		2:
			return "Green Back"
		3:
			return "Black Back"
		4:
			return "Gold Back"
		_:
			return "Blue Back"

#need to overwrite method that draws when you click on opponent's deck
func _on_area_2d_input_event(_viewport, _event, _shape_idx):
	pass
