extends CharacterBody2D

# Pengaturan dasar musuh
@export var speed: float = 100.0
var direction: int = 1 # 1 = Kanan, -1 = Kiri
var can_flip: bool = true

# Pastikan nama di $ sesuai dengan nama node di Scene Tree kamu
@onready var edge_detector: RayCast2D = $EdgeDetector
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 1. Tambahkan gravitasi agar musuh menempel di lantai
	if not is_on_floor():
		velocity.y += 0 * delta

	# 2. Logika Patroli: Cek tembok atau jurang
	# Hanya cek jika can_flip true agar tidak berputar-putar (glitch)
	if can_flip:
		var hit_wall = is_on_wall()
		var hit_edge = not edge_detector.is_colliding()

		if hit_wall or hit_edge:
			_flip_direction()

	# 3. Jalankan pergerakan
	velocity.x = direction * speed
	move_and_slide()

func _flip_direction() -> void:
	can_flip = false
	direction *= -1
	
	# Ambil node AnimatedSprite2D kamu (sesuaikan namanya)
	# Ini hanya membalik gambar, tidak membalik seluruh koordinat node
	$AnimatedSprite2D.flip_h = (direction == -1)
	
	# Raycast juga harus ikut pindah posisi ke depan wajah yang baru
	# Geser nilai 'position.x' raycast-nya secara manual
	$EdgeDetector.position.x = abs($EdgeDetector.position.x) * direction
	
	# Kasih jeda sedikit agar dia tidak langsung balik lagi
	await get_tree().create_timer(5).timeout
	can_flip = true

# 4. Fungsi Kematian Player (Hubungkan Signal body_entered dari Area2D ke sini)
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("terkena_damage"):
		# Player langsung mati (Memory Shards death mechanic)
		body.terkena_damage(999, global_position)
