extends CanvasLayer

func _ready() -> void:
	Global.hearts_container_node = %HeartsContainer
	Global.update_hearts_display()
