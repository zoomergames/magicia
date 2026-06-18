extends CharacterBody2D

# СПАВН-ПОИНТ
var spawn_point: Vector2

# СОСТОЯНИЯ
var is_frozen: bool = false
var is_dead: bool = false
var has_amulet: bool = false

# ФИЗИКА
var speed: int = 200
var jump_velocity: int = -400
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var knockback_timer: float = 0.0

# ЗДОРОВЬЕ
var current_hp: int = 30
var max_base_hp: int = 100

var current_magic_hp: int = 0
var max_magic_hp: int = 100

var invulnerability_timer: float = 0.0

# КУЛАК
var current_damage: int = 5
var current_attack_speed: float = 0.3

@onready var sprite = %Sprite2D
@onready var weapon_slot = %WeaponSlot
@onready var hand_offset_x = %WeaponSlot.position.x

func _ready():
	spawn_point = global_position
	add_to_group("player")
	
	# Загружаем стартовое снаряжение из визуальных слотов в инвентарь
	_sync_inventory_from_visual_slots()
	
	check_magic_hearts_activation()

func _sync_inventory_from_visual_slots() -> void:
	print("=== СИНХРОНИЗАЦИЯ ИНВЕНТАРЯ ИЗ ВИЗУАЛЬНЫХ СЛОТОВ ===")
	
	# Оружие
	if weapon_slot.get_child_count() > 0:
		var path = "res://items/weapons/little_sword/little_sword.tres"
		print("Загружаю оружие по пути: ", path)
		var data = load(path)
		print("Получен объект: ", data)
		if data:
			print("Имя оружия: ", data.item_name)
		Global.inventory[0] = data
	else:
		print("WeaponSlot пуст")
	
	# Броня
	if $ArmorSlot.get_child_count() > 0:
		var path = "res://items/armors/super_costume/super_costume.tres"
		print("Загружаю броню по пути: ", path)
		var data = load(path)
		print("Получен объект: ", data)
		if data:
			print("Имя брони: ", data.item_name)
		Global.inventory[6] = data
	else:
		print("ArmorSlot пуст")
	
	# Амулет
	if $AmuletSlot.get_child_count() > 0:
		var path = "res://items/artifacts/magisyanik_hand/magisyanik_hand.tres"
		print("Загружаю амулет по пути: ", path)
		var data = load(path)
		print("Получен объект: ", data)
		if data:
			print("Имя амулета: ", data.item_name)
		Global.inventory[5] = data
	else:
		print("AmuletSlot пуст")
	
	print("=== КОНЕЦ СИНХРОНИЗАЦИИ ===")
	
	var inv_ui = get_tree().get_first_node_in_group("inventory_ui")
	if inv_ui:
		inv_ui.update_all_slots()
	# Обновляем иконки в инвентаре

func die_in_abyss():	
	if not is_dead and global_position.y > 1000:
		is_dead = true
		current_hp = 0
		visible = false
		Global.update_hearts_display()
		
		Global.log_to_chat("[color=red]%s[/color] выпал из этого мира" % Global.player_name)
		await get_tree().create_timer(1.0).timeout
		Global.log_to_chat("[color=gray]возрождение через 3...[/color]")
		await get_tree().create_timer(1.0).timeout
		Global.log_to_chat("[color=gray]2...[/color]")
		await get_tree().create_timer(1.0).timeout
		Global.log_to_chat("[color=gray]1...[/color]")
		await get_tree().create_timer(1.0).timeout
		global_position = spawn_point
		velocity = Vector2.ZERO
		visible = true
		current_hp = 30
		is_dead = false
		Global.update_hearts_display()
		Global.log_to_chat("[color=green]Вы успешно возродились![/color]")
		check_magic_hearts_activation()

