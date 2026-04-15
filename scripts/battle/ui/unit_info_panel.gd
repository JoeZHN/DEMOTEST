extends Control
class_name UnitInfoPanel

@onready var info_label: Label = $InfoLabel

func show_unit_info(unit) -> void:
	if unit == null:
		info_label.text = "No Unit"
		return

	var engaged_text: String = "No"
	var engaged_with_text: String = "None"

	if unit.engagement != null and unit.engagement.has_valid_target():
		engaged_text = "Yes"
		engaged_with_text = unit.engagement.engaged_with.display_name

	info_label.text = (
		"Name: %s\n" % unit.display_name
		+ "Camp: %s\n" % unit.camp
		+ "Job: %s\n" % unit.job
		+ "HP: %d/%d\n" % [unit.stats.hp, unit.stats.max_hp]
		+ "AP: %d/%d\n" % [unit.stats.current_ap, unit.stats.max_ap]
		+ "Armor: %d\n" % unit.stats.armor
		+ "Base Damage: %d\n" % unit.stats.base_damage
		+ "Move Range: %d\n" % unit.stats.move_range
		+ "Grid: (%d, %d)\n" % [unit.grid_position.x, unit.grid_position.y]
		+ "Moved: %s\n" % str(unit.action.has_moved_this_turn)
		+ "Engaged: %s\n" % engaged_text
		+ "Engaged With: %s" % engaged_with_text
	)

func clear_info() -> void:
	info_label.text = "No Unit"
