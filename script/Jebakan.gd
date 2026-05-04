extends AnimatableBody2D

# Atur variabel ini di Inspector (sebelah kanan)
@export var jarak_naik: float = 128.0  # Spike naik setinggi 1 tile (16px)
@export var durasi_gerak: float = 0.1 # Kecepatan naik/turun
@export var jeda_diam: float = 1.0    # Berapa lama spike diam di bawah/atas

func _ready():
	mulai_animasi_jebakan()
	if not $Area2D.body_entered.is_connected(_on_area_2d_body_entered):
		$Area2D.body_entered.connect(_on_area_2d_body_entered)
		print("Signal disambungkan paksa via kode!")

func mulai_animasi_jebakan():
	# Ambil posisi Y awal spike saat ini
	var posisi_awal_y = position.y
	var posisi_target_y = posisi_awal_y - jarak_naik
	
	var tween = create_tween().set_loops() # Loop selamanya
	
	# 1. Gerak Naik
	tween.tween_property(self, "position:y", posisi_target_y, durasi_gerak).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# 2. Diam di Atas (Biar player harus waspada)
	tween.tween_interval(jeda_diam)
	
	# 3. Gerak Turun
	tween.tween_property(self, "position:y", posisi_awal_y, durasi_gerak).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 4. Diam di Bawah (Aman dilewati sebentar)
	tween.tween_interval(jeda_diam)
	
func _on_area_2d_body_entered(body: Node2D):
	print("ADA YANG NABRAK: ", body.name) # Ini WAJIB muncul di Output kalau nabrak
	
	if body.has_method("terkena_damage"):
		print("Fungsi ditemukan, kirim damage!")
		body.terkena_damage(100.0, global_position) # Memanggil fungsi di script Player kamu
	else:
		print("Benda ini gak punya fungsi 'terkena_damage'!")
