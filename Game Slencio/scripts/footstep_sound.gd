extends Node

# ─────────────────────────────────────────
#  SOM DE PASSOS
#  Adicione como filho do Player com o nome "FootstepSound"
#  e conecte um AudioStreamPlayer2D como filho.
#
#  Por enquanto gera beeps simples via código.
#  Quando tiver arquivos de som, troque o AudioStream.
# ─────────────────────────────────────────

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var walk_interval := 0.45  # segundos entre passos andando
@export var run_interval  := 0.25  # segundos entre passos correndo

var timer := 0.0
var parent_player = null

func _ready():
	parent_player = get_parent()

func _process(delta):
	if parent_player == null:
		return
	if not "direction" in parent_player:
		return

	# Só toca se estiver se movendo e não estiver morto/escondido
	if parent_player.direction == Vector2.ZERO:
		timer = 0.0
		return
	if ("is_dead" in parent_player and parent_player.is_dead):
		return
	if ("is_hidden" in parent_player and parent_player.is_hidden):
		return

	var interval = run_interval if parent_player.is_running else walk_interval
	timer += delta
	if timer >= interval:
		timer = 0.0
		if audio and audio.stream:
			audio.play()
