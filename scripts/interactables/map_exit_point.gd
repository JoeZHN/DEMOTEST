extends InteractableArea2D

@export var locked_prompt_text: String = "前方道路未明"
@export var unlocked_prompt_text: String = "离开商路"

func _process(_delta: float) -> void:
	if GameState.merchant_road_stage >= 3:
		prompt_text = unlocked_prompt_text
	else:
		prompt_text = locked_prompt_text

func interact() -> void:
	if GameState.merchant_road_stage < 3:
		print("还不能离开商路，先完成当前目标。")
		return

	get_tree().change_scene_to_file("res://scenes/maps/chapter1/merchant_road_exit_placeholder.tscn")
