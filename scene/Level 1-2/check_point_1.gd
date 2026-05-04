extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Cek apakah yang masuk adalah Player
	if body.name == "Player" or body.has_method("take_damage"):
		# Simpan posisi ke GameManager agar permanen antar scene
		GameManager.last_checkpoint_pos = global_position
		
		# Update respawn internal player supaya kalau mati langsung balik ke sini
		if "respawn_position" in body:
			body.respawn_position = global_position
			
		print("Auto Save Berhasil di: ", global_position)
		GameManager.save_data()

func tampilkan_notifikasi():
	if has_node("Label"):
		$Label.text = "Game Disimpan!"
		await get_tree().create_timer(1.5).timeout
		$Label.text = "" # Hilangkan teks setelah 1.5 detik
