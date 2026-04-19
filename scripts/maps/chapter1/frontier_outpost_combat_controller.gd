extends Node
class_name FrontierOutpostCombatController

@onready var combat_layer: Node2D = $"../CombatLayer"
@onready var runtime_controller: CombatRuntimeController = $"../CombatLayer/CombatRuntimeController"
@onready var grid_manager: GridManager = $"../CombatLayer/GridManager"

@onready var hu_chao: MapCombatUnit = $"../Characters/HuChao"
@onready var ally_spearman: MapCombatUnit = $"../Characters/AllySpearman"
@onready var ally_archer: MapCombatUnit = $"../Characters/AllyArcher"
@onready var enemy_raider_01: MapCombatUnit = $"../Characters/EnemyRaider01"
@onready var enemy_raider_02: MapCombatUnit = $"../Characters/EnemyRaider02"
@onready var enemy_raider_archer_01: MapCombatUnit = $"../Characters/EnemyRaiderArcher01"

@onready var hu_chao_battle_start: Marker2D = $"../Markers/HuChaoBattleStart"
@onready var ally_spearman_battle_start: Marker2D = $"../Markers/AllySpearmanBattleStart"
@onready var ally_archer_battle_start: Marker2D = $"../Markers/AllyArcherBattleStart"
@onready var enemy_raider_01_battle_start: Marker2D = $"../Markers/EnemyRaider01BattleStart"
@onready var enemy_raider_02_battle_start: Marker2D = $"../Markers/EnemyRaider02BattleStart"
@onready var enemy_raider_archer_01_battle_start: Marker2D = $"../Markers/EnemyRaiderArcher01BattleStart"

var current_mode: String = "exploration"
var current_battle_id: String = ""

func _ready() -> void:
	combat_layer.visible = false
	runtime_controller.battle_finished.connect(exit_combat_mode)

func _build_unit_data_map() -> Dictionary:
	return {
		"HuChao": {
			"unit_id": "hu_chao",
			"display_name": "胡超",
			"camp": BattleConstants.CAMP_PLAYER,
			"job": "swordsman",
			"initiative": 14,
			"max_hp": 16,
			"armor": 2,
			"move_range": 3,
			"max_ap": 2,
			"base_damage": 4
		},
		"AllySpearman": {
			"unit_id": "ally_spearman",
			"display_name": "枪兵",
			"camp": BattleConstants.CAMP_PLAYER,
			"job": "spearman",
			"initiative": 12,
			"max_hp": 18,
			"armor": 2,
			"move_range": 3,
			"max_ap": 2,
			"base_damage": 4
		},
		"AllyArcher": {
			"unit_id": "ally_archer",
			"display_name": "弓手",
			"camp": BattleConstants.CAMP_PLAYER,
			"job": "archer",
			"initiative": 13,
			"max_hp": 12,
			"armor": 1,
			"move_range": 3,
			"max_ap": 2,
			"base_damage": 3
		},
		"EnemyRaider01": {
			"unit_id": "enemy_raider_01",
			"display_name": "掠袭者甲",
			"camp": BattleConstants.CAMP_ENEMY,
			"job": "raider",
			"initiative": 10,
			"max_hp": 14,
			"armor": 1,
			"move_range": 3,
			"max_ap": 2,
			"base_damage": 3
		},
		"EnemyRaider02": {
			"unit_id": "enemy_raider_02",
			"display_name": "掠袭者乙",
			"camp": BattleConstants.CAMP_ENEMY,
			"job": "raider",
			"initiative": 9,
			"max_hp": 14,
			"armor": 1,
			"move_range": 3,
			"max_ap": 2,
			"base_damage": 3
		},
		"EnemyRaiderArcher01": {
			"unit_id": "enemy_raider_archer_01",
			"display_name": "敌弓手",
			"camp": BattleConstants.CAMP_ENEMY,
			"job": "raider_archer",
			"initiative": 11,
			"max_hp": 10,
			"armor": 0,
			"move_range": 3,
			"max_ap": 2,
			"base_damage": 3
		}
	}

func _prepare_battle_units() -> void:
	var unit_data_map: Dictionary = _build_unit_data_map()

	var unit_start_map: Dictionary = {
		"HuChao": hu_chao_battle_start.global_position,
		"AllySpearman": ally_spearman_battle_start.global_position,
		"AllyArcher": ally_archer_battle_start.global_position,
		"EnemyRaider01": enemy_raider_01_battle_start.global_position,
		"EnemyRaider02": enemy_raider_02_battle_start.global_position,
		"EnemyRaiderArcher01": enemy_raider_archer_01_battle_start.global_position
	}

	var unit_map: Dictionary = {
		"HuChao": hu_chao,
		"AllySpearman": ally_spearman,
		"AllyArcher": ally_archer,
		"EnemyRaider01": enemy_raider_01,
		"EnemyRaider02": enemy_raider_02,
		"EnemyRaiderArcher01": enemy_raider_archer_01
	}

	for node_name in unit_map.keys():
		var unit: MapCombatUnit = unit_map[node_name]
		if unit == null:
			continue

		if unit_data_map.has(node_name):
			unit.setup_from_unit_data(unit_data_map[node_name])

		if unit_start_map.has(node_name):
			unit.global_position = unit_start_map[node_name]

		unit.is_alive = true
		unit.visible = true

func enter_combat_mode(battle_id: String) -> void:
	current_mode = "combat"
	current_battle_id = battle_id

	GameState.current_battle_id = battle_id
	GameState.frontier_outpost_mode = "combat"

	_prepare_battle_units()

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
