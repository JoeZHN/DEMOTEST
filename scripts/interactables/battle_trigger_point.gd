extends InteractableArea2D

@export var locked_prompt_text: String = "先与斥候交谈"
@export var unlocked_prompt_text: String = "前往异动地点"

func _process(_delta: float) -> void:
	if GameState.frontier_outpost_stage >= 1:
		prompt_text = unlocked_prompt_text
	else:
		prompt_text = locked_prompt_text

func interact() -> void:
	if GameState.frontier_outpost_stage < 1:
		print("还不能前往，先与前方斥候交谈。")
		return

	get_tree().change_scene_to_file("res://scenes/battle/chapter1/frontier_skirmish_placeholder.tscn")
