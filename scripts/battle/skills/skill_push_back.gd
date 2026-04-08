extends SkillBase

func _init() -> void:
	skill_id = "push_back"
	display_name = "顶开"
	cost_ap = 1
	range = 1
	target_type = "enemy"

func execute(user: BattleUnit, target_cell: Vector2i, controller: BattleController) -> bool:
	if not can_use(user, controller):
		return false

	var target_unit: BattleUnit = controller.grid_manager.get_unit_at_grid(controller.all_units, target_cell)
	if target_unit == null:
		return false
	if not target_unit.is_alive:
		return false
	if target_unit.camp == user.camp:
		return false
	if controller.grid_manager.get_manhattan_distance(user.grid_position, target_unit.grid_position) != 1:
		return false

	var damage: int = int(max(1, user.stats.base_damage - 1 - target_unit.stats.armor))
	target_unit.stats.hp = int(max(0, target_unit.stats.hp - damage))

	var push_dir: Vector2i = target_unit.grid_position - user.grid_position
	var push_target: Vector2i = target_unit.grid_position + push_dir

	if controller.grid_manager.is_in_bounds(push_target):
		var occupant: BattleUnit = controller.grid_manager.get_unit_at_grid(controller.all_units, push_target)
		if occupant == null:
			target_unit.set_grid_position(push_target)
			target_unit.set_world_position_from_grid(controller.grid_manager)

	user.spend_ap(cost_ap)
	user.action.mark_acted()

	if target_unit.stats.hp <= 0:
		target_unit.is_alive = false
		target_unit.visible = false

	return true
