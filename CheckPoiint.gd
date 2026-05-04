extends Area2D

@onready var label = $Label
var can_interact = false

func _ready():
	label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		can_interact = true
		label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		can_interact = false
		label.visible = false

func _input(event):
	if event.is_action_pressed("interact") and can_interact:
		_activate_checkpoint()

func _activate_checkpoint():
	var player = get_tree().current_scene.find_child("Player")
	if player:
		# Update posisi di Player dan Global Manager
		player.respawn_position = global_position
		GameManager.last_checkpoint_pos = global_position
		
		# Simpan ke file permanen
		GameManager.save_data()
		
		label.text = "Checkpoint Tersimpan!"
		print("Checkpoint Aktif & Disimpan!")
