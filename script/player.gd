extends CharacterBody2D

# --- STATISTIK KARAKTER ---
var respawn_position: Vector2
var max_hp: float = 100.0
var current_hp: float = max_hp
var max_stamina: float = 200.0
var current_stamina: float = max_stamina

# Konfigurasi Stamina
var stamina_regen: float = 50.0 
var run_cost: float = 20.0      
var dash_cost: float = 50.0     

# --- KONFIGURASI PERGERAKAN ---
const SPEED = 80.0
const RUN_SPEED = 230.0 
const JUMP_VELOCITY = -300.0

# Konfigurasi Dash
const DASH_SPEED = 600.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 1

# --- KONFIGURASI WALL SLIDE & JUMP ---
var is_wall_sliding: bool = false
const WALL_SLIDE_SPEED = 200.0
# Diubah: X lebih besar untuk dorongan horizontal, Y lebih kecil agar tidak terlalu ke atas
const WALL_JUMP_VELOCITY = Vector2(600, 0) 

# --- KONFIGURASI FALL DAMAGE ---
var starting_fall_y: float = 0.0
var is_falling: bool = false
const BLOCK_SIZE = 16 
const FALL_THRESHOLD = 5 * BLOCK_SIZE 
const DAMAGE_PER_BLOCK = 0.0

# --- REFERENSI NODE ---
@onready var player_ui: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp_bar: ProgressBar = $UI/HPBar
@onready var stamina_bar: ProgressBar = $UI/StaminaBar
@onready var overlay: ColorRect = $DeathUI/Overlay

# Variabel State Internal
var last_tap_time = 0.0
var last_direction = 0
var is_running = false
var is_dashing = false
var can_dash = true

func _ready():
	if GameManager.last_checkpoint_pos != Vector2.ZERO:
		global_position = GameManager.last_checkpoint_pos
	respawn_position = global_position
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina

func _process(delta: float) -> void:
	hp_bar.value = lerp(hp_bar.value, current_hp, 10 * delta)
	stamina_bar.value = lerp(stamina_bar.value, current_stamina, 10 * delta)

func _physics_process(delta: float) -> void:
	# 1. LOGIKA STAMINA
	if not is_running and not is_dashing and current_stamina < max_stamina:
		current_stamina += stamina_regen * delta
		current_stamina = clamp(current_stamina, 0, max_stamina)

	# 2. LOGIKA DASH
	if Input.is_key_pressed(KEY_Q) and can_dash and is_running:
		if current_stamina >= dash_cost:
			start_dash()

	if is_dashing:
		player_ui.play("dash")
		move_and_slide()
		return 

	# 3. KONSUMSI STAMINA SAAT LARI
	if is_running and is_on_floor():
		if current_stamina > 0:
			current_stamina -= run_cost * delta
		else:
			is_running = false 

	# 4. TIMER DOUBLE TAP & INPUT ARAH
	if last_tap_time > 0:
		last_tap_time -= delta
	
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		var current_dir = -1 if Input.is_action_just_pressed("ui_left") else 1
		if last_tap_time > 0 and current_dir == last_direction and current_stamina > 10:
			is_running = true
		last_tap_time = 0.3
		last_direction = current_dir
	
	if direction == 0:
		is_running = false

	# 5. GRAVITASI, LOMPAT, & WALL SLIDE LOGIC
	if not is_on_floor():
		_check_wall_slide(direction)
		
		if is_wall_sliding:
			velocity.y = WALL_SLIDE_SPEED
			is_falling = false 
		else:
			if not is_falling:
				starting_fall_y = global_position.y
				is_falling = true
			velocity += get_gravity() * delta
	else:
		if is_falling:
			_handle_fall_damage()
			is_falling = false
		is_wall_sliding = false

	# Logika Lompat & Wall Jump
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_wall_sliding:
			_perform_wall_jump()

	# 6. PERGERAKAN HORIZONTAL
	if not is_wall_sliding:
		var current_speed_limit = RUN_SPEED if is_running else SPEED
		if direction:
			if not is_on_floor():
				# Lerp diperkecil agar momentum Wall Jump ke arah samping tidak langsung hilang
				velocity.x = lerp(velocity.x, direction * current_speed_limit, 0.05)
			else:
				velocity.x = direction * current_speed_limit
			player_ui.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# 7. ANIMASI
	_handle_animations(direction)
	move_and_slide()

# --- FUNGSI PENDUKUNG ---

func _check_wall_slide(direction):
	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		var wall_normal = get_wall_normal()
		
		if (direction > 0 and wall_normal.x < 0) or (direction < 0 and wall_normal.x > 0):
			is_wall_sliding = true
			player_ui.flip_h = wall_normal.x < 0 
			velocity.x = -wall_normal.x * 10.0
			return

	is_wall_sliding = false
		
