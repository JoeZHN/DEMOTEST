extends Node

var chapter1_node_unlocks: Dictionary = {
	"dunhuang": true,
	"merchant_road": false,
	"frontier_camp": false
}

var chapter1_flags: Dictionary = {
	"dunhuang_intro_finished": false
}
var inventory: Array[String] = []
var merchant_road_stage: int = 0

func add_item(item_id: String) -> void:
	if item_id in inventory:
		return
	inventory.append(item_id)

func has_item(item_id: String) -> bool:
	return item_id in inventory

func remove_item(item_id: String) -> void:
	inventory.erase(item_id)

func unlock_node(node_id: String) -> void:
	chapter1_node_unlocks[node_id] = true

func lock_node(node_id: String) -> void:
	chapter1_node_unlocks[node_id] = false

func is_node_unlocked(node_id: String) -> bool:
	return chapter1_node_unlocks.get(node_id, false)

func set_flag(flag_name: String, value: bool) -> void:
	chapter1_flags[flag_name] = value

func get_flag(flag_name: String) -> bool:
	return chapter1_flags.get(flag_name, false)

func reset_chapter1_demo() -> void:
	chapter1_node_unlocks = {
		"dunhuang": true,
		"merchant_road": false,
		"frontier_camp": false
	}
	chapter1_flags = {
		"dunhuang_intro_finished": false
	}
