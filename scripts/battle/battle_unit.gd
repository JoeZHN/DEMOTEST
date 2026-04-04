extends Node2D
class_name BattleUnit

@export var unit_id: String = ""
@export var display_name: String = "Unit"
@export var camp: String = BattleConstants.CAMP_NEUTRAL
@export var initiative: int = 0
@export var job: String = ""

var is_alive: bool = true
var grid_position: Vector2i = Vector2i.ZERO

@onready var name_label: Label = $NameLabel

var stats: StatsComponent

func _ready() -> void:
	name_label.text = display_name

func setup(data: Dictionary) -> void:
	unit_id = str(data.get("unit_id", ""))
	display_name = str(data.get("display_name", "Unit"))
	camp = str(data.get("camp", BattleConstants.CAMP_NEUTRAL))
	initiative = int(data.get("initiative", 0))
	job = str(data.get("job", ""))

	if stats == null:
		stats = StatsComponent.new()
		add_child(stats)

	stats.setup(data)

	if is_node_ready():
		name_label.text = display_name

func set_grid_position(new_grid_pos: Vector2i) -> void:
	grid_position = new_grid_pos

func get_turn_label() -> String:
	return "%s (%s, init=%d)" % [display_name, camp, initiative]
