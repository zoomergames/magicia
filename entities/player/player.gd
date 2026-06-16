extends CharacterBody2D

var spawn_point: Vector2

var is_frozen: bool = false
var is_dead: bool = false

var speed: int = 200
var jump_velocity: int = -400
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_hp: int = 30
var max_base_hp: int = 100
var max_magic_hp: int = 100

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
		var path = "res://entities/player/weapons/little_sword/little_sword.tres"
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
	var direction = Input.get_axis("move_left", "move_right")
	
	if is_frozen or is_dead:
		velocity.x = 0
		if not is_on_floor():
			velocity.y += gravity * delta
		die_in_abyss()
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
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
		weapon_slot.scale.x = -1.0
	elif direction > 0:
		sprite.flip_h = false
		%WeaponSlot.position.x = hand_offset_x
		%ArmorSlot.scale.x = 1.0
		$AmuletSlot.scale.x = 1.0
		weapon_slot.scale.x = 1.0
		
	if !(is_frozen or is_dead) and Input.is_action_just_pressed("attack") and not Global.is_pointer_over_ui:
		if weapon_slot.get_child_count() > 0:
			var current_weapon = weapon_slot.get_child(0)
			current_weapon.try_attack()
			
	move_and_slide()
	die_in_abyss()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("1"):
		Global.active_slot_index = 0
		change_hand_weapon()
	if Input.is_action_just_pressed("2"):
		Global.active_slot_index = 1
		change_hand_weapon()
	if Input.is_action_just_pressed("3"):
		Global.active_slot_index = 2
		change_hand_weapon()
	if Input.is_action_just_pressed("4"):
		Global.active_slot_index = 3
		change_hand_weapon()
	if Input.is_action_just_pressed("5"):
		Global.active_slot_index = 4
		change_hand_weapon()

func change_hand_weapon() -> void:
	for child in weapon_slot.get_children():
		child.queue_free()
		
	if Global.inventory[Global.active_slot_index] == null:
		return
		
	var item_data = Global.inventory[Global.active_slot_index]
	if item_data and item_data.scene:
		var instance = item_data.scene.instantiate()
		weapon_slot.add_child(instance)


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
