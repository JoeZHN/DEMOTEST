extends CanvasLayer
class_name DialogueBox

signal dialogue_finished

@onready var speaker_label: Label = $DialoguePanel/MarginContainer/MainVBox/HeaderRow/SpeakerLabel
@onready var content_label: Label = $DialoguePanel/MarginContainer/MainVBox/ContentLabel
@onready var avatar_placeholder: ColorRect = $DialoguePanel/MarginContainer/MainVBox/HeaderRow/AvatarPlaceholder
@onready var continue_hint: Label = $DialoguePanel/MarginContainer/MainVBox/ContinueHint

var lines: Array = []
var current_index: int = -1
var is_running: bool = false

func _ready() -> void:
	visible = false

func start_dialogue(dialogue_lines: Array) -> void:
	if dialogue_lines.is_empty():
		emit_signal("dialogue_finished")
		return

	lines = dialogue_lines
	current_index = -1
	is_running = true
	visible = true
	_show_next_line()

func _unhandled_input(event: InputEvent) -> void:
	if not is_running or not visible:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		_show_next_line()
	elif event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_show_next_line()

func _show_next_line() -> void:
	current_index += 1

	if current_index >= lines.size():
		is_running = false
		visible = false
		emit_signal("dialogue_finished")
		return

	var line: Dictionary = lines[current_index]
	var speaker := str(line.get("speaker", ""))
	var text := str(line.get("text", ""))

	speaker_label.text = speaker
	content_label.text = text
	avatar_placeholder.color = _get_placeholder_color(speaker)

func _get_placeholder_color(speaker: String) -> Color:
	match speaker:
		"胡超":
			return Color(0.35, 0.45, 0.75, 1.0)
		"李骞":
			return Color(0.45, 0.65, 0.85, 1.0)
		"唐英":
			return Color(0.75, 0.35, 0.35, 1.0)
		_:
			return Color(0.4, 0.4, 0.4, 1.0)
