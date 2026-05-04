extends CharacterBody2D

# --- STATISTIK KARAKTER ---
var respawn_position: Vector2
var max_hp: float = 100.0
var current_hp: float = max_hp
var max_stamina: float = 200.0
var current_stamina: float = max_stamina

# Konfigurasi Stamina & Burn
var stamina_regen: float = 50.0 
var run_cost: float = 50.0      
var walk_cost: float = 10.0      
var dash_cost: float = 50.0     
var jump_cost: float = 80.0      
var is_exhausted: bool = false
const EXHAUSTED_SPEED_MULTIPLIER = 0.5
const EXHAUSTED_DURATION = 2.5 

# --- KONFIGURASI PERGERAKAN ---
const SPEED = 80.0
const RUN_SPEED = 150.0 
const JUMP_VELOCITY = -280.0
const DASH_SPEED = 200.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 1.0

# --- KONFIGURASI FALL DAMAGE ---
var starting_fall_y: float = 0.0
var is_falling: bool = false
const BLOCK_SIZE = 16 
const FALL_THRESHOLD = 5 * BLOCK_SIZE 

# --- REFERENSI NODE ---
@onready var player_ui: AnimatedSprite2D = $AnimatedSprite2D
@onready var stamina_bar: ProgressBar = $UI/StaminaBar
@onready var hp_bar: ProgressBar = $UI/HPBar
@onready var overlay: ColorRect = $DeathUI/Overlay
@onready var camera: Camera2D = $Camera2D
@onready var collision_shape = $CollisionShape2D

# State Internal
var last_tap_time = 0.0
var last_direction = 0
var is_running = false
var is_dashing = false
var can_dash = true
var is_invincible: bool = false

func _ready():
	if GameManager.last_checkpoint_pos != Vector2.ZERO:
		global_position = GameManager.last_checkpoint_pos
	respawn_position = global_position
	stamina_bar.max_value = max_stamina
	hp_bar.max_value = max_hp

func _process(delta: float) -> void:
	stamina_bar.value = lerp(stamina_bar.value, current_stamina, 10 * delta)
	hp_bar.value = lerp(hp_bar.value, current_hp, 10 * delta)

func _physics_process(delta: float) -> void:
	# 1. REGEN STAMINA
	var is_moving = Input.get_axis("ui_left", "ui_right") != 0
	if not is_moving and not is_dashing and is_on_floor() and current_stamina < max_stamina:
		current_stamina += stamina_regen * delta

	# 2. LOGIKA DASH
	if Input.is_key_pressed(KEY_Q) and can_dash and is_running and not is_exhausted:
		if current_stamina >= dash_cost:
			start_dash()

	if is_dashing:
		player_ui.play("dash")
		_spawn_dash_shadow()
		move_and_slide()
		return 

	# 3. KONSUMSI STAMINA (JALAN & LARI)
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Timer Double Tap
	if last_tap_time > 0: last_tap_time -= delta
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		var current_dir = -1 if Input.is_action_just_pressed("ui_left") else 1
		if last_tap_time > 0 and current_dir == last_direction and not is_exhausted:
			is_running = true
		last_tap_time = 0.3
		last_direction = current_dir
	if direction == 0: is_running = false

	if direction != 0 and is_on_floor() and not is_exhausted:
		var current_cost = run_cost if is_running else walk_cost
		if current_stamina > 0:
			current_stamina -= current_cost * delta
			if is_running: _spawn_dash_shadow()
		else:
			_trigger_stamina_burn()

	# 4. GRAVITASI, LOMPAT & FALL DAMAGE
	if not is_on_floor():
		if not is_falling:
			starting_fall_y = global_position.y
			is_falling = true
		velocity += get_gravity() * delta
	else:
		if is_falling:
			_handle_fall_damage()
			is_falling = false

	if Input.is_action_just_pressed("ui_accept") and not is_exhausted:
		if is_on_floor() and current_stamina >= jump_cost:
			velocity.y = JUMP_VELOCITY
			current_stamina -= jump_cost
		elif is_on_floor() and current_stamina < jump_cost:
			_trigger_stamina_burn()

	# 5. PERGERAKAN HORIZONTAL
	var speed_limit = RUN_SPEED if is_running else SPEED
	if is_exhausted: speed_limit *= EXHAUSTED_SPEED_MULTIPLIER
	
	if direction:
		velocity.x = direction * speed_limit
		player_ui.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 6. LOGIKA MENDORONG BLOK
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D and collider.is_in_group("blocks"):
			var push_force = 100.0
			collider.apply_central_impulse(collision.get_normal() * -push_force)

	_handle_animations(direction)
	move_and_slide()

# --- FUNGSI MEKANIK ---

func _trigger_stamina_burn():
	if is_exhausted: return
	is_exhausted = true
	player_ui.modulate = Color(0.5, 0.5, 1.0)
	await get_tree().create_timer(EXHAUSTED_DURATION).timeout
	_end_exhaustion()

func _end_exhaustion():
	is_exhausted = false
	player_ui.modulate = Color.WHITE

func _shake_camera(intensity: float):
	var original_pos = camera.offset
	camera.offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
	await get_tree().create_timer(0.1).timeout
	camera.offset = original_pos

func start_dash():
	current_stamina -= dash_cost
	is_dashing = true
	can_dash = false
	var dash_dir = -1 if player_ui.flip_h else 1
	velocity.x = dash_dir * DASH_SPEED
	velocity.y = 0 
	await get_tree().create_timer(DASH_DURATION).timeout
	is_dashing = false
	await get_tree().create_timer(DASH_COOLDOWN).timeout
	can_dash = true

func _spawn_dash_shadow():
	var shadow = Sprite2D.new()
	shadow.texture = player_ui.sprite_frames.get_frame_texture(player_ui.animation, player_ui.frame)
	shadow.global_position = global_position
	shadow.flip_h = player_ui.flip_h
	shadow.modulate = Color(1, 1, 1, 0.5)
	get_parent().add_child(shadow)
	var tween = create_tween()
	tween.tween_property(shadow, "modulate:a", 0.0, 0.3)
	tween.finished.connect(shadow.queue_free)

func _handle_fall_damage():
	var fall_distance = global_position.y - starting_fall_y
	if fall_distance > FALL_THRESHOLD:
		take_damage(100.0)

func take_damage(amount: float):
	if is_invincible: return
	current_hp -= amount
	current_hp = clamp(current_hp, 0, max_hp)
	start_iframe(1.0)
	if current_hp <= 0: _die()

func start_iframe(duration: float):
	is_invincible = true
	var tween = create_tween().set_loops(5)
	tween.tween_property(player_ui, "modulate:a", 0.5, 0.1)
	tween.tween_property(player_ui, "modulate:a", 1.0, 0.1)
	await get_tree().create_timer(duration).timeout
	is_invincible = false

func _die():
	is_invincible = true
	set_physics_process(false)
	collision_shape.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
	await tween.finished
	if GameManager.last_checkpoint_pos != Vector2.ZERO:
		global_position = GameManager.last_checkpoint_pos
	current_hp = max_hp
	current_stamina = max_stamina
	is_exhausted = false
	collision_shape.set_deferred("disabled", false)
	create_tween().tween_property(overlay, "modulate:a", 0.0, 0.5)
	set_physics_process(true)

func _handle_animations(direction):
	if not is_on_floor():
		player_ui.play("Jump")
	elif direction != 0:
		player_ui.play("Run" if is_running else "walk")
	else:
		player_ui.play("idle")
