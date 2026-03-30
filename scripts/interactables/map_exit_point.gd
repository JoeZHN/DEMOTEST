extends InteractableArea2D

@export var locked_prompt_text: String = "Road ahead is blocked"
@export var unlocked_prompt_text: String = "Leave merchant road"

func _process(_delta: float) -> void:
	if GameState.merchant_road_stage >= 3:
		prompt_text = unlocked_prompt_text
	else:
		prompt_text = locked_prompt_text

func interact() -> void:
	if GameState.merchant_road_stage < 3:
		print("Exit is locked. Complete the current objective first.")
		return

	get_tree().change_scene_to_file("res://scenes/maps/chapter1/merchant_road_exit_placeholder.tscn")
