extends Node2D
class_name BattleController

const BATTLE_UNIT_SCENE := preload("res://scenes/battle/battle_unit.tscn")

@onready var battle_map: Node2D = $BattleMap
@onready var grid_visual: Node2D = $BattleMap/GridVisual
@onready var units_container: Node2D = $Units
@onready var effects_container: Node2D = $Effects
@onready var ui_layer: CanvasLayer = $UI
@onready var grid_manager: GridManager = $GridManager

@onready var battle_state_label: Label = $UI/DebugPanel/BattleStateLabel
@onready var turn_info_label: Label = $UI/DebugPanel/TurnInfoLabel
@onready var hint_label: Label = $UI/DebugPanel/HintLabel


var battle_state: String = BattleConstants.STATE_INIT
var battle_id: String = ""
var battle_name: String = ""

var all_units: Array[BattleUnit] = []
var turn_manager: TurnManager

func _ready() -> void:
	turn_manager = TurnManager.new()
	add_child(turn_manager)

	_start_test_battle()

func _start_test_battle() -> void:
	battle_state = BattleConstants.STATE_SETUP
	_refresh_debug_ui()

	var battle_config := BattleLoader.load_encounter("frontier_skirmish_001")
	if battle_config.is_empty():
		push_error("Failed to load encounter data.")
		return

	battle_id = str(battle_config.get("battle_id", ""))
	battle_name = str(battle_config.get("battle_name", "Unnamed Battle"))

	var grid_data: Dictionary = battle_config.get("grid", {})
	grid_manager.setup(grid_data)

	if grid_visual.has_method("setup"):
		grid_visual.setup(
			grid_manager.cols,
			grid_manager.rows,
			grid_manager.cell_size,
			grid_manager.origin
		)

	_spawn_encounter_units(battle_config)

	turn_manager.setup(all_units)

	battle_state = BattleConstants.STATE_RUNNING
	_start_first_turn()
	_refresh_debug_ui()

func _spawn_encounter_units(battle_config: Dictionary) -> void:
	all_units.clear()

	for child in units_container.get_children():
		child.queue_free()

	var player_units: Array = battle_config.get("player_units", [])
	var enemy_units: Array = battle_config.get("enemy_units", [])

	for spawn_data in player_units:
		_spawn_single_unit_from_spawn_data(spawn_data)

	for spawn_data in enemy_units:
		_spawn_single_unit_from_spawn_data(spawn_data)

func _start_first_turn() -> void:
	var current_unit := turn_manager.start_first_turn()
	if current_unit == null:
		turn_info_label.text = "Turn: None"
		return

	turn_info_label.text = "Round %d | Current: %s" % [
		turn_manager.round_index,
		current_unit.get_turn_label()
	]

func _advance_turn_for_debug() -> void:
	if battle_state != BattleConstants.STATE_RUNNING:
		return

	var current_unit := turn_manager.advance_turn()
	if current_unit == null:
		turn_info_label.text = "Turn: None"
	else:
		turn_info_label.text = "Round %d | Current: %s" % [
			turn_manager.round_index,
			current_unit.get_turn_label()
		]

	_refresh_debug_ui()

func _refresh_debug_ui() -> void:
	battle_state_label.text = "Battle State: %s | %s" % [battle_state, battle_name]

	var current_unit := turn_manager.get_current_unit()
	if current_unit == null:
		turn_info_label.text = "Turn: None"
	else:
		turn_info_label.text = "Round %d | Current: %s" % [
			turn_manager.round_index,
			current_unit.get_turn_label()
		]

	hint_label.text = (
	"Press Enter / Space to advance turn\n"
	+ "Grid: %dx%d  Cell:%d\n" % [grid_manager.cols, grid_manager.rows, grid_manager.cell_size]
	+ "Order: %s" % turn_manager.get_turn_order_debug_text()
)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_advance_turn_for_debug()
		
func _spawn_single_unit_from_spawn_data(spawn_data: Dictionary) -> void:
	var unit_id := str(spawn_data.get("unit_id", ""))
	var spawn_array: Array = spawn_data.get("spawn", [])

	if unit_id.is_empty() or spawn_array.size() < 2:
		push_error("Invalid spawn data.")
		return

	var unit_data := BattleLoader.load_unit_data(unit_id)
	if unit_data.is_empty():
		push_error("Failed to load unit data for: " + unit_id)
		return

	var grid_pos := Vector2i(int(spawn_array[0]), int(spawn_array[1]))
	if not grid_manager.is_in_bounds(grid_pos):
		push_error("Spawn out of bounds for unit: " + unit_id)
		return

	var unit_instance: BattleUnit = BATTLE_UNIT_SCENE.instantiate()
	units_container.add_child(unit_instance)
	unit_instance.setup(unit_data)
	unit_instance.set_grid_position(grid_pos)
	unit_instance.position = grid_manager.grid_to_world(grid_pos)

	all_units.append(unit_instance)
