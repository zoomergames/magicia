extends Resource
class_name ItemData

var item_id: String = "001"
var item_name: String = "Маленький Меч"
var weapon_name: String = "Маленький Меч"
@export var icon: Texture2D
@export var scene: PackedScene
var type: String = "cold"
var damage: int = 15
var attack_speed: float = 0.4
var cost: int = 0
var description: String = "Великий древний Маленький Меч, выкованный по приколу пьяным Каппой."
var has_magic: bool = false
