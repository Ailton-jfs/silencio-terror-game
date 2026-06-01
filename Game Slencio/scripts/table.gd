extends Area2D

# ─────────────────────────────────────────
#  MESA / ESCONDERIJO
#  Player entra na área e pressiona a tecla de esconder.
#  Player 1 → tecla "hide" (E)
#  Player 2 → tecla "p2_hide" (Enter)
# ─────────────────────────────────────────

var players_inside: Array = []

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta):
	for player in players_inside:
		if not is_instance_valid(player):
			continue
		var hide_action = "p2_hide" if player.is_in_group("p2") else "hide"
		if Input.is_action_just_pressed(hide_action):
			_toggle_hide(player)

func _toggle_hide(player):
	if player.is_hidden:
		_show_player(player)
	else:
		_hide_player(player)

func _hide_player(player):
	player.is_hidden = true
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	var sprite = player.get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.visible = false

func _show_player(player):
	player.is_hidden = false
	player.set_physics_process(true)
	var sprite = player.get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.visible = true

func _on_body_entered(body):
	# Garante que é um player de verdade (tem is_hidden)
	if body.is_in_group("player") and "is_hidden" in body:
		if body not in players_inside:
			players_inside.append(body)

func _on_body_exited(body):
	if body in players_inside:
		players_inside.erase(body)
		# Se saiu escondido, aparece de volta
		if "is_hidden" in body and body.is_hidden:
			_show_player(body)
