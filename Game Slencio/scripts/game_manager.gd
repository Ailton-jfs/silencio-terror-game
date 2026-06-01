extends Node

@export var exit_scene: String = "res://scenes/win_screen.tscn"
@export var lose_scene: String = "res://scenes/lose_screen.tscn"
@export var total_keys: int = 2 # total de chaves no mapa

var keys_collected      := 0
var game_over_triggered := false

# Referência à parede invisível da saída (defina no Inspector ou pelo nome)
@export var exit_wall_path: NodePath = NodePath("")
@onready var exit_wall = get_node_or_null(exit_wall_path)

func _ready():
	add_to_group("game_manager")
	_update_hud()

# ─── CHAVES ───
func key_collected():
	keys_collected += 1
	_update_hud()
	print("Chaves: " + str(keys_collected) + "/" + str(total_keys))
	if keys_collected >= total_keys:
		_open_exit()

func _open_exit():
	# Remove a parede invisível da saída pelo nome
	var wall = get_tree().get_root().find_child("ExitWall", true, false)
	if wall and is_instance_valid(wall):
		wall.queue_free()
	# Feedback visual no HUD
	var hud = get_node_or_null("/root/Main/HUD/KeyLabel")
	if hud:
		hud.text = "SAIDA ABERTA!"
		hud.modulate = Color(0.2, 1.0, 0.2)

func _update_hud():
	var hud = get_node_or_null("/root/Main/HUD/KeyLabel")
	if hud:
		hud.text = "🗝 %d/%d" % [keys_collected, total_keys]

# ─── VITÓRIA ───
func trigger_escape():
	if game_over_triggered:
		return
	game_over_triggered = true
	if ResourceLoader.exists(exit_scene):
		get_tree().change_scene_to_file(exit_scene)
	else:
		get_tree().reload_current_scene()

# ─── GAME OVER ───
func game_over():
	if game_over_triggered:
		return
	game_over_triggered = true
	for p in get_tree().get_nodes_in_group("player"):
		if "is_dead" in p and not p.is_dead:
			p.is_dead = true
			p.velocity = Vector2.ZERO
			if p.has_node("AnimatedSprite2D"):
				p.get_node("AnimatedSprite2D").play("death")
	await get_tree().create_timer(1.2).timeout
	if ResourceLoader.exists(lose_scene):
		get_tree().change_scene_to_file(lose_scene)
	else:
		get_tree().reload_current_scene()
