extends Node2D

const screen_size = Vector2(640, 480)
const options_scene = preload("res://scenes/options.tscn")
var active 
var endgame := true
var players := []
var opponents := []
var turn_direction := 1
var player_turn := false
var skip := 0
var draw_amount := 0
var go_again := false
var warcry := false
var hovered

# Called when the node enters the scene tree for the first time.
func _ready():
	#set fkag
	Autoload.in_game = true
	#turn on music
	$Music.play(Autoload.music_location)
	#enable touchscreen button
	if Autoload.touchscreen:
		$Confirm.visible = true
	#get players
	get_players_and_opponents()
	#set difficulty
	if Autoload.difficulty <= 1:
		$OpponentL.queue_free()
		$OpponentL.remove_from_group("opponents")
		$OpponentL.remove_from_group("players")
		$OpponentR.queue_free()
		$OpponentR.remove_from_group("opponents")
		$OpponentR.remove_from_group("players")
		get_players_and_opponents()
		if Autoload.difficulty == 1:
			$OpponentC.hard_mode = true
	elif Autoload.difficulty <= 4:
		$OpponentC.queue_free()
		$OpponentC.remove_from_group("opponents")
		$OpponentC.remove_from_group("players")
		get_players_and_opponents()
		if Autoload.difficulty == 3:
			opponents = get_tree().get_nodes_in_group("opponents")
			opponents.shuffle()
			opponents[0].hard_mode = true
		elif Autoload.difficulty == 4:
			$OpponentL.hard_mode = true
			$OpponentR.hard_mode = true
	else:
		match Autoload.difficulty:
			6:
				opponents.shuffle()
				opponents[0].hard_mode = true
			7:
				opponents.shuffle()
				opponents[0].hard_mode = true
				opponents[1].hard_mode = true
			8:
				$OpponentL.hard_mode = true
				$OpponentC.hard_mode = true
				$OpponentR.hard_mode = true
			9:
				$OpponentL.queue_free()
				$OpponentL.remove_from_group("opponents")
				$OpponentL.remove_from_group("players")
				$OpponentR.queue_free()
				$OpponentR.remove_from_group("opponents")
				$OpponentR.remove_from_group("players")
				get_players_and_opponents()
				$OpponentC.hard_mode = true
	#set card backs:
	$Player.card_back = Autoload.player_card_back
	var backs = []
	for i in range(4):
		backs.append(i)
	backs.erase(Autoload.player_card_back)
	backs.shuffle()
	opponents.shuffle()
	for opponent in opponents:
		opponent.card_back = backs.pop_front()
	if Autoload.difficulty == 9:
		$OpponentC.card_back = 4
	#load player's deck
	for card in Autoload.player_deck:
		create_card(card, $Player)
	#create cards
	var cards = []
	for card in Autoload.standard_deck:
		cards.append(card.duplicate())
	for card in Autoload.player_deck:
		cards.erase(card)
	cards.shuffle()
	#deal decks
	for i in range(13):
		for opponent in opponents:
			create_card(cards.pop_front(), opponent)
			if not cards:
				break
		if not cards:
				break
	if Autoload.difficulty == 9:
		$OpponentC.deck = []
		var common_values = ['S', 'D']
		var suits = ["clubs", "hearts", "spades", "diamonds"]
		for v in common_values:
			for s in suits:
				create_card([v, s], $OpponentC)
		for card in Autoload.special_cards:
			create_card(card, $OpponentC)
		create_card(['D', '*'], $OpponentC)
		create_card(['*', '*'], $OpponentC)
		$OpponentC.deck.shuffle()
		while $OpponentC.deck.size() > 13:
			$OpponentC.deck.pop_front()
	for player in players:
		player.deck.shuffle()
	#draw starting card
	make_active($Player.deck.pop_front())
	#deal starting hand
	for i in range(5):
		for player in players:
			player.draw_card()
	#start listening for player hovering their deck
	$Player.deck_hovered.connect(_on_deck_hovered)
	$Player.deck_unhovered.connect(_on_deck_unhovered)
	#start checking for game end
	endgame = false
	#start first turn
	player_turn = true
	#draw bank
	$Bank/Amount.text = "x" + str(Autoload.player_gold)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func create_card(card, player):
	if card:
		var c = player.create_card(card)
		if c:
			c.card_hovered.connect(_on_card_hovered)
			c.card_unhovered.connect(_on_card_unhovered)
			if player == $Player:
				c.clickable = true
				c.card_clicked.connect(_on_player_card_clicked)

