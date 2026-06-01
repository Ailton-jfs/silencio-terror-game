extends CharacterBody2D

# --- Referências ---
@onready var anim_sprite = $AnimatedSprite2D

# --- Configurações ---
@export var walk_speed := 120.0
@export var run_speed  := 220.0

# --- Estado ---
var direction   := Vector2.ZERO
var is_running  := false
var is_hidden   := false
var is_dead     := false
var current_hiding_spot = null

func _ready():
	add_to_group("player")
	add_to_group("p2")
	anim_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta):
	if is_dead or is_hidden:
		velocity = Vector2.ZERO
		return

	direction  = Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")
	is_running = Input.is_action_pressed("p2_run")
	velocity   = direction * (run_speed if is_running else walk_speed)
	move_and_slide()
	update_animation()

func update_animation():
	if direction == Vector2.ZERO:
		anim_sprite.play("idle")
		return
	if abs(direction.x) > abs(direction.y):
		anim_sprite.play("move_side")
		anim_sprite.flip_h = direction.x < 0
	else:
		anim_sprite.play("move_down" if direction.y > 0 else "move_up")

func get_noise_level() -> float:
	if is_hidden or is_dead:
		return 0.0
	if is_running and direction != Vector2.ZERO:
		return 1.0
	if direction != Vector2.ZERO:
		return 0.4
	return 0.0

# ─── MORTE ───
func die():
	if is_dead:
		return
	is_dead  = true
	velocity = Vector2.ZERO
	anim_sprite.play("death")

func _on_animation_finished():
	pass  # game_manager controla a troca de cena

# ─── ESCONDERIJO ───
func set_hiding_spot(spot):
	current_hiding_spot = spot

func clear_hiding_spot(spot):
	if current_hiding_spot == spot:
		current_hiding_spot = null
		is_hidden = false
		anim_sprite.visible = true

func _input(event):
	if event.is_action_pressed("p2_hide"):
		if current_hiding_spot != null:
			is_hidden = !is_hidden
			anim_sprite.visible = !is_hidden
