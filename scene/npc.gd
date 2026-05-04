extends StaticBody2D

@onready var chat_box = $Label # Sesuaikan dengan nama node chat kamu
var is_player_near = false

func _ready():
	chat_box.visible = false
	chat_box.text = "Halo! Tekan B untuk bicara."

func _process(_delta):
	# Cek apakah pemain didekatnya DAN menekan tombol B
	if is_player_near and Input.is_action_just_pressed("interact"):
		tampilkan_dialog()

func tampilkan_dialog():
	chat_box.text = "Senang bertemu denganmu, petualang!"
	chat_box.visible = true
	# Kamu bisa tambah Timer di sini untuk menutup chat otomatis
	await get_tree().create_timer(3.0).timeout
	chat_box.visible = false

# Hubungkan Signal body_entered dari Area2D ke sini
func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"): # Pastikan Player kamu masuk group "Player"
		is_player_near = true
		chat_box.text = "Tekan B untuk bicara"
		chat_box.visible = true

# Hubungkan Signal body_exited dari Area2D ke sini
func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		is_player_near = false
		chat_box.visible = false


func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
