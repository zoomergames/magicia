extends CharacterBody2D
class_name EnemyBase

@export var enemy_data: EnemyData
@export var sprite: Sprite2D

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
		speed = enemy_data.speed
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
	var player:CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player:
		if player.global_position.x < global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

func _physics_process(delta: float) -> void:
	die_in_abyss()
	# Гравитация
	if not is_on_floor():
		velocity.y += gravity * delta
	# Преследование игрока
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.global_position.x < global_position.x:
			velocity.x = -speed
		else:
			velocity.x = speed
	move_and_slide()
