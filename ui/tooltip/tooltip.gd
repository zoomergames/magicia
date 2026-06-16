extends PanelContainer

@onready var label: RichTextLabel = %DescriptionLabel

func _ready() -> void:
	visible = false
	Global.tooltip_node = self
	
func _process(_delta: float) -> void:
	if visible:
		global_position = get_global_mouse_position() + Vector2(15,15)
		
func show_tooltip(text: String) -> void:
	label.text = text
	visible = true
	
func hide_tooltip() -> void:
	visible = false
