extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/AnimationPlayer.play("fade_out")


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	$CanvasLayer/GoBackToExtend.play("fade_in")
	$SFX.stream = load("res://Assets/Sound/Raynn.mp3")
	$SFX.play()


func _on_normal_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/sins.tscn")


func _on_go_back_to_extend_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scene/extend.tscn")
