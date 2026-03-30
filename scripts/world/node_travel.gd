extends Node
class_name NodeTravel

static func go_to_scene(scene_path: String) -> void:
	if scene_path.is_empty():
		push_error("Scene path is empty.")
		return

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		push_error("Failed to get SceneTree.")
		return

	var error := tree.change_scene_to_file(scene_path)
	if error != OK:
		push_error("Scene change failed: " + scene_path)
