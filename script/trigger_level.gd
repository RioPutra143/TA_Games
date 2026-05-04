extends Area2D

# Kamu bisa ganti path scene tujuan lewat Inspector
@export_file("Cutscene2.tscn") var target_scene: String

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("terkena_damage"):
		if target_scene == "": # Cek jika string kosong
			print("Peringatan: Target scene belum diisi di Inspector!")
			return
		
		# GANTI BARIS INI:
		get_tree().call_deferred("change_scene_to_file", target_scene)
