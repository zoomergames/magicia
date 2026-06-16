extends NPCBase

func _ready() -> void:
# вызываем готовность базового класса через super
	super._ready()
	npc_name = "Каппа"
	color_name = Color.GREEN

func _process(delta: float) -> void:
	super(delta)
	var player:CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player:
		if player.global_position.x < global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

var was_met: bool = false

func start_npc_dialogue() -> void:
	var current_script: DialogueManager = null
	
	# СЕЛЕКТОР СЦЕНАРИЕВ
	if not was_met:
		current_script = preload("res://entities/npc/kappa/dialogue/kappa_meet.gd").new()
		was_met = true # первая встреча состоялась
	else:
		current_script = preload("res://entities/npc/kappa/dialogue/kappa_worship.gd").new()
		
	# Записываем контроллер в базовый класс NPCBase, чтобы работал _unhandled_input
	dialogue_controller = current_script
	# Запускаем менеджер диалога и передаем ему Каппу (self)
	dialogue_controller.start(self)
