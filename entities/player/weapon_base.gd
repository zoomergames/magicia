class_name WeaponBase
extends Node2D

# БАЗОВЫЕ ХАР-КИ ОРУЖИЯ
@export var weapon_name: String = "Оружие"
@export var damage: int = 10
@export var attack_speed: float = 0.5

var is_recharging: bool = false

# ФУНКЦИЯ ПЕРЕЗАРЯДКИ
func try_attack() -> void:
	if is_recharging: #он в перезарядке?
		return
	is_recharging = true # в перезаярдке
	attack() # аттакуем
	await get_tree().create_timer(attack_speed).timeout # ждём
	is_recharging = false # уже не в перезарядке
	
# ФУНКЦИЯ АТТАКИ
func attack() -> void:
	pass
