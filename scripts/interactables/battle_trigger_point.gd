extends InteractableArea2D

@export var locked_prompt_text: String = "Talk to the scout first"
@export var unlocked_prompt_text: String = "Enter battle"

func _process(_delta: float) -> void:
	if GameState.frontier_outpost_stage >= 1:
		prompt_text = unlocked_prompt_text
	else:
		prompt_text = locked_prompt_text

func interact() -> void:
	if GameState.frontier_outpost_stage < 1:
		print("Battle is locked. Talk to the scout first.")
		return

	get_tree().change_scene_to_file("res://scenes/battle/chapter1/frontier_skirmish_placeholder.tscn")
