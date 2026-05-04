extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/AnimationPlayer.play("fade_out")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_pressed() -> void:
	$CanvasLayer/BackToMenu.play("fade_in")
	$SFX.stream = load("res://Assets/Sound/Raynn.mp3")
	$SFX.play()

# Di script Menu kamu

func _on_newgame_pressed() -> void:
	GameManager.reset_data()
	$CanvasLayer/GoToLevel.play("fade_in")
	$SFX.stream = load("res://Assets/Sound/Raynn.mp3")
	$SFX.play()


func _on_load_pressed() -> void:
	# Coba load data dulu
	if GameManager.load_data():
		# Jika ada save data, pindah ke level
		get_tree().change_scene_to_file(GameManager.current_scene_path)
	else:
		print("Tidak ada file save!")
		


func _on_back_to_menu_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scene/Main_Menu.tscn")
	
func _on_go_to_level_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scene/Cutscene.tscn")
