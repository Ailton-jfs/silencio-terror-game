extends Area2D

# ─────────────────────────────────────────
#  NOISE AREA — filho do player
#  Expande/retrai com base no nível de barulho
#  
#  Estrutura esperada:
#  Player
#  └── NoiseArea (Area2D) <-- este script
#      └── CollisionShape2D (CircleShape2D)
# ─────────────────────────────────────────

@onready var shape: CollisionShape2D = $CollisionShape2D

@export var min_radius := 0.0    # parado/escondido
@export var walk_radius := 120.0
@export var run_radius  := 280.0

func _ready():
	monitoring = false  # começa desativado

func set_radius_by_noise(noise_level: float):
	if not shape or not shape.shape is CircleShape2D:
		return
	if noise_level <= 0.0:
		monitoring = false
		shape.shape.radius = min_radius
	elif noise_level < 0.8:
		monitoring = true
		shape.shape.radius = walk_radius
	else:
		monitoring = true
		shape.shape.radius = run_radius
