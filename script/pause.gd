extends Control

# Sesuai dengan nama node di hierarchy screenshot kamu
@onready var animation_player = $AnimationPlayer
@onready var blur_react = $BlurReact 
@onready var panel_container = $PanelContainer

func _ready() -> void:
	# Memastikan script ini tetap jalan saat game di-pause
	process_mode = PROCESS_MODE_ALWAYS
	
	# Sembunyikan menu saat game baru mulai
	hide()
	reset_animation_state()

func _process(_delta: float) -> void:
	# Mendeteksi pencetan tombol Escape (ui_cancel)
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func pause_game():
	# Munculkan menu dan hentikan waktu game
	show()
	get_tree().paused = true
	
	# Pastikan shader tidak menghalangi klik ke tombol
	blur_react.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Mainkan animasi blur & fade (sesuaikan nama "blur" dengan di AnimationPlayer)
	animation_player.play("blur")

func resume_game():
	# Mainkan animasi mundur (fade out)
	animation_player.play_backwards("blur")
	
	# Tunggu sampai animasi benar-benar selesai baru unpause
	await animation_player.animation_finished
	
	get_tree().paused = false
	hide()
	reset_animation_state()

func reset_animation_state():
	# Memastikan shader lod balik ke 0 dan panel transparan lagi
	if blur_react.material:
		blur_react.material.set_shader_parameter("lod", 0.0)
	panel_container.modulate.a = 0.0

# --- Koneksi Signal Tombol ---

func _on_resume_pressed() -> void:
	resume_game()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	# WAJIB unpause dulu sebelum pindah ke Main Menu
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/Main_Menu.tscn")
