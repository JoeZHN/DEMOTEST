extends Node
class_name CombatRuntimeController

signal battle_finished(result: String)

const BATTLE_UNIT_SCENE := preload("res://scenes/battle/battle_unit.tscn")

@onready var combat_layer: Node2D = $".."
@onready var units_container: Node2D = $"../CombatUnits"
@onready var effects_container: Node2D = $"../Effects"
@onready var grid_manager: GridManager = $"../GridManager"
@onready var tile_overlay: TileOverlay = $"../TileOverlay"

@onready var unit_info_panel: UnitInfoPanel = $"../CombatUI/UnitInfoPanel"
@onready var bottom_skill_bar = $"../CombatUI/BottomSkillBar"
@onready var attack_button_large: Button = $"../CombatUI/BottomSkillBar/CenterContainer/HBoxContainer/AttackButtonLarge"
@onready var skill_button_1: Button = $"../CombatUI/BottomSkillBar/CenterContainer/HBoxContainer/SkillButton1"
@onready var skill_button_2: Button = $"../CombatUI/BottomSkillBar/CenterContainer/HBoxContainer/SkillButton2"
@onready var skill_button_3: Button = $"../CombatUI/BottomSkillBar/CenterContainer/HBoxContainer/SkillButton3"
@onready var end_turn_button_large: Button = $"../CombatUI/BottomSkillBar/CenterContainer/HBoxContainer/EndTurnButtonLarge"
@onready var turn_order_bar = $"../CombatUI/TurnOrderBar"

var battle_state: String = BattleConstants.STATE_INIT
var battle_id: String = ""
var battle_name: String = ""

var all_units: Array[BattleUnit] = []
var turn_manager: TurnManager
var current_unit: BattleUnit = null
var input_mode: String = "idle" # idle / player_move / player_attack / player_skill / enemy_wait
var battle_ai: BattleAI = BattleAI.new()
var selected_skill: SkillBase = null

func _ready() -> void:
	turn_manager = TurnManager.new()
	add_child(turn_manager)

	attack_button_large.pressed.connect(_on_attack_button_pressed)
	end_turn_button_large.pressed.connect(_on_end_turn_button_pressed)
	skill_button_1.pressed.connect(func(): _on_skill_button_pressed(0))
	skill_button_2.pressed.connect(func(): _on_skill_button_pressed(1))
	skill_button_3.pressed.connect(func(): _on_skill_button_pressed(2))

func initialize_runtime(runtime_data: Dictionary) -> void:
	battle_state = BattleConstants.STATE_SETUP

	battle_id = str(runtime_data.get("battle_id", ""))
	battle_name = str(runtime_data.get("battle_name", "Map Combat"))

	var grid_data: Dictionary = runtime_data.get("grid", {})
	grid_manager.setup(grid_data)
	tile_overlay.setup(grid_manager)

	_spawn_runtime_units(runtime_data)

	turn_manager.setup(all_units)

	battle_state = BattleConstants.STATE_RUNNING
	_start_first_turn()
	_refresh_runtime_ui()


func _spawn_runtime_units(runtime_data: Dictionary) -> void:
	all_units.clear()

	for child in units_container.get_children():
		child.queue_free()

	var player_units: Array = runtime_data.get("player_units", [])
	var enemy_units: Array = runtime_data.get("enemy_units", [])

	for spawn_data in player_units:
		_spawn_single_unit_from_spawn_data(spawn_data)

	for spawn_data in enemy_units:
		_spawn_single_unit_from_spawn_data(spawn_data)


func _start_first_turn() -> void:
	var unit := turn_manager.start_first_turn()
	if unit == null:
		return

	_begin_current_turn()
	_refresh_runtime_ui()

func _advance_turn_for_debug() -> void:
	if battle_state != BattleConstants.STATE_RUNNING:
		return

	var unit := turn_manager.advance_turn()
	if unit == null:
		return

	_begin_current_turn()
	_refresh_runtime_ui()

func _unhandled_input(event: InputEvent) -> void:
	if battle_state != BattleConstants.STATE_RUNNING:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		var clicked_cell: Vector2i = _get_mouse_grid_position()

		var clicked_unit: BattleUnit = _get_alive_unit_at_cell(clicked_cell)
		if clicked_unit != null:
			unit_info_panel.show_unit_info(clicked_unit)

			if input_mode == "player_attack":
				if clicked_unit.camp != current_unit.camp:
					_try_attack_current_unit_to(clicked_cell)
				return

			if input_mode == "player_skill":
				_try_use_selected_skill(clicked_cell)
				return

			return

		if input_mode == "player_move":
			_try_move_current_unit_to(clicked_cell)
		elif input_mode == "player_attack":
			_try_attack_current_unit_to(clicked_cell)
		elif input_mode == "player_skill":
			_try_use_selected_skill(clicked_cell)

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
	bottom_skill_bar.refresh_for_unit(current_unit)
	selected_skill = null

	if current_unit.camp == BattleConstants.CAMP_PLAYER:
		input_mode = "player_move"
		_show_current_unit_move_range()
		_refresh_runtime_ui()
	else:
		input_mode = "enemy_wait"
		tile_overlay.clear_all()
		_refresh_runtime_ui()
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
	
