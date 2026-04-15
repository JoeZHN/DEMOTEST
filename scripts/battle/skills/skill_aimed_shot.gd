extends SkillBase

func _init() -> void:
	skill_id = "aimed_shot"
	display_name = "瞄准射击"
	cost_ap = 2
	range = 3
	target_type = "enemy"

func can_use(user, controller) -> bool:
	if not super.can_use(user, controller):
		return false

	if user.is_archer_unit() and not controller._can_unit_use_ranged_attack(user):
		return false

	return true

func execute(user, target_cell: Vector2i, controller) -> bool:
	if not can_use(user, controller):
		return false

	var target_unit = controller.grid_manager.get_unit_at_grid(controller.all_units, target_cell)
	if target_unit == null:
		return false
	if not target_unit.is_alive:
		return false
	if target_unit.camp == user.camp:
		return false

	var distance: int = controller.grid_manager.get_manhattan_distance(user.grid_position, target_unit.grid_position)
	if distance <= 0 or distance > range:
		return false

	var damage: int = int(max(1, user.stats.base_damage + 3 - target_unit.stats.armor))
	target_unit.stats.hp = int(max(0, target_unit.stats.hp - damage))

	user.spend_ap(cost_ap)
	user.action.mark_acted()

	if target_unit.stats.hp <= 0:
		target_unit.is_alive = false
		target_unit.visible = false

	return true
