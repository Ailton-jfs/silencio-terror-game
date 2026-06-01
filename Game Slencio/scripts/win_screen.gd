extends Node

func _ready():
	get_tree().paused = false

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_R):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