func make_active(card):
	card.set_sprite()
	var card_position = Vector2(320 + randfn(0, 2), 240 + randfn(0, 2))
	var tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", card_position, 0.25)
	tween.parallel().tween_property(card, "scale", Vector2(2,2), 0.25)
	tween.parallel().tween_property(card, "global_rotation", 0, 0.25)
	card.z_index = 1
	card.visible = true
	if active:
		active.get_parent().discard.append(active)
		for player in players:
			for c in player.discard:
				c.hoverable = false
				c.z_index = -1
		active.z_index = 0
	card.get_parent().hand.erase(card)
	card.get_parent().redraw_hand()
	active = card
	if not active.card_hovered.is_connected(_on_card_hovered):
		active.card_hovered.connect(_on_card_hovered)
	if not active.card_unhovered.is_connected(_on_card_unhovered):
		active.card_unhovered.connect(_on_card_unhovered)
	active.clickable = false
	active.hoverable = true
	if not endgame:
		await special_effects(active)
	check_endgame()

func special_effects(card):
	Autoload.suit_to_draw = []
	if card.value.size() == 1:
		if 'S' in card.value:
			skip += 1
		if 'R' in card.value:
			turn_direction *= -1
			$Arrows.frame = 1
			await get_tree().create_timer(0.1).timeout
			if turn_direction == 1:
				$Arrows.frame = 0
			else:
				$Arrows.frame = 2
		if 'D' in card.value:
			draw_amount = 2
	match card.card_name:
		"Wild Draw 4":
			draw_amount = 4
		"Time Walk":
			go_again = true
		"Credit Card":
			Autoload.player_gold += 1
			$Bank/Amount.text = "x" + str(Autoload.player_gold)
		"Warcry":
			warcry = true
			go_again = true
		"Dark Meltizard":
			Autoload.suit_to_draw = ["hearts"]

func check_endgame():
	var winner
	if not endgame:
		for player in players:
			if is_instance_valid(player) and player.hand.size() == 0:
				winner = player
	if winner:
		endgame = true
		player_turn = false
		Autoload.music_location = $Music.get_playback_position()
		$Music.stop()
		if winner == $Player:
			$Win.play()
			#if player defeated the champion
			if Autoload.difficulty == 9:
				#award gold card back
				Autoload.champion = true
				Autoload.save_game()
				#update button
				$Button.text = "Return to Menu"
				$Button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
				#show time played
				var total_time = Time.get_ticks_usec() - Autoload.start_time
				@warning_ignore("integer_division")
				var total_hours = total_time / 3600000000
				total_time -= total_hours * 3600000000
				@warning_ignore("integer_division")
				var total_minutes = total_time / 60000000
				total_time -= total_minutes * 60000000
				@warning_ignore("integer_division")
				var total_seconds = total_time / 1000000
				total_time -= total_time * 1000000
				$CardText/CardName.text = "You Win!"
				$CardText/CardDescription.text = "You defeated the final boss and unlocked the Golden Card Back!"
				$CardText/CardDescription.text += " Total time: " + total_hours + ":" + total_minutes + ":" + total_seconds
				#prevent text box from being overwritten
				for player in players:
					for card in player.hand:
						card.hoverable = false
					for card in player.discard:
						card.hoverable = false
			else:
				#if player won, give them gold
				Autoload.difficulty += 1
				Autoload.player_gold += Autoload.difficulty
				#if player won, set button
				$Button.text = "Go to Shop"
				$Button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/shop.tscn"))
		else:
			$Lose.play()
		#draw chalice for winner
		if not $Chalice.visible:
			var timer = randfn(1, 0.1)
			$Chalice.rotation = winner.rotation
			$Chalice.show()
			var tween = get_tree().create_tween()
			tween.tween_property($Chalice, "scale", Vector2(1, 1), timer)
			tween.parallel().tween_property($Chalice, "rotation", winner.rotation + (2 * PI), timer)
			tween.parallel().tween_property($Chalice, "position", winner.position, timer)
		if not $Button.visible:
			if not $Button.text:
				$Button.text = "Main Menu"
				$Button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
			$Button.visible = true

