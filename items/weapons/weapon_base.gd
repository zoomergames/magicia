class_name WeaponBase
extends Node2D

# Сюда будут прикрепляться .tres файлы любых пушек
var weapon_data: ItemData

# БАЗОВЫЕ ХАР-КИ ОРУЖИЯ
@export var weapon_name: String = "Оружие"
@export var damage: int = 10
@export var attack_speed: float = 0.5

var is_recharging: bool = false

func _ready() -> void:
	if weapon_data:
		_update_weapon_stats()
		return
		
	var weapon_folder_name = name.to_snake_case()
	var resource_path = "res://entities/player/weapons/" + weapon_folder_name + "/" + weapon_folder_name + ".tres"
	if ResourceLoader.exists(resource_path):
		weapon_data = load(resource_path)
		_update_weapon_stats()

# ФУНКЦИЯ НАХОЖДЕНИЯ РЕСУРС-ФАЙЛА
func _update_weapon_stats() -> void:
	if weapon_data:
		weapon_name = weapon_data.weapon_name
		damage = weapon_data.damage
		attack_speed = weapon_data.attack_speed

# ФУНКЦИЯ ПЕРЕЗАРЯДКИ
func try_attack() -> void:
	if is_recharging:
		return
	is_recharging = true
	
	var attack_area = get_node_or_null("AttackArea") as Area2D
	if not attack_area:
		attack_area = get_node_or_null("%AttackArea") as Area2D

	if attack_area:
		# КРИТИЧЕСКИЙ УРОН
		var final_damage = damage
		var player = get_tree().get_first_node_in_group("player")
		if weapon_data.type == "cold":
			if not player.is_on_floor():
				final_damage = damage * 2.0
			elif player.velocity.x != 0:
				final_damage = damage * 1.5
		
		# Насильно будим геометрию зоны в Godot 4
		attack_area.monitoring = true
		attack_area.monitorable = true
		attack_area.set_meta("attack_power", final_damage)
		
		# Ждём один физический кадр, чтобы Godot 4 ТОЧНО обновил столкновения
		await get_tree().physics_frame
		
		# ПРЯМАЯ ПРОВЕРКА: Просим меч выдать список всех, кого он коснулся
		var targets = attack_area.get_overlapping_areas()
		print("[ОТЛАДКА МЕЧА]: В момент удара меч перекрывает зон: ", targets.size())
		
		for target in targets:
			print("[ОТЛАДКА МЕЧА]: Меч коснулся зоны: ", target.name, " на объекте: ", target.get_parent().name)
			
			# Получаем ссылку на самого Слайма (он родитель нашего хитбокса)
			var enemy = target.get_parent()
			
			# Проверяем: если у родителя есть наша базовая функция получения урона take_damage
			if enemy.has_method("take_damage"):
				print("[БОЙ]: Напрямую бью врага ", enemy.name, " на ", damage, " урона!")
				# Вламываем ему урон напрямую в лицо!
				enemy.take_damage(final_damage)

	attack() # Ваш визуал взмаха
	
	# Время взмаха меча
	await get_tree().create_timer(0.15).timeout
	
	if attack_area:
		attack_area.monitoring = false
		if attack_area.has_meta("attack_power"):
			attack_area.remove_meta("attack_power")
			
	await get_tree().create_timer(max(0.01, attack_speed - 0.15)).timeout
	is_recharging = false
	
# ФУНКЦИЯ АТТАКИ
func attack() -> void:
	pass
	
