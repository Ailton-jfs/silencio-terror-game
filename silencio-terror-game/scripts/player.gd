extends CharacterBody2D

@onready var anim_sprite = $AnimatedSprite2D

@export var speed = 200.0
var direction = Vector2.ZERO

var is_alive = true

func _physics_process(delta: float) -> void:
	
	if is_alive:
		move()
		anim()
	
	pass
	
func move():
	
	direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	move_and_slide()
	
	pass
	
func anim():
	
	if direction == Vector2.ZERO:
		anim_sprite.play("idle")
	else:
		if abs(direction.x) > abs(direction.y):
			anim_sprite.play("move_side")
			if direction.x < 0:
				anim_sprite.flip_h = true
			else:
				anim_sprite.flip_h = false
		elif direction.y > 0:
			anim_sprite.play("move_down")
		else:
			anim_sprite.play("move_up")
			
	pass

func die():
	
	is_alive = false
	anim_sprite.play("death")
	$Area2D.queue_free()
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()
