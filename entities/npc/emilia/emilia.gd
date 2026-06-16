extends NPCBase

var was_met: bool = false
var time: float = 0.0

func _ready() -> void:
	npc_name = "Эмилия"
	color_name = Color.AQUA
	super._ready() # Вызываем готовность из базового класса, чтобы создалось имя над головой

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
			
func start_npc_dialogue() -> void:
	var current_script = null
	
	# СЕЛЕКТОР СЦЕНАРИЕВ
	if not was_met:
		current_script = preload("res://entities/npc/emilia/dialogue/emilia_meet.gd").new()
		was_met = true
	else:
		current_script = preload("res://entities/npc/emilia/dialogue/emilia_worship.gd").new()
		
	# Записываем в базовый класс, чтобы работал _unhandled_input
	dialogue_controller = current_script
	# Запускаем менеджер диалога и передаем ему Богиню (self)
	dialogue_controller.start(self)
