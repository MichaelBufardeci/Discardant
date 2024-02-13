extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() != "HTML5":
		$Credits.connect("meta_clicked", _on_Credits_meta_clicked)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_return_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_Credits_meta_clicked(meta):
	OS.shell_open(meta)
