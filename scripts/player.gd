extends CharacterBody2D

var speed = 150
var run_speed = 300

func _physics_process(delta):

	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	direction = direction.normalized()

	var is_running = Input.is_action_pressed("run")

	if is_running:
		velocity = direction * run_speed
		if direction != Vector2.ZERO:
			NoiseSystem.add_noise(5 * delta)
	else:
		velocity = direction * speed
		if direction != Vector2.ZERO:
			NoiseSystem.add_noise(2 * delta)

	move_and_slide()
