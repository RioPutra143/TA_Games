# Ini script yang nempel di Scene Login kamu (misal LoginUI.gd)
extends Control

@onready var email_box = $EmailInput
@onready var pass_box = $PasswordInput

func _on_register_button_pressed():
	var email = email_box.text
	var password = pass_box.text
	
	# Memanggil fungsi register yang ada di Autoload (AuthManager)
	var success = AuthManager.register_user(email, password)
	
	if success:
		print("Silakan login sekarang")
	else:
		print("Gagal daftar")

func _on_login_button_pressed():
	var email = email_box.text
	var password = pass_box.text
	
	# Memanggil fungsi login di Autoload
	var data_save = AuthManager.login_user(email, password)
	
	if data_save != null:
		# Pindah ke Scene Game jika login berhasil
		get_tree().change_scene_to_file("res://scene/Main_Menu.tscn")
	else:
		print("Email atau password salah!")
