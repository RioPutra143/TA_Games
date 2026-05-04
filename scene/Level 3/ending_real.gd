extends Control

@onready var label = $StoryLabel

# --- SETTING NASKAH ---
var naskah: Array = [
	"Ini Adalah Akhir Dari Perjalanannya",
	"Ia Terbangun Dari Mimpinya",
	"The End"
]

var index_naskah: int = 0
var kecepatan_ketik: float = 0.05 
var is_transitioning: bool = false # Mencegah double klik/pindah scene berkali-kali

func _ready():
	label.text = ""
	label.visible_ratio = 0.0
	tampilkan_baris_naskah()

func tampilkan_baris_naskah():
	if index_naskah < naskah.size():
		label.text = naskah[index_naskah]
		label.visible_ratio = 0.0
		
		var tween = create_tween()
		tween.tween_property(label, "visible_ratio", 1.0, label.text.length() * kecepatan_ketik)
		
		await tween.finished
		
		# Cek: Jika ini adalah baris terakhir, beri jeda lalu pindah
		if index_naskah == naskah.size() - 1:
			await get_tree().create_timer(2.5).timeout # Jeda lebih lama di teks "LEVEL 1"
			masuk_ke_game()
		else:
			_lanjut_ke_berikutnya()

func _lanjut_ke_berikutnya():
	await get_tree().create_timer(1.5).timeout
	index_naskah += 1
	tampilkan_baris_naskah()

func masuk_ke_game():
	if is_transitioning: return
	is_transitioning = true
	
	print("Berhasil memicu pindah scene")	
	
	var error = get_tree().change_scene_to_file("res://scene/Main_Menu.tscn")
	
	if error != OK:
		print("ERROR: File tidak ditemukan! Cek lagi folder tempat menyimpan scene.")

func _input(event):
	# Jika tekan Enter/Space, langsung skip ke game
	if event.is_action_pressed("ui_accept"):
		masuk_ke_game()
