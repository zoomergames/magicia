extends WeaponBase

func _ready() -> void:
	weapon_name = "Маленький Меч ™®℠©"
	damage = 15
	attack_speed = 0.4
	
func attack() -> void:
	print("Взмах мечом! Нанесено урона:", damage)
