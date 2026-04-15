extends RefCounted
class_name SkillBase

var skill_id: String = ""
var display_name: String = "Skill"
var cost_ap: int = 1
var range: int = 0
var target_type: String = "self" # self / enemy / cell

func can_use(user, controller) -> bool:
	if user == null:
		return false
	if not user.is_alive:
		return false
	return user.stats.current_ap >= cost_ap

func execute(user, target_cell: Vector2i, controller) -> bool:
	return false
