extends Node2D

signal options_exited

var music_location := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#set settings
	$TouchToggle.button_pressed = Autoload.touchscreen
	$VolumeControl/Volume.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))
	$MusicControl/Music.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	$SFXControl/SFX.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))))
	$SpeedControl/Speed.set_value_no_signal(1 - Autoload.game_speed)
	#detect champions
	if Autoload.champion:
		$ColorControl/Color.add_item(" Gold", 4)
	$ColorControl/Color.selected = Autoload.player_card_back
	#Detect if in game
	if Autoload.in_game:
		$ColorControl.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func blip():
	if not $Blip.playing:
		$Blip.play()

func _on_touch_toggle_toggled(button_pressed):
	Autoload.touchscreen = button_pressed

func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	blip()

func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	blip()

func _on_sfx_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	blip()

func _on_color_item_selected(index):
	Autoload.player_card_back = index
	blip()

func _on_return_pressed():
	blip()
	Autoload.save_game()
	if options_exited.get_connections():
		options_exited.emit()
		queue_free()
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_music_mouse_entered():
	if not options_exited.get_connections():
		$Music2.play(music_location)

func _on_music_mouse_exited():
	music_location = $Music2.get_playback_position()
	$Music2.stop()

func _on_speed_value_changed(value):
	Autoload.game_speed = 1 - value
	blip()

func _on_delete_button_pressed():
	$Delete/Button.text = "Confirm:"
	$Delete/Yes.visible = true
	$Delete/No.visible = true

func _on_yes_pressed():
	blip()
	Autoload.bought_cards = []
	Autoload.champion = false
	Autoload.player_card_back = 0
	$ColorControl/Color.selected = 0
	_on_no_pressed()

func _on_no_pressed():
	$Delete/Button.text = "Delete Save"
	$Delete/Yes.visible = false
	$Delete/No.visible = false

