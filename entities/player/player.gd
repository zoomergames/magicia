extends CharacterBody2D

var spawn_point: Vector2

var is_frozen: bool = false # режим диалога
var is_dead: bool = false # живой, пока что

var speed: int = 200
var jump_velocity: int = -400
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_hp: int = 30
var max_base_hp: int = 100
var max_magic_hp: int = 100

@onready var sprite = %Sprite2D

func _ready():
	spawn_point = global_position
	print("Player явился")
	add_to_group("player")

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

	
func _physics_process(delta: float) -> void:
	die_in_abyss()
	var direction = Input.get_axis("move_left", "move_right") # управление
	
	if is_frozen or is_dead: # если игрок в диалоге или сдох
		velocity.x = 0
		if not is_on_floor():
			velocity.y += gravity * delta
		die_in_abyss()
		move_and_slide()
		return # стоп-кран. код ниже выполняться не будет при диалоге
	
	if not is_on_floor(): # если не на полу - падаем
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor(): # на полу? можешь прыгать
		velocity.y = jump_velocity
		
	if direction != 0:
		velocity.x = direction * speed
	else:
		velocity.x = 0
		
	if direction < 0: # если игрок повернулся влево, поварачиваем
		sprite.flip_h = true
	if direction > 0:
		sprite.flip_h = false
		
	move_and_slide()
	
