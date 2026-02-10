extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var player_ui: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Animasi logic
	if velocity.x > 0 or velocity.x < 0:
		player_ui.animation = "walk"
	else:
		player_ui.animation = "idle"
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		player_ui.animation = "Jump"

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		player_ui.flip_h = direction < 0
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
