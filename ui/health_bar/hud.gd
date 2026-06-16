extends CanvasLayer

func _ready() -> void:
	add_to_group("hud")
	Global.hearts_container_node = %HeartsContainer
	Global.update_hearts_display()
