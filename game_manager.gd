extends Node

const SAVE_PATH = "user://savegame.data"

var last_checkpoint_pos: Vector2 = Vector2.ZERO
var has_key: bool = false
var current_scene_path = "res://scene/Sins.tscn" # Default awal game

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		# Kita bungkus semua data ke dalam satu paket (Dictionary)
		var data_to_save = {
			"pos_x": last_checkpoint_pos.x,
			"pos_y": last_checkpoint_pos.y,
			"scene": get_tree().current_scene.scene_file_path # Ini yang mencatat kamu di Goa atau Sins
		}
		file.store_var(data_to_save)
		file.close()
		print("Data Berhasil Disimpan! Lokasi: ", data_to_save.scene)

func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var loaded_data = file.get_var()
			# Ambil lagi datanya dari paket
			last_checkpoint_pos.x = loaded_data.get("pos_x", 0)
			last_checkpoint_pos.y = loaded_data.get("pos_y", 0)
			current_scene_path = loaded_data.get("scene", "res://scene/Sins.tscn")
			
			file.close()
			print("Data Berhasil Dimuat! Level tujuan: ", current_scene_path)
			return true
	return false

func reset_data():
	last_checkpoint_pos = Vector2.ZERO
	current_scene_path = "res://scene/Sins.tscn"
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	print("Data di-reset")
