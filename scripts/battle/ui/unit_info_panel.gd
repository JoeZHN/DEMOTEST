extends Control
class_name UnitInfoPanel

@onready var info_label: Label = $InfoLabel

func show_unit_info(unit: BattleUnit) -> void:
	if unit == null:
		info_label.text = "No Unit"
		return

	info_label.text = (
		"Name: %s\n" % unit.display_name
		+ "Camp: %s\n" % unit.camp
		+ "Job: %s\n" % unit.job
		+ "HP: %d/%d\n" % [unit.stats.hp, unit.stats.max_hp]
		+ "AP: %d/%d\n" % [unit.stats.current_ap, unit.stats.max_ap]
		+ "Grid: (%d, %d)\n" % [unit.grid_position.x, unit.grid_position.y]
		+ "Moved: %s" % str(unit.action.has_moved_this_turn)
	)

func clear_info() -> void:
	info_label.text = "No Unit"
