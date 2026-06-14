extends NPCBase

var dialogue_controller = preload("res://entities/npc/kappa/kappa_script.gd").new()

func _ready() -> void:
# вызываем готовность базового класса через super
	super._ready()
	
	dialogue_controller.kappa_node = self
	npc_name = "Каппа"
	color_name = Color.GREEN

func _process(delta: float) -> void:
	super(delta)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.global_position.x < global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

func _unhandled_input(event: InputEvent) -> void:
	# Если диалог сейчас активен, и игрок КЛИКНУЛ левой кнопкой мыши по экрану
	if Global.is_dialogue_active and Global.current_speaker == self and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if dialogue_controller:
			# Передаем клик в изолированный скрипт!
			dialogue_controller.handle_input(event)

func start_npc_dialogue() -> void:
	dialogue_controller.start()
