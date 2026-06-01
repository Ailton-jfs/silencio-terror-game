extends CharacterBody2D

# ─────────────────────────────────────────
#  MONSTRO — caça pelo barulho
# ─────────────────────────────────────────

@onready var anim_sprite = $AnimatedSprite2D

@export var chase_speed   := 180.0
@export var patrol_speed  := 60.0
@export var stun_duration := 3.0
@export var hear_radius   := 300.0
@export var lose_time     := 2.5
@export var return_speed  := 90.0  # velocidade ao voltar ao ponto inicial

@export var patrol_points: Array[Vector2] = []

enum State { PATROL, CHASE, STUNNED, RETURNING }

var state           : State = State.PATROL
var target_position : Vector2 = Vector2.ZERO
var sound_target    : Node = null
var lose_timer      : float = 0.0
var stun_timer      : float = 0.0
var patrol_index    := 0

# Ponto de partida — salvo automaticamente no _ready
var spawn_position  : Vector2 = Vector2.ZERO

func _ready():
	add_to_group("monster")
	spawn_position = global_position  # salva posição inicial
	if patrol_points.size() == 0:
		patrol_points = [global_position]

func _physics_process(delta):
	# Verifica captura em QUALQUER estado
	if state != State.STUNNED:
		_check_player_catch()

	match state:
		State.PATROL:
			_do_patrol()
			_listen_for_sound()
		State.CHASE:
			_do_chase()
			_check_lose_target(delta)
		State.STUNNED:
			_do_stunned(delta)
		State.RETURNING:
			_do_return()
			_listen_for_sound()

# ─────────────────────────────────────────
#  PATRULHA
# ─────────────────────────────────────────
func _do_patrol():
	anim_sprite.play("idle")
	if patrol_points.size() <= 1:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dest = patrol_points[patrol_index]
	if global_position.distance_to(dest) < 10.0:
		patrol_index = (patrol_index + 1) % patrol_points.size()
	else:
		velocity = (dest - global_position).normalized() * patrol_speed
		move_and_slide()

# ─────────────────────────────────────────
#  AUDIÇÃO
# ─────────────────────────────────────────
func _listen_for_sound():
	var loudest_level := 0.0
	var loudest_player = null

	for p in get_tree().get_nodes_in_group("player"):
		if not p.has_method("get_noise_level"):
			continue
		var dist = global_position.distance_to(p.global_position)
		if dist > hear_radius:
			continue
		var level = p.get_noise_level() * (1.0 - dist / hear_radius)
		if level > loudest_level:
			loudest_level = level
			loudest_player = p

	if loudest_player != null:
		sound_target    = loudest_player
		target_position = loudest_player.global_position
		state           = State.CHASE
		lose_timer      = 0.0

# ─────────────────────────────────────────
#  PERSEGUIÇÃO
# ─────────────────────────────────────────
func _do_chase():
	if not anim_sprite.animation == "run_monster":
		anim_sprite.play("run_monster")

	if sound_target != null and is_instance_valid(sound_target):
		if sound_target.get_noise_level() > 0.0:
			target_position = sound_target.global_position
			lose_timer = 0.0

	var dir = (target_position - global_position).normalized()
	velocity = dir * chase_speed
	move_and_slide()

	if velocity.x != 0:
		anim_sprite.flip_h = velocity.x < 0


func _check_lose_target(delta):
	var player_making_noise = (
		sound_target != null
		and is_instance_valid(sound_target)
		and sound_target.get_noise_level() > 0.0
	)

	if player_making_noise:
		lose_timer = 0.0
	else:
		lose_timer += delta

	if lose_timer >= lose_time:
		# Todos os players estão escondidos ou em silêncio — volta ao spawn
		sound_target = null
		lose_timer   = 0.0
		state        = State.RETURNING

# ─────────────────────────────────────────
#  RETORNO AO PONTO DE PARTIDA
# ─────────────────────────────────────────
func _do_return():
	anim_sprite.play("idle")

	var dist_to_spawn = global_position.distance_to(spawn_position)

	if dist_to_spawn < 15.0:
		# Chegou no spawn — volta a patrulhar normalmente
		global_position = spawn_position
		velocity        = Vector2.ZERO
		patrol_index    = 0
		state           = State.PATROL
		move_and_slide()
		return

	var dir = (spawn_position - global_position).normalized()
	velocity = dir * return_speed
	move_and_slide()

	if velocity.x != 0:
		anim_sprite.flip_h = velocity.x < 0

# ─────────────────────────────────────────
#  CAPTURA
# ─────────────────────────────────────────
func _check_player_catch():
	for p in get_tree().get_nodes_in_group("player"):
		if "is_hidden" in p and p.is_hidden:
			continue
		if "is_dead" in p and p.is_dead:
			continue
		if global_position.distance_to(p.global_position) < 150.0:
			p.die()
			get_tree().call_group("game_manager", "game_over")

# ─────────────────────────────────────────
#  ATORDOADO
# ─────────────────────────────────────────
func stun():
	state      = State.STUNNED
	stun_timer = 0.0
	velocity   = Vector2.ZERO
	anim_sprite.play("idle")

func _do_stunned(delta):
	stun_timer += delta
	velocity = Vector2.ZERO
	move_and_slide()
	if stun_timer >= stun_duration:
		# Após atordoamento também volta ao spawn
		state      = State.RETURNING
		stun_timer = 0.0


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass
