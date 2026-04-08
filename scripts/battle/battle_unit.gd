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
var action: ActionComponent
var engagement: EngagementComponent

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

	if action == null:
		action = ActionComponent.new()
		add_child(action)

	if engagement == null:
		engagement = EngagementComponent.new()
		add_child(engagement)

	stats.setup(data)

	if is_node_ready():
		name_label.text = display_name

func set_grid_position(new_grid_pos: Vector2i) -> void:
	grid_position = new_grid_pos

func set_world_position_from_grid(grid_manager: GridManager) -> void:
	position = grid_manager.grid_to_world(grid_position)

func begin_turn() -> void:
	stats.current_ap = stats.max_ap
	action.reset_for_new_turn(stats.max_ap)

func can_move() -> bool:
	return action.can_move(stats.current_ap)

func can_attack() -> bool:
	return action.can_attack(stats.current_ap)

func spend_ap(amount: int) -> void:
	stats.current_ap = max(0, stats.current_ap - amount)

func get_turn_label() -> String:
	return "%s (%s, init=%d)" % [display_name, camp, initiative]

func is_archer_unit() -> bool:
	return job == "archer" or job == "raider_archer"

func is_melee_unit() -> bool:
	return not is_archer_unit()
