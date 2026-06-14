extends NPCBase

var time: float = 0.0

# Подгружаем скрипт, который полностью управляет логикой диалога
var dialogue_controller = preload("res://entities/npc/emilia/script.gd").new()

func _ready() -> void:
	npc_name = "Эмилия"
	color_name = Color.AQUA
	super._ready() # Вызываем готовность из базового класса, чтобы создалось имя над головой
	dialogue_controller.goddess_node = self 

func _process(delta: float) -> void:
	super(delta) # заставляет параллельно работать _process из базового класса npc_base!
	# плавный полет по синусоиде
	time += delta
	sprite.position.y = sin(time) * 10.0
	
	# слежка взглядом за игроком
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.global_position.x > global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
func _unhandled_input(event: InputEvent) -> void:
	if Global.is_dialogue_active and Global.current_speaker == self and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if dialogue_controller:
			dialogue_controller.handle_input(event)
			
func start_npc_dialogue() -> void:
	dialogue_controller.start()
