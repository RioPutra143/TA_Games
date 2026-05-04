extends Node

# Path folder penyimpanan akun
const USER_DATA_PATH = "user://accounts/"

func _ready():
	# Pastikan direktori penyimpanan sudah ada
	if not DirAccess.dir_exists_absolute(USER_DATA_PATH):
		DirAccess.make_dir_absolute(USER_DATA_PATH)

# Fungsi Validasi Format Gmail
func is_valid_gmail(email: String) -> bool:
	var regex = RegEx.new()
	# Memastikan format nama@gmail.com
	regex.compile("^[a-zA-Z0-9_.+-]+@gmail\\.com$")
	return regex.search(email) != null

# Fungsi Registrasi
func register_user(email, password):
	if not is_valid_gmail(email):
		print("Format harus Gmail (@gmail.com)")
		return false
	
	var file_path = USER_DATA_PATH + email.replace("@", "_at_") + ".json"
	
	if FileAccess.file_exists(file_path):
		print("Email sudah terdaftar!")
		return false
	
	var account_data = {
		"email": email,
		"password": password, # Catatan: Untuk produksi, gunakan enkripsi/hashing
		"save_data": {
			"level": 1,
			"score": 0,
			"inventory": []
		}
	}
	
	save_to_local(file_path, account_data)
	print("Registrasi Berhasil!")
	return true

# Fungsi Login
func login_user(email, password):
	var file_path = USER_DATA_PATH + email.replace("@", "_at_") + ".json"
	
	if not FileAccess.file_exists(file_path):
		print("Akun tidak ditemukan")
		return null
		
	var data = load_from_local(file_path)
	if data["password"] == password:
		print("Login Berhasil!")
		return data["save_data"] # Mengembalikan data save game unik user
	else:
		print("Password salah")
		return null

func save_to_local(path, data):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	file.store_string(json_string)

func load_from_local(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	return JSON.parse_string(content)