func _physics_process(delta: float) -> void:
	if invulnerability_timer > 0.0:
		invulnerability_timer -= delta
	var direction = Input.get_axis("move_left", "move_right")
	
	if is_dead and knockback_timer <= 0.0 and visible:
		_start_death_logic()
		
	if is_frozen  or (is_dead and knockback_timer <= 0.0):
		velocity.x = 0
		if not is_on_floor():
			velocity.y += gravity * delta
		die_in_abyss()
		move_and_slide()
		return
		
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if knockback_timer <= 0.0:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			
		if direction != 0:
			velocity.x = direction * speed
		else:
			velocity.x = 0
			
		if direction < 0:
			sprite.flip_h = true
			%WeaponSlot.position.x = -hand_offset_x
			%ArmorSlot.scale.x = -1.0
			$AmuletSlot.scale.x = -1.0
			%FistAttackArea.scale.x = -1.0
			weapon_slot.scale.x = -1.0
		elif direction > 0:
			sprite.flip_h = false
			%WeaponSlot.position.x = hand_offset_x
			%ArmorSlot.scale.x = 1.0
			$AmuletSlot.scale.x = 1.0
			%FistAttackArea.scale.x = 1.0
			weapon_slot.scale.x = 1.0
	else:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, 1500.0 * delta)
		
	# атака
	if !(is_frozen or is_dead) and Input.is_action_just_pressed("attack") and get_viewport().gui_get_hovered_control() == null:
		if weapon_slot.get_child_count() > 0:
			var current_weapon = weapon_slot.get_child(0)
			current_weapon.try_attack()
		else:
			# бьём кулаком
			_execute_fist_attack()
			
			
	# атакуют игрока
	if not is_dead and invulnerability_timer <= 0.0 and has_node("HitBox"):
		# var enemy_areas: Array = %HitBox.get_overlapping_areas()
		
		var query = PhysicsShapeQueryParameters2D.new()
		query.collide_with_areas = true
		query.collide_with_bodies = false
		query.shape = %HitBox.get_node("CollisionShape2D").shape
		query.transform = %HitBox.global_transform
		query.collision_mask = 32
		
		var intersections = get_world_2d().direct_space_state.intersect_shape(query)
		for result in intersections:
			var enemy_area = result.collider as Area2D
			if enemy_area and enemy_area.has_meta("attack_power"):
				print("[ОТЛАДКА ИГРОКА]: Нашёл метаданные урона врага! Вызываю take_damage.")
				var damage_area = enemy_area.get_meta("attack_power")
				take_damage(damage_area, enemy_area)
				break
			else:
				print("[ОТЛАДКА ИГРОКА]: Ошибка! На зоне врага НЕТ метаданных 'attack_power'.")
			
	move_and_slide()
	die_in_abyss()
	
	
var is_fist_recharging: bool = false
func _execute_fist_attack():
	if is_fist_recharging:
		return
	is_fist_recharging = true
	print("Удар кулаком! Нанесено урона: ", current_damage)
	
	# подключаем hurtbox кулака
	if has_node("FistAttackArea"):
		%FistAttackArea.set_meta("attack_power", current_damage)
		%FistAttackArea.monitoring = true
		%FistAttackArea.monitorable = true
		
		await get_tree().physics_frame
		
		# проверяем, кого задели
		var targets = %FistAttackArea.get_overlapping_areas()
		for target in targets:
			var enemy = target.get_parent()
			if enemy.has_method("take_damage"):
				enemy.take_damage(current_damage)
				
		await get_tree().create_timer(0.1).timeout
		%FistAttackArea.monitoring = false
		if %FistAttackArea.has_meta("attack_power"):
			%FistAttackArea.remove_meta("attack_power")
		
		await get_tree().create_timer(current_attack_speed).timeout
		is_fist_recharging = false
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("slot_1"):
		Global.active_slot_index = 0
		change_hand_weapon()
	if Input.is_action_just_pressed("slot_2"):
		Global.active_slot_index = 1
		change_hand_weapon()
	if Input.is_action_just_pressed("slot_3"):
		Global.active_slot_index = 2
		change_hand_weapon()
	if Input.is_action_just_pressed("slot_4"):
		Global.active_slot_index = 3
		change_hand_weapon()
	if Input.is_action_just_pressed("slot_5"):
		Global.active_slot_index = 4
		change_hand_weapon()

func change_hand_weapon() -> void:
	# удаляем старое оружие из рук
	for child in weapon_slot.get_children():
		child.queue_free()
	
	# если слот пуст - включаем кулаки
	if Global.inventory[Global.active_slot_index] == null:
		var fist_data = load("res://items/weapons/fist/fist.tres")
		if fist_data:
			current_damage = fist_data.damage
			current_attack_speed = fist_data.attack_speed
		return
		
	# если в слоте есть оружие	
	var item_data = Global.inventory[Global.active_slot_index]
	if item_data and item_data.scene:
		var instance = item_data.scene.instantiate()
		
		if "weapon_data" in instance:
			instance.weapon_data = item_data
		weapon_slot.add_child(instance)
		
		# Сбрасываем урон игрока на урон меча, чтобы кулаки не смешивались с оружием
		current_damage = item_data.damage
		current_attack_speed = item_data.attack_speed


