extends NPCBase

func _ready() -> void:
# вызываем готовность базового класса через super
	super._ready()
	dialogue_controller = preload("res://entities/npc/kappa/script.gd").new()
	
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

func start_npc_dialogue() -> void:
	dialogue_controller.start()
