extends Area2D
class_name WorldNode

signal node_selected(node_id: String, scene_path: String)

@export var node_id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var unlocked: bool = false

@onready var label: Label = $Label
@onready var button_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Sprite2D = $Sprite2D

func _ready() -> void:
	label.text = display_name
	_update_visual()

func setup(data: Dictionary) -> void:
	node_id = data.get("id", "")
	display_name = data.get("name", "")
	scene_path = data.get("scene_path", "")
	unlocked = data.get("unlocked", false)

	var pos = data.get("position", [0, 0])
	global_position = Vector2(pos[0], pos[1])

	if is_inside_tree():
		label.text = display_name
		_update_visual()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if unlocked:
			emit_signal("node_selected", node_id, scene_path)
		else:
			print("该地点尚未解锁：", display_name)

func set_unlocked(value: bool) -> void:
	unlocked = value
	_update_visual()

func _update_visual() -> void:
	if visual == null:
		return

	if unlocked:
		visual.modulate = Color(1, 1, 1, 1)
	else:
		visual.modulate = Color(0.5, 0.5, 0.5, 1)
