class_name DialogueManager
extends RefCounted

var npc_node: Node2D = null # Ссылка на NPC, который говорит
var dialogue_step: int = 0  # Текущий шаг
var prefix: String = ""     # Красивый цветной префикс [Имя]

# Запуск диалога
func start(target_npc: Node2D) -> void:
	npc_node = target_npc
	dialogue_step = 0
	
	# Автоматически генерируем цветной префикс для чата, чтобы сценарий об этом не думал!
	var hex_color = npc_node.color_name.to_html(false)
	prefix = "[color=#%s][%s][/color]" % [hex_color, npc_node.npc_name]
	
	advance_dialogue()

# Глобальный перехватчик Enter / Space
func handle_input(event: InputEvent) -> void:
	# Если на экране горит ввод ника — блокируем клавиатуру
	if Global.name_input_node and Global.name_input_node.visible:
		return
		
	if event.is_action_pressed("ui_accept"):
		npc_node.get_viewport().set_input_as_handled() # Съедаем нажатие
		advance_dialogue()

# Двигаем шаг вперед
func advance_dialogue() -> void:
	dialogue_step += 1
	run_dialogue_step() # Вызываем кастомный шаг из файла сценария

# Эту функцию перепишет конкретный файл сценария (там будут только тексты и ивенты)
func run_dialogue_step() -> void:
	pass

# Быстрый и удобный финал диалога для всех
func end_dialogue() -> void:
	dialogue_step = 0
	Global.end_dialogue()
