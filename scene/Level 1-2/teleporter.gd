extends Area2D

# Referensi ke posisi tujuan (Marker2D)
@onready var target_pos = $TargetPos

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Hanya pindahkan posisi fisik player
		body.global_position = target_pos.global_position
		
		print("Teleport berhasil! (Tanpa simpan posisi)")
