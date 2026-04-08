extends Node
class_name SkillComponent

var skills: Array[SkillBase] = []

func setup_for_job(job: String) -> void:
	skills.clear()

	match job:
		"swordsman":
			skills.append(preload("res://scripts/battle/skills/skill_guard_stance.gd").new())
		"spearman":
			skills.append(preload("res://scripts/battle/skills/skill_push_back.gd").new())
		"archer", "raider_archer":
			skills.append(preload("res://scripts/battle/skills/skill_aimed_shot.gd").new())

func get_skill_by_index(index: int) -> SkillBase:
	if index < 0 or index >= skills.size():
		return null
	return skills[index]

func get_all_skills() -> Array[SkillBase]:
	return skills
