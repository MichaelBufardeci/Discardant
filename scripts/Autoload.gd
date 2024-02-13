extends Node

var touchscreen := false
var player_deck := []
var player_gold := 1
var difficulty := 0
var standard_deck := []
var delete_card := false
var player_card_back := 0
var suit_to_draw := []
var champion := false
var start_time := 0
var music_location := 0.0
var game_speed := 0.3
var in_game := false
var bought_cards := []
const standard_values = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'R', 'S', 'D']
const standard_suits = ["clubs", "hearts", "spades", "diamonds"]
const special_cards = ["Time Walk", "Credit Card", "Warcry", "The Firelord", "Dark Meltizard"]

# Called when the node enters the scene tree for the first time.
func _ready():
	#create standard deck
	for v in standard_values:
		for s in standard_suits:
			standard_deck.append([v, s])
	for i in range(2):
		standard_deck.append(['*', '*'])
		standard_deck.append(['D', '*'])
	#load save data
	if FileAccess.file_exists("user://discardant.save"):
		var json_instance = JSON.new()
		var save_file = FileAccess.open("user://discardant.save", FileAccess.READ).get_line()
		if json_instance.parse(save_file) == OK:
			var save_data = json_instance.get_data()
			touchscreen = save_data["touchscreen"]
			bought_cards = save_data["bought_cards"]
			champion = save_data["champion"]
			player_card_back = save_data["player_card_back"]
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), save_data["master_volume"])
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), save_data["music_volume"])
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), save_data["sfx_volume"])
	#set default values
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func save_game():
	var save_data = {
		"touchscreen" : touchscreen,
		"bought_cards" : bought_cards,
		"champion" : champion,
		"player_card_back" : player_card_back,
		"master_volume" : AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")),
		"music_volume" : AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),
		"sfx_volume" : AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	}
	save_data = JSON.stringify(save_data)
	var save_file = FileAccess.open("user://discardant.save", FileAccess.WRITE)
	save_file.store_line(save_data)

func reset():
	#set these to match default values above
	player_deck = []
	player_gold = 1
	difficulty = 0
	suit_to_draw = []
	Autoload.start_time = Time.get_ticks_usec()