func check_magic_hearts_activation() -> void:
	if has_node("AmuletSlot") and $AmuletSlot.get_child_count() > 0:
		var amulet_data = Global.inventory[5]
		if amulet_data != null and amulet_data.get("mana_bonus") != null:
			max_magic_hp = amulet_data.mana_bonus
			print("[Магия] Амулет активен! Добавлено магических ХП: ", max_magic_hp)
			Global.update_hearts_display()
			return
	max_magic_hp = 0
	Global.update_hearts_display()
	
func take_damage(amount: int, enemy_area: Area2D):
	if is_dead:
		return
	
	current_hp -= amount
	invulnerability_timer = 1.5
	print("[ИГРОК] Получил урон: ", amount, ". Осталось ХП: ", current_hp)
	
	Global.update_hearts_display()
	if current_hp <= 0:
		is_dead = true
		current_hp = 0
		# _start_death_logic()
		
	if enemy_area != null:
		if enemy_area.global_position.x < global_position.x:
			velocity.x = 350.0
		else:
			velocity.x = -350.0
		velocity.y = -150.0
		knockback_timer = 0.2

		
	if amount:
		sprite.modulate = Color(10, 1, 1) # Гипер-красный
		get_tree().create_timer(0.15).timeout.connect(func(): sprite.modulate = Color(1, 1, 1))

		
func _start_death_logic() -> void:
	visible = false
	
	Global.log_to_chat("[color=red]%s[/color] был аннигилирован монстрами!" % Global.player_name)
	await get_tree().create_timer(1.0).timeout
	Global.log_to_chat("[color=gray]возрождение через 3...[/color]")
	await get_tree().create_timer(1.0).timeout
	Global.log_to_chat("[color=gray]2...[/color]")
	await get_tree().create_timer(1.0).timeout
	Global.log_to_chat("[color=gray]1...[/color]")
	await get_tree().create_timer(1.0).timeout
	
	global_position = spawn_point
	velocity = Vector2.ZERO
	visible = true
	current_hp = 30 # Ваше стартовое ХП при респавне
	is_dead = false
	Global.update_hearts_display()
	Global.log_to_chat("[color=green]Вы успешно возродились![/color]")
	check_magic_hearts_activation()

func _process(_delta: float) -> void:
	# 1. ОБРАБОТКА НАЖАТИЯ ЦИФР 1-7
	if Input.is_action_just_pressed("slot_1"): _change_active_slot(0)
	elif Input.is_action_just_pressed("slot_2"): _change_active_slot(1)
	elif Input.is_action_just_pressed("slot_3"): _change_active_slot(2)
	elif Input.is_action_just_pressed("slot_4"): _change_active_slot(3)
	elif Input.is_action_just_pressed("slot_5"): _change_active_slot(4)
	elif Input.is_action_just_pressed("slot_6"): _change_active_slot(5)
	elif Input.is_action_just_pressed("slot_7"): _change_active_slot(6)

	# 2. ОБРАБОТКА ПРОКРУТКИ КОЛЁСИКА
	if Input.is_action_just_pressed("next_slot"):
		var new_slot = Global.active_slot_index + 1
		if new_slot > 4: new_slot = 0
		_change_active_slot(new_slot)
		
	elif Input.is_action_just_pressed("prev_slot"):
		var new_slot = Global.active_slot_index - 1
		if new_slot < 0: new_slot = 4
		_change_active_slot(new_slot)

# Вспомогательная функция для применения выбора
func _change_active_slot(index: int) -> void:
	Global.active_slot_index = index
	
	# Просим инвентарь перерисовать рамки (вызываем метод из нашего inventory_ui)
	get_tree().call_group("inventory_ui", "update_all_slots")
	
	# Сами обновляем оружие в руках у игрока
	if has_method("change_hand_weapon"):
		change_hand_weapon()
