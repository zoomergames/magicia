extends CharacterBody2D
class_name EnemyBase

@export var enemy_data: EnemyData
@export var sprite: Sprite2D

@export var detection_range: float = 300.0
@export var jump_force: float = -300.0
@export var jump_chance: float = 0.01

var max_hp: int
var speed: float
var display_name: String = ""

var current_hp: int
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead: bool = false

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
	else:
		# На всякий случай ставим стандартные статы, если забыли прикрепить ресурс
		max_hp = 50
		speed = 50.0
		printerr("Забыли прикрепить файл-ресурс .tres в инспекторе у врага: ", name)
		
	# Только ПОСЛЕ того, как max_hp заполнился, приравниваем текущее здоровье
	current_hp = max_hp
	
func take_damage(amount: int) -> void:
	current_hp -= amount
	print("[УДАР] Враг ", name, " получил урон: ", amount, ". Осталось ХП: ", current_hp)
	if current_hp <= 0:
		die(false)

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

func _physics_process(delta: float) -> void:
	die_in_abyss()
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	var player = get_tree().get_first_node_in_group("player")
	
	# Проверяем: есть игрок и он НЕ мертв
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
			# Если игрок жив, но ушел далеко — останавливаемся
			velocity.x = 0
	else:
		# Если игрок умер или его нет на сцене — останавливаемся
		velocity.x = 0
		
	move_and_slide()
