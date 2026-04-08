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
@onready var tile_overlay: TileOverlay = $BattleMap/TileOverlay
@onready var unit_info_panel: UnitInfoPanel = $UI/UnitInfoPanel
@onready var battle_camera: Camera2D = $Camera2D
@onready var attack_button: Button = $UI/DebugPanel/AttackButton
@onready var end_turn_button: Button = $UI/DebugPanel/EndTurnButton


var battle_state: String = BattleConstants.STATE_INIT
var battle_id: String = ""
var battle_name: String = ""

var all_units: Array[BattleUnit] = []
var turn_manager: TurnManager
var current_unit: BattleUnit = null
var input_mode: String = "idle" # idle / player_move / player_attack / enemy_wait
var battle_ai: BattleAI = BattleAI.new()

func _ready() -> void:
	turn_manager = TurnManager.new()
	add_child(turn_manager)

	attack_button.pressed.connect(_on_attack_button_pressed)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)

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
	tile_overlay.setup(grid_manager)
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
	var unit := turn_manager.start_first_turn()
	if unit == null:
		turn_info_label.text = "Turn: None"
		return

	_begin_current_turn()
	_refresh_debug_ui()

func _advance_turn_for_debug() -> void:
	if battle_state != BattleConstants.STATE_RUNNING:
		return

	var unit := turn_manager.advance_turn()
	if unit == null:
		turn_info_label.text = "Turn: None"
		return

	_begin_current_turn()
	_refresh_debug_ui()

func _refresh_debug_ui() -> void:
	battle_state_label.text = "Battle State: %s | %s" % [battle_state, battle_name]

	var unit := turn_manager.get_current_unit()
	if unit == null:
		turn_info_label.text = "Turn: None"
	else:
		turn_info_label.text = "Round %d | Current: %s | AP:%d" % [
			turn_manager.round_index,
			unit.get_turn_label(),
			unit.stats.current_ap
		]

	if battle_state == BattleConstants.STATE_FINISHED:
		return

	hint_label.text = (
		"Left Click: move or attack target\n"
		+ "Attack Button: enter attack mode\n"
		+ "End Turn: next turn\n"
		+ "Grid: %dx%d  Cell:%d\n" % [grid_manager.cols, grid_manager.rows, grid_manager.cell_size]
		+ "Mode: %s\n" % input_mode
		+ "Order: %s" % turn_manager.get_turn_order_debug_text()
	)

func _unhandled_input(event: InputEvent) -> void:
	if battle_state != BattleConstants.STATE_RUNNING:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		var clicked_cell := _get_mouse_grid_position()

		if input_mode == "player_move":
			_try_move_current_unit_to(clicked_cell)
		elif input_mode == "player_attack":
			_try_attack_current_unit_to(clicked_cell)


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

func _begin_current_turn() -> void:
	current_unit = turn_manager.get_current_unit()

	if current_unit == null:
		input_mode = "idle"
		unit_info_panel.clear_info()
		tile_overlay.clear_all()
		return

	current_unit.begin_turn()
	unit_info_panel.show_unit_info(current_unit)

	if current_unit.camp == BattleConstants.CAMP_PLAYER:
		input_mode = "player_move"
		_show_current_unit_move_range()
		_refresh_debug_ui()
	else:
		input_mode = "enemy_wait"
		tile_overlay.clear_all()
		_refresh_debug_ui()
		_run_enemy_turn()

func _show_current_unit_move_range() -> void:
	if current_unit == null:
		tile_overlay.clear_all()
		return

	var move_cells := grid_manager.get_cells_in_move_range(
		current_unit.grid_position,
		current_unit.stats.move_range
	)

	# 排除被单位占用的格子，但保留自己当前格
	var filtered_cells: Array[Vector2i] = []
	for cell in move_cells:
		var occupant := grid_manager.get_unit_at_grid(all_units, cell)
		if occupant == null or occupant == current_unit:
			filtered_cells.append(cell)

	tile_overlay.set_move_cells(filtered_cells)
	tile_overlay.set_attack_cells([])
	tile_overlay.set_selected_cell(current_unit.grid_position)
	
func _show_current_unit_attack_range() -> void:
	if current_unit == null:
		tile_overlay.clear_all()
		return

	var attack_range := 1
	if current_unit.job == "archer":
		attack_range = 3

	var attack_cells := grid_manager.get_cells_in_attack_range(
		current_unit.grid_position,
		attack_range
	)

	tile_overlay.set_move_cells([])
	tile_overlay.set_attack_cells(attack_cells)
	tile_overlay.set_selected_cell(current_unit.grid_position)
	
func _try_move_current_unit_to(target_cell: Vector2i) -> void:
	if current_unit == null:
		return

	if input_mode != "player_move":
		return

	if not current_unit.can_move():
		return

	if not grid_manager.is_in_bounds(target_cell):
		return

	var move_cells := grid_manager.get_cells_in_move_range(
		current_unit.grid_position,
		current_unit.stats.move_range
	)

	if target_cell not in move_cells:
		return

	var occupant := grid_manager.get_unit_at_grid(all_units, target_cell)
	if occupant != null and occupant != current_unit:
		return

	current_unit.set_grid_position(target_cell)
	current_unit.set_world_position_from_grid(grid_manager)
	current_unit.action.mark_moved()

	unit_info_panel.show_unit_info(current_unit)
	_show_current_unit_move_range()
	
