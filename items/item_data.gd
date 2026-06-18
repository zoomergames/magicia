extends Resource
class_name ItemData

@export var item_id: String = "001"
@export var item_name: String = "Предмет"
@export var weapon_name: String = "Оружие"
@export var icon: Texture2D
@export var scene: PackedScene
@export var type: String = "cold"
@export var damage: int = 15
@export var attack_speed: float = 0.4
@export var cost: int = 0
@export var description: String = "Описание предмета."
@export var has_magic: bool = false
