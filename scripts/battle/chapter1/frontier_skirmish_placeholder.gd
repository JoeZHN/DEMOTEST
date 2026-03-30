extends Control

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $CenterContainer/VBoxContainer/DescriptionLabel
@onready var stage_info_label: Label = $CenterContainer/VBoxContainer/StageInfoLabel
@onready var end_battle_button: Button = $CenterContainer/VBoxContainer/EndBattleButton

func _ready() -> void:
	title_label.text = "已进入战斗"
	description_label.text = "这里将接入第一场正式战斗。"
	stage_info_label.text = "frontier_outpost_stage = %s" % [GameState.frontier_outpost_stage]

	end_battle_button.pressed.connect(_on_end_battle_button_pressed)

func _on_end_battle_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/maps/chapter1/frontier_outpost.tscn")
