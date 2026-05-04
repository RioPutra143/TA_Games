extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	$CanvasLayer/OpenGameScene.play("fade_out")
	$CanvasLayer/AnimationPlayer/ColorRect.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
	pass


func _on_play_pressed() -> void:
	$CanvasLayer/AnimationPlayer.play("fade_in")
	$SFX.stream = load("res://Assets/Sound/Raynn.mp3")
	$SFX.play()


func _on_exit_pressed() -> void:
	$CanvasLayer/ExitScene.play("fade_in")
	$SFX.stream = load("res://Assets/Sound/Raynn.mp3")
	$SFX.play()
	
  


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scene/extend.tscn")


func _on_exit_scene_animation_finished(anim_name: StringName) -> void:
	get_tree().quit()
