extends CanvasLayer

func _ready():
	get_tree().paused = false

func _input(event):
	# Enter ou Espaço também inicia o jogo
	if event.is_action_pressed("ui_accept"):
		_on_play_pressed()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()
