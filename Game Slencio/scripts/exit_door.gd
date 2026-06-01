extends Area2D

var players_escaped := []

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	if body in players_escaped:
		return
	players_escaped.append(body)
	
	var all_players = get_tree().get_nodes_in_group("player")
	# Conta apenas players vivos
	var alive = all_players.filter(func(p): return not ("is_dead" in p and p.is_dead))
	
	# Todos os players vivos passaram pela porta
	if players_escaped.size() >= alive.size():
		get_tree().call_group("game_manager", "trigger_escape")
