extends Area2D

@export var durasi_aktif: float = 2.0
@export var durasi_mati: float = 2.0

func _ready():
	# Mulai siklus muncul-hilang
	mulai_siklus()

func mulai_siklus():
	while true:
		# --- PHASE 1: MUNCUL (AKTIF) ---
		show() # Munculkan visual
		# Aktifkan collision agar bisa memberi damage
		$CollisionShape2D.disabled = false 
		if $AnimatedSprite2D.sprite_frames:
			$AnimatedSprite2D.play("default") # Ganti "default" sesuai nama animasi kamu
		
		await get_tree().create_timer(durasi_aktif).timeout
		
		# --- PHASE 2: HILANG (MATI) ---
		hide() # Hilangkan visual
		# Matikan collision agar player tidak kena damage saat api hilang
		$CollisionShape2D.disabled = true 
		
		await get_tree().create_timer(durasi_mati).timeout

# Jangan lupa tambahkan fungsi damage-nya juga
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("terkena_damage"):
		body.terkena_damage(15.0, global_position)