func _show_selected_skill_range() -> void:
	if current_unit == null or selected_skill == null:
		tile_overlay.clear_all()
		return

	var skill_cells := grid_manager.get_cells_in_attack_range(
		current_unit.grid_position,
		selected_skill.range
	)

	tile_overlay.set_move_cells([])
	tile_overlay.set_attack_cells(skill_cells)
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

	if _will_disengage(current_unit, target_cell):
		var engaged_target: BattleUnit = current_unit.engagement.engaged_with
		_apply_opportunity_attack(engaged_target, current_unit)

		if not current_unit.is_alive or battle_state != BattleConstants.STATE_RUNNING:
			unit_info_panel.show_unit_info(current_unit)
			_refresh_runtime_ui()
			return

		current_unit.engagement.clear_engagement()
		if engaged_target != null and engaged_target.engagement != null and engaged_target.engagement.engaged_with == current_unit:
			engaged_target.engagement.clear_engagement()
	
	current_unit.set_grid_position(target_cell)
	current_unit.set_world_position_from_grid(grid_manager)
	current_unit.action.mark_moved()

	unit_info_panel.show_unit_info(current_unit)
	bottom_skill_bar.refresh_for_unit(current_unit)
	_show_current_unit_move_range()
	
func _get_mouse_grid_position() -> Vector2i:
	return grid_manager.world_to_grid(get_global_mouse_position())
func _get_alive_unit_at_cell(cell: Vector2i) -> BattleUnit:
	var unit: BattleUnit = grid_manager.get_unit_at_grid(all_units, cell)
	if unit == null:
		return null
	if not unit.is_alive:
		return null
	return unit
func _inspect_clicked_unit(cell: Vector2i) -> bool:
	var clicked_unit: BattleUnit = _get_alive_unit_at_cell(cell)
	if clicked_unit == null:
		return false

	unit_info_panel.show_unit_info(clicked_unit)
	return true

func _on_attack_button_pressed() -> void:
	if current_unit == null:
		return

	if current_unit.camp != BattleConstants.CAMP_PLAYER:
		return

	if not current_unit.can_attack():
		return

	if current_unit.is_archer_unit() and not _can_unit_use_ranged_attack(current_unit):
		unit_info_panel.show_unit_info(current_unit)
		return

	input_mode = "player_attack"
	_show_current_unit_attack_range()
	
func _on_skill_button_pressed(index: int) -> void:
	if current_unit == null:
		return
	if current_unit.camp != BattleConstants.CAMP_PLAYER:
		return

	var skill: SkillBase = current_unit.skills.get_skill_by_index(index)
	if skill == null:
		return
	if not skill.can_use(current_unit, self):
		return

	selected_skill = skill

	if skill.target_type == "self":
		var success: bool = skill.execute(current_unit, current_unit.grid_position, self)
		if success:
			selected_skill = null
			input_mode = "player_move"
			unit_info_panel.show_unit_info(current_unit)
			bottom_skill_bar.refresh_for_unit(current_unit)
			_refresh_runtime_ui()
		return

	input_mode = "player_skill"
	_show_selected_skill_range()
	
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
	
	if current_unit.is_archer_unit() and not _can_unit_use_ranged_attack(current_unit):
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

	if current_unit.is_melee_unit() and _is_adjacent(current_unit.grid_position, target_unit.grid_position):
		_create_engagement(current_unit, target_unit)

	if target_unit.stats.hp <= 0:
		target_unit.is_alive = false
		target_unit.visible = false
		_clear_engagement_if_needed(current_unit)
		_clear_engagement_if_needed(target_unit)

	var result: String = _check_battle_result()
	if result != "":
		_apply_battle_result(result)
		return

	input_mode = "player_move"
	unit_info_panel.show_unit_info(current_unit)
	bottom_skill_bar.refresh_for_unit(current_unit)
	_show_current_unit_move_range()
	_refresh_runtime_ui()
	
