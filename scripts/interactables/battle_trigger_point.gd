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

	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	var combat_controller := scene_root.get_node_or_null("CombatController")
	if combat_controller == null:
		push_error("CombatController not found in current scene.")
		return

	combat_controller.enter_combat_mode("frontier_skirmish_001")
