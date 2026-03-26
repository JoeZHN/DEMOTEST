extends CharacterBody2D

@export var move_speed: float = 120.0

var can_move: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		animated_sprite.stop()
		return

	var input_vector := Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		input_vector.x = -1
	elif Input.is_action_pressed("ui_right"):
		input_vector.x = 1
	elif Input.is_action_pressed("ui_up"):
		input_vector.y = -1
	elif Input.is_action_pressed("ui_down"):
		input_vector.y = 1

	velocity = input_vector.normalized() * move_speed
	move_and_slide()

	_update_animation(input_vector)

func _update_animation(input_vector: Vector2) -> void:
	if input_vector == Vector2.ZERO:
		animated_sprite.stop()
		return

	if input_vector.x < 0:
		animated_sprite.play("walk_right")
		animated_sprite.flip_h = true
	elif input_vector.x > 0:
		animated_sprite.play("walk_right")
		animated_sprite.flip_h = false
	elif input_vector.y < 0:
		animated_sprite.play("walk_up")
		animated_sprite.flip_h = false
	elif input_vector.y > 0:
		animated_sprite.play("walk_down")
		animated_sprite.flip_h = false
