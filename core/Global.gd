extends Node

signal chat_message_received

var current_speaker: Node2D = null # Ссылка на того, кто СЕЙЧАС говорит с игроком

var player_name: String = "Безымянный"; # ник по умолчанию
var name_input_node: LineEdit = null
var chat_node: RichTextLabel = null;
var is_dialogue_active: bool = false
var dialogue_step: int = 0

var hearts_container_node: HBoxContainer = null

func update_hearts_display() -> void:
	if hearts_container_node == null:
		print("[HUD] ОШИБКА: Global не видит контейнер сердец! Он равен null!")
		return
	
	for child in hearts_container_node.get_children():
		child.queue_free()
		
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
		
	var total_base_hearts: int = player.max_base_hp / 10
	var current_red_hearts: int = player.current_hp / 10
	
	for i in range(total_base_hearts):
		var heart_rect = TextureRect.new()
		
		heart_rect.custom_minimum_size = Vector2(16, 13) 
		heart_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		if i < current_red_hearts:
			heart_rect.texture = load("res://ui/health_bar/heart.png")
		else:
			heart_rect.texture = load("res://ui/health_bar/dead_heart.png")
		hearts_container_node.add_child(heart_rect)

func log_to_chat(message: String) -> void: # логика игровой панели чата
	if chat_node != null:
		chat_node.append_text(message + "\n")
		chat_message_received.emit() # Пинаем чат, чтобы он проснулся!
	else:
		print("[Система] Чат еще не готов: ", message)
		
func start_dialogue(speaker: Node2D) -> void: # начинаем диалог с npc
	current_speaker = speaker # Запомнили, кто говорит
	is_dialogue_active = true
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_frozen = true # замораживаем
		
func end_dialogue() -> void: # заканчиваем
	current_speaker = null
	is_dialogue_active = false
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_frozen = false # размораживаем
