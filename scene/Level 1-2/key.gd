extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("ambil_kunci"):
			body.ambil_kunci()
			queue_free() 