func _get_mouse_grid_position() -> Vector2i:
	return grid_manager.world_to_grid(get_global_mouse_position())
	
func _on_attack_button_pressed() -> void:
	if current_unit == null:
		return

	if current_unit.camp != BattleConstants.CAMP_PLAYER:
		return

	if not current_unit.can_attack():
		return

	input_mode = "player_attack"
	_show_current_unit_attack_range()
func _on_end_turn_button_pressed() -> void:
	if current_unit == null:
		return

	_advance_turn_for_debug()
func _try_attack_current_unit_to(target_cell: Vector2i) -> void:
	if current_unit == null:
		return

	if input_mode != "player_attack":
		return

	if not current_unit.can_attack():
		return

	var attack_range := 1
	if current_unit.job == "archer":
		attack_range = 3

	var distance := grid_manager.get_manhattan_distance(current_unit.grid_position, target_cell)
	if distance <= 0 or distance > attack_range:
		return

	var target_unit := grid_manager.get_unit_at_grid(all_units, target_cell)
	if target_unit == null:
		return

	if target_unit.camp == current_unit.camp:
		return

	var final_damage: int = int(max(1, current_unit.stats.base_damage - target_unit.stats.armor))
	target_unit.stats.hp = int(max(0, target_unit.stats.hp - final_damage))

	current_unit.spend_ap(1)
	current_unit.action.mark_acted()

	if target_unit.stats.hp <= 0:
		target_unit.is_alive = false
		target_unit.visible = false

	var result: String = _check_battle_result()
	if result != "":
		_apply_battle_result(result)
		return

	input_mode = "player_move"
	unit_info_panel.show_unit_info(current_unit)
	_show_current_unit_move_range()
	_refresh_debug_ui()

func _run_enemy_turn() -> void:
	if current_unit == null:
		return

	if not current_unit.is_alive:
		_finish_enemy_turn()
		return

	if current_unit.camp != BattleConstants.CAMP_ENEMY:
		return

	await get_tree().create_timer(0.25).timeout

	var target_unit: BattleUnit = battle_ai.find_nearest_player_unit(current_unit, all_units, grid_manager)
	if target_unit == null:
		_finish_enemy_turn()
		return

	if battle_ai.can_attack_target(current_unit, target_unit, grid_manager):
		_enemy_try_attack(target_unit)
		return

	var best_move_cell: Vector2i = battle_ai.find_best_move_cell_toward_target(
		current_unit,
		target_unit,
		all_units,
		grid_manager
	)

	if best_move_cell != current_unit.grid_position:
		_enemy_try_move(best_move_cell)
		await get_tree().create_timer(0.2).timeout

	if target_unit.is_alive and battle_ai.can_attack_target(current_unit, target_unit, grid_manager):
		_enemy_try_attack(target_unit)
		return

	_finish_enemy_turn()
	
func _enemy_try_move(target_cell: Vector2i) -> void:
	if current_unit == null:
		return
	if not current_unit.is_alive:
		return
	if not grid_manager.is_in_bounds(target_cell):
		return

	var occupant: BattleUnit = grid_manager.get_unit_at_grid(all_units, target_cell)
	if occupant != null and occupant != current_unit:
		return

	current_unit.set_grid_position(target_cell)
	current_unit.set_world_position_from_grid(grid_manager)
	current_unit.action.mark_moved()

	unit_info_panel.show_unit_info(current_unit)
	_refresh_debug_ui()
func _enemy_try_attack(target_unit: BattleUnit) -> void:
	if current_unit == null or target_unit == null:
		return
	if not current_unit.is_alive or not target_unit.is_alive:
		_finish_enemy_turn()
		return

	var final_damage: int = int(max(1, current_unit.stats.base_damage - target_unit.stats.armor))
	target_unit.stats.hp = int(max(0, target_unit.stats.hp - final_damage))

	current_unit.spend_ap(1)
	current_unit.action.mark_acted()

	if target_unit.stats.hp <= 0:
		target_unit.is_alive = false
		target_unit.visible = false

	var result: String = _check_battle_result()
	if result != "":
		_apply_battle_result(result)
		return

	unit_info_panel.show_unit_info(current_unit)
	_refresh_debug_ui()

	await get_tree().create_timer(0.2).timeout
	_finish_enemy_turn()
func _finish_enemy_turn() -> void:
	if battle_state != BattleConstants.STATE_RUNNING:
		return

	_advance_turn_for_debug()
func _check_battle_result() -> String:
	var alive_players: int = 0
	var alive_enemies: int = 0

	for unit in all_units:
		if unit == null:
			continue
		if not unit.is_alive:
			continue

		if unit.camp == BattleConstants.CAMP_PLAYER:
			alive_players += 1
		elif unit.camp == BattleConstants.CAMP_ENEMY:
			alive_enemies += 1

	if alive_enemies == 0:
		return "player_win"

	if alive_players == 0:
		return "enemy_win"

	return ""
func _apply_battle_result(result: String) -> void:
	battle_state = BattleConstants.STATE_FINISHED
	input_mode = "idle"
	tile_overlay.clear_all()

	match result:
		"player_win":
			hint_label.text = "Victory"
		"enemy_win":
			hint_label.text = "Defeat"
		_:
			hint_label.text = "Battle Finished"

	_refresh_debug_ui()
