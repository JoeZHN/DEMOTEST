extends Node
class_name NodeTravel

static func go_to_scene(scene_path: String) -> void:
	if scene_path.is_empty():
		push_error("场景路径为空，无法跳转")
		return

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		push_error("无法获取 SceneTree")
		return

	var error := tree.change_scene_to_file(scene_path)
	if error != OK:
		push_error("场景切换失败: " + scene_path)
