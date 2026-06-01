extends Camera2D

# ─────────────────────────────────────────
#  CÂMERA COMPARTILHADA
#  Fica no meio dos dois players sempre.
#  Adicione esta câmera direto no main.tscn
# ─────────────────────────────────────────

@export var smoothing_speed := 5.0   # quão suave é o movimento
@export var min_zoom        := 0.5   # zoom máximo (afasta)
@export var max_zoom        := 1.0   # zoom mínimo (aproxima)
@export var zoom_padding    := 200.0 # margem extra ao calcular zoom

func _ready():
	# Garante que esta é a câmera ativa
	make_current()

func _process(delta):
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return

	if players.size() == 1:
		# Só um player — segue ele direto
		var target = players[0].global_position
		global_position = global_position.lerp(target, smoothing_speed * delta)
		zoom = Vector2.ONE
		return

	# Dois players — vai para o ponto médio entre eles
	var p1_pos = players[0].global_position
	var p2_pos = players[1].global_position
	var midpoint = (p1_pos + p2_pos) / 2.0

	global_position = global_position.lerp(midpoint, smoothing_speed * delta)

	# Ajusta zoom com base na distância entre os players
	var dist = p1_pos.distance_to(p2_pos)
	var viewport_size = get_viewport_rect().size
	var required_zoom = min(
		viewport_size.x / (dist + zoom_padding),
		viewport_size.y / (dist + zoom_padding)
	)
	var target_zoom = clamp(required_zoom, min_zoom, max_zoom)
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), smoothing_speed * delta)
