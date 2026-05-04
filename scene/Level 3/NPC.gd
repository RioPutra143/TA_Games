extends Area2D

# Slot untuk memasukkan file scene di Inspector
@export_file("*.tscn") var scene_ya: String
@export_file("*.tscn") var scene_tidak: String

# Referensi ke UI (Pastikan nama node di Scene Tree sama)
@onready var ui_dialog = $CanvasLayer/Panel
@onready var btn_ya = $CanvasLayer/Panel/Button_Ya
@onready var btn_tidak = $CanvasLayer/Panel/Button_Tidak
@onready var label_pertanyaan = $CanvasLayer/Panel/Label

var player_dalam_jangkauan = false

func _ready():
	# 1. Sembunyikan UI saat game mulai (Hide)
	ui_dialog.hide()
	
	# 2. Hubungkan sinyal tombol agar bisa diklik
	btn_ya.pressed.connect(_on_ya_pressed)
	btn_tidak.pressed.connect(_on_tidak_pressed)
	
	# 3. Hubungkan sinyal Area2D untuk deteksi player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Mengecek apakah yang masuk adalah Player (menggunakan Group)
	if body.is_in_group("player"):
		player_dalam_jangkauan = true
		print("YOWWWWWWWW")
		# Opsi: Munculkan icon "!" atau teks "Tekan Enter" di sini

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_dalam_jangkauan = false
		ui_dialog.hide() # Otomatis tutup dialog kalau player pergi jauh
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Sembunyikan mouse lagi

func _input(event):
	# Gunakan Input (huruf kapital I) untuk mengecek action
	if player_dalam_jangkauan and Input.is_action_just_pressed("ui_accept"):
		if not ui_dialog.visible:
			ui_dialog.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Pastikan pakai 'mouse'
		else:
			ui_dialog.hide()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_ya_pressed():
	if scene_ya != "":
		# Pindah ke scene yang dipilih di slot "Scene Ya"
		get_tree().change_scene_to_file(scene_ya)
	else:
		print("Peringatan: Slot Scene Ya belum diisi di Inspector!")

func _on_tidak_pressed():
	if scene_tidak != "":
		# Pindah ke scene yang dipilih di slot "Scene Tidak"
		get_tree().change_scene_to_file(scene_tidak)
		GameManager.reset_data()
	else:
		# Jika tidak ingin pindah scene saat pilih "Tidak", cukup tutup dialog
		ui_dialog.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
