class_name NPCBase
extends Area2D

@export var label_offset_y: float = -40.0 # Высота имени по умолчанию
@export var npc_name: String = "Имя NPC"
@export var color_name: Color = Color.WHITE

@onready var sprite = %Sprite2D
var name_label: Label = null

var dialogue_controller = null

func _ready() -> void:
	input_pickable = true
	_create_hover_label()
	
func _create_hover_label():
	name_label = Label.new()
	name_label.text = npc_name
	
	name_label.add_theme_color_override("font_color", color_name)
	
	var font = load("res://ui/font/VCR OSD Mono Nova/VCROSDMonoNova.ttf")
	if font:
		name_label.add_theme_font_override("font", font)
		name_label.add_theme_font_size_override("font_size", 12)
		
	name_label.visible = false # по умолчанию имя npc скрыто
	add_child(name_label)
	
func _process(delta: float) -> void:
	if name_label and name_label.visible:
		var text_width = name_label.size.x
		name_label.position.x = sprite.position.x - (text_width / 2.0)
		name_label.position.y = sprite.position.y + label_offset_y 
	
func _mouse_enter() -> void: # игрок проявляет интерес
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND) # курсор на руку
	sprite.modulate = Color(5, 5, 5) # подсветка белым
	if name_label: name_label.visible = true # показываем имя
	
func _mouse_exit() -> void: # обычный режим
	Input.set_default_cursor_shape(Input.CURSOR_ARROW) # курсор обычный
	sprite.modulate = Color(1, 1, 1) # обыкновенный режим спрайта
	if name_label: name_label.visible = false # не показываем имя

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Global.is_dialogue_active:
			return
		Global.start_dialogue(self) 
		start_npc_dialogue() # Вызываем функцию диалога, у каждого своя

# Пустая функция-заглушка. Её перепишет каждый конкретный NPC под себя
func start_npc_dialogue() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	# Если диалог идет, и текущий спикер — это Я
	if Global.is_dialogue_active and Global.current_speaker == self:
		if dialogue_controller and dialogue_controller.has_method("handle_input"):
			dialogue_controller.handle_input(event)
