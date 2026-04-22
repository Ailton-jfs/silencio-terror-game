extends CharacterBody2D

var speed = 120
var player

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):

	if player == null:
		return

	if NoiseSystem.noise > 40:
		look_at(player.global_position)

	if NoiseSystem.noise > 70:
		chase_player()

func chase_player():

	var direction = (player.global_position - global_position).normalized()

	velocity = direction * speed

	move_and_slide()

	if global_position.distance_to(player.global_position) < 20:
		game_over()

func game_over():
	get_tree().reload_current_scene()
