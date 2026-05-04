extends Area2D

@export var damage_per_second: float = 2000.0

func _physics_process(delta):
	# Ambil semua objek yang sedang tumpang tindih dengan gergaji
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body.has_method("terkena_damage"):
			# Damage dikali delta agar adil (misal 50 HP per detik)
			body.terkena_damage(damage_per_second * delta, global_position)

# Tentukan jumlah damage yang diberikan jebakan ini
