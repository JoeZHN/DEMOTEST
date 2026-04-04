extends Node2D
class_name BattleController

const BATTLE_UNIT_SCENE := preload("res://scenes/battle/battle_unit.tscn")

@onready var battle_map: Node2D = $BattleMap
@onready var units_container: Node2D = $Units
@onready var effects_container: Node2D = $Effects
@onready var ui_layer: CanvasLayer = $UI

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

	var battle_config := BattleLoader.load_test_battle_config()
	battle_id = str(battle_config.get("battle_id", ""))
	battle_name = str(battle_config.get("battle_name", "Unnamed Battle"))

	var unit_data_list: Array = battle_config.get("units", [])
	_spawn_test_units(unit_data_list)

	turn_manager.setup(all_units)

	battle_state = BattleConstants.STATE_RUNNING
	_start_first_turn()
	_refresh_debug_ui()

func _spawn_test_units(unit_data_list: Array) -> void:
	all_units.clear()

	var start_x := 120.0
	var start_y := 240.0
	var spacing := 140.0

	for i in range(unit_data_list.size()):
		var data: Dictionary = unit_data_list[i]
		var unit_instance: BattleUnit = BATTLE_UNIT_SCENE.instantiate()
		units_container.add_child(unit_instance)
		unit_instance.setup(data)
		unit_instance.position = Vector2(start_x + i * spacing, start_y)
		all_units.append(unit_instance)

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

	hint_label.text = "Press Enter / Space to advance turn\nOrder: %s" % turn_manager.get_turn_order_debug_text()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_advance_turn_for_debug()
