extends CharacterBody2D
class_name EnemyBase

# БАЗОВЫЕ НАСТРОЙКИ
@export var enemy_data: EnemyData
@export var sprite: Sprite2D

# ЗОНА ПРЕСЛЕДОВАНИЯ
@export var detection_range: float = 300.0

# ХАОТИЧНЫЙ ПРЫЖОК
@export var jump_force: float = -300.0
@export var jump_chance: float = 0.01

# ОТБРАСЫВАНИЕ
@export var knockback_force: float = 200.0
@export var knockback_force_x: float = 250.0
@export var knockback_force_y: float = -200.0
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float


# НАДПИСЬ ИМЕНИ
@export var label_offset_y: float = -40.0
var name_label: Label = null

var display_name: String = ""

# ЗДОРОВЬЕ
var max_hp: int
var current_hp: int
var is_dead: bool = false

# АТАКА
var damage: int

# ФИЗИКА
var speed: float
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func die_in_abyss():	
	if not is_dead and global_position.y > 1000:
		is_dead = true
		die(true)

func _ready() -> void:
	# Проверяем, закинули ли мы файл .tres в переменную enemy_data
	if enemy_data:
		# Вытаскиваем характеристики из файла-ресурса
		max_hp = enemy_data.max_hp
		speed = enemy_data.speed + randf_range(-15.0, 15.0)
		display_name = enemy_data.enemy_name # Присваиваем имя из ресурса самой ноде
		damage = enemy_data.damage
	else:
		# На всякий случай ставим стандартные статы, если забыли прикрепить ресурс
		max_hp = 50
		speed = 50.0
		printerr("Забыли прикрепить файл-ресурс .tres в инспекторе у врага: ", name)
		damage = 100
		
	# Только ПОСЛЕ того, как max_hp заполнился, приравниваем текущее здоровье
	current_hp = max_hp
	
	input_pickable = true # наведение мышки включено
	_create_hover_label()
	
	
	
	
	

		
func take_damage(amount: int) -> void:
	if is_dead:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	
	if Global.inventory[Global.active_slot_index] != null:
		# Оружие ЕСТЬ в руке
		if player != null and not player.is_on_floor() and Global.inventory[Global.active_slot_index].type == "cold":
			Global.log_to_chat("[color=yellow]КРИТИЧЕСКИЙ УДАР![/color]")
	else:
		# В руке НИЧЕГО НЕТ — значит, бьем КУЛАКАМИ!
		if player != null and not player.is_on_floor():
			Global.log_to_chat("[color=yellow]КРИТИЧЕСКИЙ УДАР![/color]")
		
		
	current_hp -= amount
	print("[УДАР] Враг ", name, " получил урон: ", amount, ". Осталось ХП: ", current_hp)
	
	# 1. ОТБРАСЫВАНИЕ
	if player:
	# Направление от игрока (1 вправо, -1 влево)
		var direction = 1.0 if player.global_position.x < global_position.x else -1.0
	# Задаем импульс: летим вбок по направлению атаки и подлетаем вверх
		knockback_velocity.x = direction * knockback_force_x
		knockback_timer = 0.45 # Время отключения ИИ
		velocity.y = knockback_force_y
		
	# 2. ВИЗУАЛ КРАСНОГО ЦВЕТА
	if sprite:
		sprite.modulate = Color(10, 1, 1)
		get_tree().create_timer(0.15).timeout.connect(func():
			if is_instance_valid(sprite): sprite.modulate = Color(1, 1, 1)
		)

	# 3. ВСПЛЫВАЮЩИЙ ТЕКСТ УРОНА
	_spawn_damage_text(amount)
	
	# 4. ПРОВЕРКА СМЕРТИ
	if current_hp <= 0:
		is_dead = true # Включаем флаг смерти (он отключит ИИ и коллизии)
		
		# Отключаем хитбокс, чтобы мертвого врага нельзя было избить еще раз в полете
		var hitbox = get_node_or_null("HitBox")
		if hitbox: hitbox.queue_free()
		
		# Ждем 0.4 секунды, пока враг летит в отскоке, а текст урона красиво растворяется
		await get_tree().create_timer(0.4).timeout
		die(false) # И только теперь полностью удаляем ег

		
