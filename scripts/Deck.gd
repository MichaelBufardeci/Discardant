extends Node2D

signal deck_exited

const card_scene = preload("res://scenes/card.tscn")
var hovered

# Called when the node enters the scene tree for the first time.
func _ready():
	#change from "view deck" or "delete card"
	if Autoload.delete_card:
		if Autoload.touchscreen:
			$Confirm.visible = true
		$Delete.visible = true
		$View.visible = false
		$Skip.visible = false
	else:
		$Delete.visible = false
		$View.visible = true
		$Skip.visible = true
	#display deck
	var i = 0
	for card in Autoload.player_deck:
		var c = create_card(card)
		@warning_ignore("integer_division")
		c.position = Vector2(((i % 12) * 50) + 45, (int(i / 12) * 70) + 105 )
		i += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func create_card(card):
	var card_instance = card_scene.instantiate()
	card_instance.set_card(card)
	add_child(card_instance)
	card_instance.z_index = 10
	card_instance.card_clicked.connect(card_selected)
	card_instance.card_hovered.connect(card_hovered)
	card_instance.card_unhovered.connect(card_unhovered)
	return card_instance

func card_hovered(card):
	hovered = card

func card_unhovered(_card):
	pass

func card_selected(card):
	if Autoload.delete_card:
		Autoload.delete_card = false
		Autoload.player_deck.erase(card.shortcode())
		deck_exited.emit()
		queue_free()

func _on_skip_pressed():
	deck_exited.emit()
	queue_free()

func _on_confirm_pressed():
	if hovered:
		card_selected(hovered)
		hovered = null
