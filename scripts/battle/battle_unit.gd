extends Node2D
class_name BattleUnit

@export var unit_id: String = ""
@export var display_name: String = "Unit"
@export var camp: String = BattleConstants.CAMP_NEUTRAL
@export var initiative: int = 0

var is_alive: bool = true

@onready var name_label: Label = $NameLabel

func _ready() -> void:
	name_label.text = display_name

func setup(data: Dictionary) -> void:
	unit_id = str(data.get("unit_id", ""))
	display_name = str(data.get("display_name", "Unit"))
	camp = str(data.get("camp", BattleConstants.CAMP_NEUTRAL))
	initiative = int(data.get("initiative", 0))

	if is_node_ready():
		name_label.text = display_name

func get_turn_label() -> String:
	return "%s (%s, init=%d)" % [display_name, camp, initiative]
