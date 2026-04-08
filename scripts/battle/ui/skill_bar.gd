extends Control
class_name SkillBar

@onready var current_unit_label: Label = $CenterContainer/HBoxContainer/CurrentUnitLabel
@onready var attack_button_large: Button = $CenterContainer/HBoxContainer/AttackButtonLarge
@onready var skill_button_1: Button = $CenterContainer/HBoxContainer/SkillButton1
@onready var skill_button_2: Button = $CenterContainer/HBoxContainer/SkillButton2
@onready var skill_button_3: Button = $CenterContainer/HBoxContainer/SkillButton3
@onready var end_turn_button_large: Button = $CenterContainer/HBoxContainer/EndTurnButtonLarge

func refresh_for_unit(unit: BattleUnit) -> void:
	if unit == null:
		current_unit_label.text = "No Unit"
		skill_button_1.text = "-"
		skill_button_2.text = "-"
		skill_button_3.text = "-"
		skill_button_1.disabled = true
		skill_button_2.disabled = true
		skill_button_3.disabled = true
		return

	current_unit_label.text = "%s  AP:%d/%d" % [unit.display_name, unit.stats.current_ap, unit.stats.max_ap]

	var skill_list: Array[SkillBase] = unit.skills.get_all_skills()

	_set_skill_button(skill_button_1, skill_list, 0, unit)
	_set_skill_button(skill_button_2, skill_list, 1, unit)
	_set_skill_button(skill_button_3, skill_list, 2, unit)

func _set_skill_button(button: Button, skill_list: Array[SkillBase], index: int, unit: BattleUnit) -> void:
	var skill: SkillBase = null
	if index >= 0 and index < skill_list.size():
		skill = skill_list[index]

	if skill == null:
		button.text = "-"
		button.disabled = true
		return

	button.text = "%s (%dAP)" % [skill.display_name, skill.cost_ap]
	button.disabled = unit.stats.current_ap < skill.cost_ap
