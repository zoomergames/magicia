extends NPCBase

var time: float = 0.0

func _ready() -> void:
	npc_name = "Эмилия"
	color_name = Color.AQUA
	dialogue_controller = preload("res://entities/npc/emilia/script.gd").new()
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
			
func start_npc_dialogue() -> void:
	dialogue_controller.start()