func _try_use_selected_skill(target_cell: Vector2i) -> void:
	if current_unit == null:
		return
	if selected_skill == null:
		return
	if input_mode != "player_skill":
		return

	var success: bool = selected_skill.execute(current_unit, target_cell, self)
	if not success:
		return

	selected_skill = null
	input_mode = "player_move"

	_clear_engagement_if_needed(current_unit)

	var result: String = _check_battle_result()
	if result != "":
		_apply_battle_result(result)
		return

	unit_info_panel.show_unit_info(current_unit)
	bottom_skill_bar.refresh_for_unit(current_unit)
	_show_current_unit_move_range()
	_refresh_runtime_ui()


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

	if current_unit.is_archer_unit() and not _can_unit_use_ranged_attack(current_unit):
		var best_move_cell: Vector2i = battle_ai.find_best_move_cell_toward_target(
			current_unit,
			target_unit,
			all_units,
			grid_manager
		)

		if best_move_cell != current_unit.grid_position:
			_enemy_try_move(best_move_cell)
			await get_tree().create_timer(0.2).timeout

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
	
	if _will_disengage(current_unit, target_cell):
		var engaged_target: BattleUnit = current_unit.engagement.engaged_with
		_apply_opportunity_attack(engaged_target, current_unit)

		if not current_unit.is_alive or battle_state != BattleConstants.STATE_RUNNING:
			_refresh_runtime_ui()
			return

		current_unit.engagement.clear_engagement()
		if engaged_target != null and engaged_target.engagement != null and engaged_target.engagement.engaged_with == current_unit:
			engaged_target.engagement.clear_engagement()

	current_unit.set_grid_position(target_cell)
	current_unit.set_world_position_from_grid(grid_manager)
	current_unit.action.mark_moved()

	unit_info_panel.show_unit_info(current_unit)
	_refresh_runtime_ui()
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

	if current_unit.is_melee_unit() and _is_adjacent(current_unit.grid_position, target_unit.grid_position):
		_create_engagement(current_unit, target_unit)

	if target_unit.stats.hp <= 0:
		target_unit.is_alive = false
		target_unit.visible = false

	_clear_engagement_if_needed(current_unit)
	_clear_engagement_if_needed(target_unit)

	var result: String = _check_battle_result()
	if result != "":
		_apply_battle_result(result)
		return

	unit_info_panel.show_unit_info(current_unit)
	_refresh_runtime_ui()

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

	emit_signal("battle_finished", result)
	_refresh_runtime_ui()

func _is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return grid_manager.get_manhattan_distance(a, b) == 1

func _create_engagement(unit_a: BattleUnit, unit_b: BattleUnit) -> void:
	if unit_a == null or unit_b == null:
		return
	if not unit_a.is_alive or not unit_b.is_alive:
		return

	unit_a.engagement.engage(unit_b)
	unit_b.engagement.engage(unit_a)

	unit_info_panel.show_unit_info(unit_a)
func _clear_engagement_if_needed(unit: BattleUnit) -> void:
	if unit == null:
		return
	if unit.engagement == null:
		return

	if not unit.engagement.has_valid_target():
		unit.engagement.clear_engagement()
		return

	var other: BattleUnit = unit.engagement.engaged_with
	if other == null or not other.is_alive:
		unit.engagement.clear_engagement()
		return

	if not _is_adjacent(unit.grid_position, other.grid_position):
		unit.engagement.clear_engagement()
func _can_unit_use_ranged_attack(unit: BattleUnit) -> bool:
	if unit == null:
		return false

	if not unit.is_archer_unit():
		return true

	if unit.engagement != null and unit.engagement.has_valid_target():
		return false

	return true
func _will_disengage(unit: BattleUnit, target_cell: Vector2i) -> bool:
	if unit == null:
		return false
	if unit.engagement == null:
		return false
	if not unit.engagement.has_valid_target():
		return false

	var engaged_target: BattleUnit = unit.engagement.engaged_with
	if engaged_target == null or not engaged_target.is_alive:
		return false

	if not _is_adjacent(unit.grid_position, engaged_target.grid_position):
		return false

	return not _is_adjacent(target_cell, engaged_target.grid_position)
func _apply_opportunity_attack(attacker: BattleUnit, target: BattleUnit) -> void:
	if attacker == null or target == null:
		return
	if not attacker.is_alive or not target.is_alive:
		return

	var opportunity_damage: int = int(max(1, int(attacker.stats.base_damage * 0.5) - target.stats.armor))
	target.stats.hp = int(max(0, target.stats.hp - opportunity_damage))

	if target.stats.hp <= 0:
		target.is_alive = false
		target.visible = false

	_clear_engagement_if_needed(attacker)
	_clear_engagement_if_needed(target)

	var result: String = _check_battle_result()
	if result != "":
		_apply_battle_result(result)
		
func _refresh_runtime_ui() -> void:
	var unit := turn_manager.get_current_unit()
	if unit != null:
		bottom_skill_bar.refresh_for_unit(unit)

	turn_order_bar.refresh_text(turn_manager.get_turn_order_debug_text())
