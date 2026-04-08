extends Node
class_name EngagementComponent

var is_engaged: bool = false
var engaged_with: BattleUnit = null

func engage(target: BattleUnit) -> void:
	is_engaged = target != null
	engaged_with = target

func clear_engagement() -> void:
	is_engaged = false
	engaged_with = null

func has_valid_target() -> bool:
	return is_engaged and engaged_with != null and engaged_with.is_alive