# ТЕКСТ УРОНА
func _spawn_damage_text(amount: int):
	var dmg_label = Label.new()
	dmg_label.text = "-" + str(amount)
	
	# стиль
	dmg_label.add_theme_color_override("font_color", Color(0.935, 0.0, 0.154, 1.0))
	# шрифт
	var font = load("res://ui/font/VCR OSD Mono Nova/VCROSDMonoNova.ttf")
	if font:
		dmg_label.add_theme_font_override("font", font)
		dmg_label.add_theme_font_size_override("font_size", 14)
	
	# ТЕПЕРЬ СТАВИМ ЛОКАЛЬНУЮ ПОЗИЦИЮ НАД ГОЛОВОЙ (относительно врага)
	dmg_label.position = Vector2(-10, label_offset_y - 15)
	
	# добавляем прям на главную сцену, чтобы текст не двигался вместе с врагом
	# ВАЖНО: Добавляем дочерним узлом к САМОМУ врагу! 
	# Теперь если враг удалится через queue_free(), этот текст сотрется вместе с ним автоматически.
	add_child(dmg_label)
	# плавно поднимаем вверх и растворяем в чистом небытии
	var tween = create_tween().set_parallel(true)
	# За 0.5 секунды поднимаем на 30 пикселей вверх
	tween.tween_property(dmg_label, "global_position:y", dmg_label.global_position.y - 30, 0.5)
	# За те же 0.5 секунды делаем его полностью прозрачным
	tween.tween_property(dmg_label, "modulate:a", 0.0, 0.5)
	
	# Как только анимация закончится, удаляем этот Label из памяти
	tween.chain().tween_callback(dmg_label.queue_free)
	

# ФУНКЦИЯ СМЕРТИ
func die(was_in_abyss: bool):
	if was_in_abyss:
		Global.log_to_chat("[color=red]" + display_name + " с криками улетел в бездну![/color]")
	else:
		Global.log_to_chat("[color=red]" + display_name + " был успешно аннигилирован![/color]")
	queue_free()
	
func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	# Проверяем, существует ли игрок и ЖИВ ли он
	if player and not player.get("is_dead"):
		var distance = global_position.distance_to(player.global_position)
		# Поворачиваем спрайт ТОЛЬКО если игрок в зоне видимости
		if distance <= detection_range:
			if player.global_position.x < global_position.x:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
				
	if name_label and name_label.visible and sprite:
		var text_width = name_label.size.x
		name_label.position.x = sprite.position.x - (text_width / 2.0)
		name_label.position.y = sprite.position.y + label_offset_y



func _physics_process(delta: float) -> void:
	die_in_abyss()
	# Гравитация работает всегда (даже для трупа в полете)
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# 2. ТРЕНИЕ ТОЛЬКО ПО ОСИ X
	# Плавно тормозим полет назад, чтобы враг не летел до конца карты
	knockback_velocity.x = move_toward(knockback_velocity.x, 0.0, 500.0 * delta)

		
	if knockback_timer > 0.0 or is_dead:
		# ИИ отключен! Скорость ходьбы равна 0, работает ТОЛЬКО чистый импульс отскока
		if knockback_timer > 0.0: knockback_timer -= delta
		# ВНИМАНИЕ: Если враг летит от удара и физически УПЁРСЯ В СТЕНУ
		if is_on_wall():
			# Мгновенно выжигаем горизонтальный импульс в ноль!
			knockback_velocity.x = 0.
		velocity.x = knockback_velocity.x
	else:
		# Враг пришел в себя! Включаем обычный режим преследования
		var player = get_tree().get_first_node_in_group("player")
		if player and not player.get("is_dead"):
			var distance = global_position.distance_to(player.global_position)
			if distance <= detection_range:
				if player.global_position.x < global_position.x:
					velocity.x = -speed
				else:
					velocity.x = speed
					
				if is_on_floor() and randf() < jump_chance:
					velocity.y = jump_force
			else:
				velocity.x = 0
		else:
			velocity.x = 0
			

	
	# заряжаем зону атаки врага его текущим уроном из ресурса
	if has_node("HurtBox"):
		$HurtBox.set_meta("attack_power", damage)
	elif has_node("Hurtbox"):
		$Hurtbox.set_meta("attack_power", damage)
	
	move_and_slide()




func _create_hover_label():
	name_label = Label.new()
	
	if enemy_data:
		name_label.text = enemy_data.enemy_name
		name_label.add_theme_color_override("font_color", enemy_data.name_color)
	else:
		name_label.text = name
		name_label.add_theme_color_override("font_color", Color.WHITE)
		
	var font = load("res://ui/font/VCR OSD Mono Nova/VCROSDMonoNova.ttf")
	if font:
		name_label.add_theme_font_override("font", font)
		name_label.add_theme_font_size_override("font_size", 12)
		
	name_label.visible = false
	add_child(name_label)
	
	
func _mouse_enter() -> void:
	if name_label: name_label.visible = true

func _mouse_exit() -> void:
	if name_label: name_label.visible = false
