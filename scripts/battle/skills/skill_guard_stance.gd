extends SkillBase

func _init() -> void:
	skill_id = "guard_stance"
	display_name = "守势"
	cost_ap = 1
	range = 0
	target_type = "self"

func execute(user, target_cell: Vector2i, controller) -> bool:
	if not can_use(user, controller):
		return false

	user.spend_ap(cost_ap)
	user.action.mark_acted()

	if user.stats.get_meta("guard_stance_active", false) == false:
		user.stats.set_meta("guard_stance_active", true)

	return true
