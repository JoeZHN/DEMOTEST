extends Node2D

const DIALOGUE_PATH := "res://data/dialogues/chapter1/dun_huang_inn_intro.json"

@onready var dialogue_box: DialogueBox = $DialogueBox

func _ready() -> void:
	var dialogue_lines := DialogueManager.load_dialogue(DIALOGUE_PATH)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	dialogue_box.start_dialogue(dialogue_lines)

func _on_dialogue_finished() -> void:
	print("敦煌客栈对话结束")
