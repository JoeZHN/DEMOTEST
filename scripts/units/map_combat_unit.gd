extends CharacterBody2D
class_name MapCombatUnit

@export var unit_id: String = ""
@export var display_name: String = "Unit"
@export var camp: String = BattleConstants.CAMP_NEUTRAL
@export var job: String = ""
@export var initiative: int = 10

var grid_position: Vector2i = Vector2i.ZERO
var is_alive: bool = true
var can_move: bool = true

var stats: StatsComponent
var action: ActionComponent
var engagement: EngagementComponent
var skills: SkillComponent

func _ready() -> void:
	_ensure_components()

func _ensure_components() -> void:
	if stats == null:
		stats = StatsComponent.new()
		add_child(stats)

	if action == null:
		action = ActionComponent.new()
		add_child(action)

	if engagement == null:
		engagement = EngagementComponent.new()
		add_child(engagement)

	if skills == null:
		skills = SkillComponent.new()
		add_child(skills)

func setup_from_unit_data(data: Dictionary) -> void:
	unit_id = str(data.get("unit_id", unit_id))
	display_name = str(data.get("display_name", display_name))
	camp = str(data.get("camp", camp))
	job = str(data.get("job", job))
	initiative = int(data.get("initiative", initiative))

	_ensure_components()
	stats.setup(data)
	skills.setup_for_job(job)

func begin_turn() -> void:
	action.begin_turn()
	if stats.has_method("begin_turn"):
		stats.begin_turn()

func can_move() -> bool:
	return is_alive and not action.has_moved_this_turn and stats.current_ap > 0

func can_attack() -> bool:
	return is_alive and not action.has_acted_this_turn and stats.current_ap > 0

func spend_ap(amount: int) -> void:
	stats.current_ap = max(0, stats.current_ap - amount)

func set_grid_position(new_grid_position: Vector2i) -> void:
	grid_position = new_grid_position

func set_world_position_from_grid(grid_manager: GridManager) -> void:
	global_position = grid_manager.grid_to_world(grid_position)

func get_turn_label() -> String:
	return "%s (%s, init=%d)" % [display_name, camp, initiative]

func is_archer_unit() -> bool:
	return job == "archer" or job == "raider_archer"

func is_melee_unit() -> bool:
	return not is_archer_unit()

func move_to_grid_immediate(target_grid: Vector2i, grid_manager: GridManager) -> void:
	set_grid_position(target_grid)
	set_world_position_from_grid(grid_manager)
