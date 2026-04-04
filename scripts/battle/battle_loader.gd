extends RefCounted
class_name BattleLoader

const ENCOUNTER_DIR := "res://data/battle/encounters/"
const UNIT_DIR := "res://data/battle/units/"

static func load_test_battle_config() -> Dictionary:
	return load_encounter("frontier_skirmish_001")

static func load_encounter(encounter_id: String) -> Dictionary:
	var path := ENCOUNTER_DIR + encounter_id + ".json"
	return _load_json_file(path)

static func load_unit_data(unit_id: String) -> Dictionary:
	var path := UNIT_DIR + unit_id + ".json"
	return _load_json_file(path)

static func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("JSON file does not exist: " + path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()

	var json := JSON.new()
	var result := json.parse(content)
	if result != OK:
		push_error("Failed to parse JSON: " + path)
		return {}

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("JSON root must be a Dictionary: " + path)
		return {}

	return json.data
