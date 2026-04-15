extends Node
class_name FrontierOutpostCombatController

@onready var combat_layer: Node2D = $"../CombatLayer"
@onready var runtime_controller: CombatRuntimeController = $"../CombatLayer/CombatRuntimeController"
@onready var grid_manager: GridManager = $"../CombatLayer/GridManager"
@onready var scene_root: Node = $".."

var current_mode: String = "exploration" # exploration / combat / result
var current_battle_id: String = ""

func _ready() -> void:
	combat_layer.visible = false
	runtime_controller.battle_finished.connect(exit_combat_mode)

func enter_combat_mode(battle_id: String) -> void:
	current_mode = "combat"
	current_battle_id = battle_id

	GameState.current_battle_id = battle_id
	GameState.frontier_outpost_mode = "combat"

	combat_layer.visible = true

	var runtime_data: Dictionary = _build_runtime_data(battle_id)
	runtime_controller.initialize_runtime(runtime_data)

func exit_combat_mode(result: String) -> void:
	current_mode = "exploration"
	GameState.frontier_outpost_mode = "exploration"
	GameState.current_battle_id = ""

	if result == "player_win":
		if GameState.frontier_outpost_stage < 2:
			GameState.frontier_outpost_stage = 2

	combat_layer.visible = false

func _build_runtime_data(battle_id: String) -> Dictionary:
	var encounter: Dictionary = BattleLoader.load_encounter(battle_id)
	var map_units: Dictionary = _collect_map_units()

	return {
		"battle_id": encounter.get("battle_id", battle_id),
		"battle_name": encounter.get("battle_name", "Map Combat"),
		"grid": encounter.get("grid", {}),
		"player_units": map_units.get("player_units", []),
		"enemy_units": map_units.get("enemy_units", [])
	}
func _collect_map_units() -> Dictionary:
	var player_units: Array[MapCombatUnit] = []
	var enemy_units: Array[MapCombatUnit] = []

	for node in get_tree().get_nodes_in_group("combat_player_unit"):
		if node is MapCombatUnit:
			player_units.append(node)

	for node in get_tree().get_nodes_in_group("combat_enemy_unit"):
		if node is MapCombatUnit:
			enemy_units.append(node)

	return {
		"player_units": player_units,
		"enemy_units": enemy_units
	}
