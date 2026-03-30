extends Node2D

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var battle_test_button: Button = $VBoxContainer/BattleTestButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	battle_test_button.pressed.connect(_on_battle_test_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world/chapter1_world_map.tscn")

func _on_battle_test_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/battle/chapter1/frontier_skirmish_placeholder.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
