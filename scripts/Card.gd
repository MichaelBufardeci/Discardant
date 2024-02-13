extends Node2D

signal card_clicked(card)
signal card_hovered(card)
signal card_unhovered(card)

var value := []
var suit := []
var card_name := ""
var description := ""
var clickable := true
var hoverable := true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_card(card):
	if card is Array:
		self.set_variables(card[0], card[1])
	elif card is String:
		self.set_special_variables(card)
	self.set_sprite()

func set_variables(v, s):
	if not v and not s:
		set_special_variables()
		return
	if v == "*":
		self.value = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'R', 'S', 'D']
		self.card_name = "Wild"
	else:
		self.value = [v]
		self.card_name = num_to_string(v)
	self.card_name += " of "
	if s == '*':
		if v == 'D':
			self.value = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'R', 'S', 'D']
		self.suit = ["clubs", "hearts", "spades", "diamonds"]
		self.card_name += "Wilds"
	else:
		self.suit = [s]
		self.card_name += s.capitalize()
	if self.card_name == "Wild of Wilds":
		self.card_name = "Wild"
		self.description = "Play on any card. Any card can be played on this."
	elif self.card_name == "Draw of Wilds":
		self.card_name = "Wild Draw 4"
		self.description = "Play on any card. "
		self.description += "The next player draws 4 cards before taking their turn. "
		#self.description += "Any card can be played on this."
	elif self.card_name.begins_with("Draw of "):
		self.card_name = self.card_name.trim_prefix("Draw of ")
		self.card_name += " Draw 2"
		self.description = "Play on any " + suit_to_text(self.suit[0]) + " or any Draw 2. "
		self.description += "The next player draws 2 cards before taking their turn."
	elif self.card_name.begins_with("Reverse of "):
		self.card_name = self.card_name.trim_prefix("Reverse of ")
		self.card_name += " Reverse"
		self.description = "Play on any " + suit_to_text(self.suit[0]) + " or any Reverse. "
		self.description += "The turn order is reversed."
	elif self.card_name.begins_with("Skip of "):
		self.card_name = self.card_name.trim_prefix("Skip of ")
		self.card_name += " Skip"
		self.description = "Play on any " + suit_to_text(self.suit[0]) + " or any Skip. "
		self.description += "The next player skips their next turn."
	else:
		self.description = "Play on any " + num_to_string(self.value[0])
		self.description += " or any " + suit_to_text(self.suit[0]) + "."

func set_special_variables(card = null):
	if not card:
		card = self.card_name
	else:
		self.card_name = card
	match card:
		"Time Walk":
			self.suit = ["diamonds"]
			self.description = "Play on any " + suit_to_text(self.suit[0]) + "."
			self.description += " Take another turn after this one."
		"Credit Card":
			self.suit = ["clubs"]
			self.description = "Play on any " + suit_to_text(self.suit[0]) + "."
			self.description += " Gain 1 gold."
		"Warcry":
			self.suit = ["hearts"]
			self.description = "Play on any " + suit_to_text(self.suit[0]) + "."
			self.description += " You draw 1 card,"
			self.description += " then put a card from your hand on top of your deck."
		"The Firelord":
			self.value = ['8']
			self.description = "Play on any " + num_to_string(self.value[0]) + "."
			self.description += " Each turn this is on top of the pile,"
			self.description += " another player draws 4 cards."
		"Dark Meltizard":
			self.suit = ["spades"]
			self.description = "Play on any " + suit_to_text(self.suit[0]) + "."
			self.description += " While this is on top of the pile, players will draw Hearts"
			self.description += " if possible."

func set_sprite(card = null):
	var spriteIndex = 57
	if not card:
		card = self.card_name
	match card:
		"Wild":
			spriteIndex = 48
		"Wild Draw 4":
			spriteIndex = 49
		"Time Walk":
			spriteIndex = 61
		"Credit Card":
			spriteIndex = 62
		"Warcry":
			spriteIndex = 63
		"The Firelord":
			spriteIndex = 64
		"Dark Meltizard":
			spriteIndex = 65
		"Gold Back":
			spriteIndex = 55
		"Blue Back":
			spriteIndex = 56
		"Red Back":
			spriteIndex = 57
		"Green Back":
			spriteIndex = 58
		"Black Back":
			spriteIndex = 59
		_:
			match self.suit[0]:
				'clubs':
					spriteIndex = 0
				'hearts':
					spriteIndex = 12
				'spades':
					spriteIndex = 24
				'diamonds':
					spriteIndex = 36
			match self.value[0]:
				'R':
					spriteIndex += 9
				'S':
					spriteIndex += 10
				'D':
					spriteIndex += 11
				_:
					spriteIndex += int(self.value[0]) - 1
	$Sprite2D.frame = spriteIndex

#converts value to readable string
func num_to_string(num):
	match num:
		'1':
			return "Ace"
		'2':
			return "Two"
		'3':
			return "Three"
		'4':
			return "Four"
		'5':
			return "Five"
		'6':
			return "Six"
		'7':
			return "Seven"
		'8':
			return "Eight"
		'9':
			return "Nine"
		'R':
			return "Reverse"
		'S':
			return "Skip"
		'D':
			return "Draw"
		_:
			return ""

func suit_to_text(suit_name):
	match suit_name:
		"clubs":
			return "Club"
		"hearts":
			return "Heart"
		"spades":
			return "Spade"
		"diamonds":
			return "Diamond"
		_:
			return ""

func compare(c):
	for x in c.suit:
		if x in self.suit:
			return true
	for x in c.value:
		if x in self.value:
			return true
	return false
	
func shortcode():
	var special_cards = ["Time Walk", "Credit Card", "Warcry", "The Firelord", "Dark Meltizard"]
	if self.card_name in special_cards:
		return self.card_name
	elif self.card_name.contains("Wild"):
		if self.card_name.contains("Draw 4"):
			return ['D', '*']
		else:
			return ['*', '*']
	else:
		return [self.value[0], self.suit[0]]

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if clickable and event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not Autoload.touchscreen:
				card_clicked.emit(self)

func _on_area_2d_mouse_entered():
	if hoverable:
		card_hovered.emit(self)

func _on_area_2d_mouse_exited():
	if hoverable:
		card_unhovered.emit(self)
