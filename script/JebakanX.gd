extends AnimatableBody2D

@export var speed: float = 100.0
@export var acceleration: float = 10.0
@export var max_dist: float = 3200.0

var is_chasing: bool = false
var start_x: float
var current_velocity: float = 0.0

# ... (bagian atas script tetap sama) ...

func _ready():
	start_x = global_position.x
	# Pastikan saat mulai game dia sembunyi
	visible = false 
	
	var trigger = get_parent().get_node("TriggerKejar")
	if trigger:
		trigger.body_entered.connect(_on_trigger_kejar_body_entered)

func _physics_process(delta):
	if is_chasing:
		# Munculkan besinya kalau sedang mengejar
		visible = true 
		
		current_velocity = move_toward(current_velocity, speed, acceleration)
		position.x += current_velocity * delta
		
		if position.x > start_x + max_dist:
			is_chasing = false
			visible = false # Sembunyi lagi kalau sudah sampai batas (opsional)
			
func _on_damage_area_body_entered(body: Node2D) -> void:
	# Cek apakah yang menabrak adalah Player
	if body.has_method("terkena_damage"):
		# 20.0 adalah jumlah darah yang berkurang
		# global_position dikirim agar Player terpental ke arah yang benar
		body.terkena_damage(20.0, global_position)
		print("Player terkena damage dari besi!")
		
func _on_trigger_kejar_body_entered(body: Node2D) -> void:
	if body.has_method("terkena_damage"): 
		is_chasing = true
		# Langsung buat kelihatan di sini juga boleh
		visible = true 
		print("Jebakan muncul dan mengejar!")