func _perform_wall_jump():
	var wall_normal = get_wall_normal()
	is_wall_sliding = false
	
	# Menendang menjauh secara horizontal sesuai arah normal dinding
	velocity.x = wall_normal.x * WALL_JUMP_VELOCITY.x
	velocity.y = WALL_JUMP_VELOCITY.y
	
	# Tetap gunakan logika flip_h kamu
	player_ui.flip_h = wall_normal.x < 0

func start_dash():
	current_stamina -= dash_cost
	if has_node("DashSound"): $DashSound.play()
	is_dashing = true
	can_dash = false
	var dash_dir = -1 if player_ui.flip_h else 1
	velocity.x = dash_dir * DASH_SPEED
	velocity.y = 0 
	await get_tree().create_timer(DASH_DURATION).timeout
	is_dashing = false
	await get_tree().create_timer(DASH_COOLDOWN).timeout
	can_dash = true

func _handle_fall_damage():
	var fall_distance = global_position.y - starting_fall_y
	if fall_distance > FALL_THRESHOLD:
		var extra_dist = fall_distance - FALL_THRESHOLD
		var extra_blocks = extra_dist / BLOCK_SIZE
		var total_damage = 15.0 + (extra_blocks * DAMAGE_PER_BLOCK)
		take_damage(total_damage)

func _handle_animations(direction):
	if is_wall_sliding:
		player_ui.play("WallSlide")
		# TAMBAHKAN INI: Hentikan suara saat wall slide
		if has_node("WalkSound"): $WalkSound.stop()
		return 

	if not is_on_floor():
		player_ui.play("Jump")
		# TAMBAHKAN INI: Hentikan suara saat di udara
		if has_node("WalkSound"): $WalkSound.stop()
		return

	if direction != 0:
		player_ui.play("Run" if is_running else "walk")
		if has_node("WalkSound"):
			if not $WalkSound.playing:
				$WalkSound.pitch_scale = 2.0 if is_running else 1.0
				$WalkSound.play()
	else:
		player_ui.play("idle")
		if has_node("WalkSound"): $WalkSound.stop()

var is_invincible: bool = false # Tambahkan variabel state baru di atas

func take_damage(amount: float):
	if is_invincible: return # Jika sedang I-Frame, abaikan damage
	
	current_hp -= amount
	current_hp = clamp(current_hp, 0, max_hp)
	
	# Aktifkan I-Frame
	start_iframe(1.5) # Beri waktu 1.5 detik perlindungan
	
	var tween = create_tween()
	tween.tween_property(player_ui, "modulate", Color.RED, 0.1)
	tween.tween_property(player_ui, "modulate", Color.WHITE, 0.1)
	
	if current_hp <= 0:
		_die()

# Fungsi baru untuk mengontrol I-Frame
func start_iframe(duration: float):
	is_invincible = true
	# Opsi 1: Matikan Collision Mask (Misal musuh ada di Layer 2)
	# set_collision_mask_value(2, false) 
	
	# Efek visual kedip-kedip
	var tween = create_tween().set_loops(5)
	tween.tween_property(player_ui, "modulate:a", 0.5, 0.1)
	tween.tween_property(player_ui, "modulate:a", 1.0, 0.1)
	
	await get_tree().create_timer(duration).timeout
	
	is_invincible = false
	# set_collision_mask_value(2, true) # Hidupkan kembali
	player_ui.modulate.a = 1.0 # Pastikan kembali normal

func _die():
	is_invincible = true # Pastikan tidak bisa kena damage lagi
	set_physics_process(false)
	
	# MATIKAN COLLISION TOTAL
	# Ini mematikan bentuk fisik karakter agar tembus segalanya
	$CollisionShape2D.set_deferred("disabled", true)
	
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
	await tween.finished
	await get_tree().create_timer(0.8).timeout
	
	# Pindahkan posisi
	velocity = Vector2.ZERO
	global_position = respawn_position
	current_hp = max_hp
	
	# HIDUPKAN KEMBALI
	$CollisionShape2D.set_deferred("disabled", false)
	
	var tween_in = create_tween()
	tween_in.tween_property(overlay, "modulate:a", 0.0, 0.5)
	
	# Beri sedikit perlindungan ekstra saat baru lahir kembali
	start_iframe(1.0) 
	
	set_physics_process(true)

func terkena_damage(amount: float, sumber_posisi: Vector2):
	take_damage(amount)
	var arah_mundur = 1 if global_position.x > sumber_posisi.x else -1
	velocity.x = arah_mundur * 300.0
	velocity.y = -200.0
	
# Tambahkan ini di bagian bawah script player kamu
func ambil_kunci():
	GameManager.has_key = true
	print("Kunci didapat! Sekarang cari pintu.")
	# Efek visual tambahan jika mau
	var tween = create_tween()
	tween.tween_property(player_ui, "self_modulate", Color.YELLOW, 0.2)
	tween.tween_property(player_ui, "self_modulate", Color.WHITE, 0.2)
