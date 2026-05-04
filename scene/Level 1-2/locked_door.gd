extends StaticBody2D

@onready var interaction_area: Area2D = $InteractionArea

func _ready():
	# Hubungkan sinyal secara otomatis via code atau lewat editor (Tab Node)
	interaction_area.body_entered.connect(_on_player_masuk)

func _on_player_masuk(body: Node2D):
	if body.name == "Player":
		if GameManager.has_key:
			_buka_pintu()
		else:
			print("Pintu butuh kunci!")

func _buka_pintu():
	print("Pintu terbuka!")
	GameManager.has_key = false # Kunci terpakai
	
	# Animasi menghilang (opsional)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	
	# Matikan tabrakan agar player bisa lewat
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Hapus pintu setelah animasi selesai
	await tween.finished
	queue_free()


func _on_interaction_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
