extends RefCounted
class_name DialogueManager

static func load_dialogue(dialogue_path: String) -> Array:
	if not FileAccess.file_exists(dialogue_path):
		push_error("对话文件不存在: " + dialogue_path)
		return []

	var file := FileAccess.open(dialogue_path, FileAccess.READ)
	var content := file.get_as_text()

	var json := JSON.new()
	var result := json.parse(content)
	if result != OK:
		push_error("对话 JSON 解析失败: " + dialogue_path)
		return []

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("对话数据格式错误，根对象必须是 Dictionary")
		return []

	if not data.has("lines"):
		push_error("对话数据缺少 lines 字段: " + dialogue_path)
		return []

	if typeof(data["lines"]) != TYPE_ARRAY:
		push_error("对话数据 lines 必须是 Array: " + dialogue_path)
		return []

	return data["lines"]