func cycle_turns():
	var turn = players.find($Player)
	while not endgame:
		#check if player is getting skipped
		if skip:
			turn += turn_direction * skip
			skip = 0
		#check if warcry is active
		if warcry:
			players[turn].draw_card()
			if players[turn] != $Player:
				var card = players[turn].hand[randi() % players[turn].hand.size()]
				var tween = get_tree().create_tween()
				tween.tween_property(card, "global_position", players[turn].position, 0.25)
				tween.parallel().tween_property(card, "scale", Vector2(1,1), 0.25)
				tween.parallel().tween_property(card, "global_rotation", players[turn].rotation, 0.25)
				tween.connect("finished", card.hide)
				tween.connect("finished", players[turn].redraw_deck)
				players[turn].hand.erase(card)
				players[turn].deck.push_front(card)
				warcry = false
		#increment turn, maybe
		if not go_again:
			turn += turn_direction
		go_again = false
		if turn < 0:
			turn = players.size() + turn
		else:
			turn = turn % players.size()
		#check if draws are forced
		for i in range(draw_amount):
			players[turn].draw_card()
		draw_amount = 0
		#check if Ragnaros is active
		if active.card_name == "The Firelord":
			var ragnaros = players[randi() % players.size()]
			while ragnaros == active.get_parent():
				ragnaros = players[randi() % players.size()]
			for i in range(4):
				ragnaros.draw_card()
		#check if back to user
		if players[turn] == $Player:
			break
		#opponents take turns
		await players[turn].take_turn(active)
	#user takes turn
	if not endgame:
		player_turn = true

func get_players_and_opponents():
	players = get_tree().get_nodes_in_group("players")
	opponents = get_tree().get_nodes_in_group("opponents")

func _on_card_hovered(card):
	hovered = card
	$CardText/CardName.text = card.card_name
	$CardText/CardDescription.text = card.description
	if card in $Player.hand:
		card.z_index = 2
		card.position = Vector2(card.position.x, -5)

func _on_card_unhovered(card):
	if card == hovered:
		$CardText/CardName.text = ""
		$CardText/CardDescription.text = ""
	if card in $Player.hand:
		card.z_index = 1
		card.position = Vector2(card.position.x, 5)

func _on_deck_hovered(player):
	if not endgame:
		if player == $Player:
			hovered = $Player
			$CardText/CardName.text = "Your Draw Pile"
			if player.deck.size():
				#if there are cards in the player's deck
				$CardText/CardDescription.text = "Draw a card and end your turn."
			elif player.discard.size():
				#if the player's deck is empty
				$CardText/CardDescription.text = "Shuffle your discarded cards into your deck, "
				$CardText/CardDescription.text += "then draw a card and end your turn."
			else:
				#if the player's deck and discard are both empty
				$CardText/CardDescription.text = "Pass your turn without playing a card."
		else:
			$CardText/CardName.text = "Opponent Draw Pile"

func _on_deck_unhovered(_player):
	$CardText/CardName.text = ""
	$CardText/CardDescription.text = ""

func _on_player_card_clicked(card):
	if player_turn:
		if warcry:
			warcry = false
			player_turn = false
			var tween = get_tree().create_tween()
			tween.tween_property(card, "global_position", $Player.position, 0.25)
			tween.parallel().tween_property(card, "scale", Vector2(1,1), 0.25)
			tween.parallel().tween_property(card, "global_rotation", $Player.rotation, 0.25)
			tween.connect("finished", card.hide)
			tween.connect("finished", $Player.redraw_deck)
			$Player.hand.erase(card)
			$Player.redraw_hand()
			$Player.deck.push_front(card)
		elif active == null or active.compare(card):
			player_turn = false
			await make_active(card)
		if not player_turn:
			$Card.play()
			$Player.redraw_hand()
			cycle_turns()

func _on_player_card_drawn():
	if player_turn and not draw_amount:
		$Deck.play()
		player_turn = false
		cycle_turns()

func _on_opponent_card_played(card):
	await make_active(card)

func _on_confirm_pressed():
	if hovered:
		if hovered == $Player:
			$Player.draw_card()
		else:
			hovered.card_clicked.emit(hovered)
	hovered = null

func _on_options_pressed():
	var options = options_scene.instantiate()
	add_child(options)
	options.get_node("Delete").queue_free()
	options.position = Vector2(0, 500)
	options.options_exited.connect(func(): self.set_position(Vector2(0, 0)))
	self.position = Vector2(0, -500)
