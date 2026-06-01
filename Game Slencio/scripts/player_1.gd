extends CharacterBody2D

# --- Referências ---
@onready var anim_sprite = $AnimatedSprite2D

# --- Configurações exportáveis ---
@export var walk_speed    := 120.0
@export var run_speed     := 220.0
@export var stun_cooldown := 3.0

# --- Estado ---
var direction    := Vector2.ZERO
var is_running   := false
var is_hidden    := false
var is_dead      := false
var can_stun     := true
var stun_timer   := 0.0
var current_hiding_spot = null

func _ready():
	add_to_group("player")
	anim_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if is_dead or is_hidden:
		velocity = Vector2.ZERO
		return

	_handle_stun_cooldown(delta)
	move_player()
	update_animation()

func move_player():
	direction  = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	is_running = Input.is_action_pressed("run")
	velocity   = direction * (run_speed if is_running else walk_speed)
	move_and_slide()

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

# ─── ATORDOAR MONSTRO ───
func _handle_stun_cooldown(delta):
	if not can_stun:
		stun_timer += delta
		if stun_timer >= stun_cooldown:
			can_stun   = true
			stun_timer = 0.0

func try_stun():
	if not can_stun:
		return
	for monster in get_tree().get_nodes_in_group("monster"):
		if global_position.distance_to(monster.global_position) < 80.0:
			monster.stun()
			can_stun   = false
			stun_timer = 0.0

func _input(event):
	if event.is_action_pressed("stun"):
		try_stun()

# ─── ESCONDERIJO ───
func set_hiding_spot(spot):
	current_hiding_spot = spot

func clear_hiding_spot(spot):
	if current_hiding_spot == spot:
		current_hiding_spot = null
		is_hidden = false
		anim_sprite.visible = true
