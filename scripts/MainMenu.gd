extends Node2D

var all_cards := []

# Called when the node enters the scene tree for the first time.
func _ready():
	Autoload.in_game = false
	new_card()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func new_card(_card = null):
	if not all_cards:
		for card in Autoload.standard_deck:
			all_cards.append(card.duplicate())
		for card in Autoload.special_cards:
			all_cards.append(card)
	all_cards.shuffle()
	$Card.set_card(all_cards.pop_front())

func _on_new_game_pressed():
	Autoload.reset()
	get_tree().change_scene_to_file("res://scenes/draft.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_options_pressed():
	get_tree().change_scene_to_file("res://scenes/options.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_mouse_entered():
	$Blip.play()
