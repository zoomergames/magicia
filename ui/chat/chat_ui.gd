extends CanvasLayer

var regex = RegEx.new()
var old_text: String = ""
var is_mouse_inside: bool = false
var fade_tween: Tween = null
var hide_timer: SceneTreeTimer = null  # <-- новый таймер

@onready var panel = %Panel

func _ready() -> void:
	Global.chat_node = $Panel/RichTextLabel
	Global.name_input_node = $NameInput
	regex.compile("^[a-zA-Z0-9а-яА-ЯёЁ]*$")
	$NameInput.text_changed.connect(_on_name_text_changed)
	Global.chat_message_received.connect(on_new_message)
	reset_hide_timer()
	Global.log_to_chat("[color=gray][Система][/color] [color=white]Игрок явился в мир![/color]")

func _on_name_text_changed(new_text: String) -> void:
	if regex.search(new_text):
		old_text = new_text
	else:
		$NameInput.text = old_text
		($NameInput as LineEdit).caret_column = old_text.length()

func on_new_message() -> void:
	show_chat_instantly()
	reset_hide_timer()  # <-- сбрасываем таймер при каждом новом сообщении

func _on_panel_mouse_entered() -> void:
	is_mouse_inside = true
	show_chat_instantly()
	if hide_timer:
		hide_timer.timeout.disconnect(_on_hide_timer_timeout)  # отключаем старый
		hide_timer = null

func _on_panel_mouse_exited() -> void:
	is_mouse_inside = false
	reset_hide_timer()

func show_chat_instantly() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	panel.modulate.a = 1.0

func reset_hide_timer() -> void:
	if hide_timer:
		hide_timer.timeout.disconnect(_on_hide_timer_timeout)
	hide_timer = get_tree().create_timer(4.0)
	hide_timer.timeout.connect(_on_hide_timer_timeout)

func _on_hide_timer_timeout() -> void:
	if not is_mouse_inside and not Global.is_dialogue_active:
		fade_out_chat()
	hide_timer = null

func fade_out_chat() -> void:
	if is_mouse_inside or Global.is_dialogue_active:
		return
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(panel, "modulate:a", 0.0, 1.0)
