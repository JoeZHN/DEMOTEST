extends Node2D

const NODE_SCENE_PATH := "res://scenes/world/world_node.tscn"
const MAP_DATA_PATH := "res://data/maps/chapter1_world_nodes.json"

@onready var nodes_container: Node = $Nodes
@onready var title_label: Label = $UI/TitleLabel
@onready var hint_label: Label = $UI/HintLabel

var map_data: Dictionary = {}
var spawned_nodes: Dictionary = {}

func _ready() -> void:
	#title_label.text = "第一章地图"
	#hint_label.text = "点击节点前往地点"
	_load_map_data()
	_spawn_nodes()

func _load_map_data() -> void:
	if not FileAccess.file_exists(MAP_DATA_PATH):
		push_error("地图数据文件不存在: " + MAP_DATA_PATH)
		return

	var file := FileAccess.open(MAP_DATA_PATH, FileAccess.READ)
	var content := file.get_as_text()
	var json := JSON.new()
	var result := json.parse(content)

	if result != OK:
		push_error("地图 JSON 解析失败")
		return

	map_data = json.data

func _spawn_nodes() -> void:
	if not map_data.has("nodes"):
		return

	var node_scene: PackedScene = load(NODE_SCENE_PATH)

	for node_data in map_data["nodes"]:
		var node_instance = node_scene.instantiate()
		nodes_container.add_child(node_instance)
		node_instance.setup(node_data)
		node_instance.node_selected.connect(_on_node_selected)
		spawned_nodes[node_data["id"]] = node_instance

func _on_node_selected(node_id: String, scene_path: String) -> void:
	print("选择节点：", node_id)
	NodeTravel.go_to_scene(scene_path)

func unlock_node(node_id: String) -> void:
	if spawned_nodes.has(node_id):
		spawned_nodes[node_id].set_unlocked(true)
