extends Control

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $CenterContainer/VBoxContainer/DescriptionLabel
@onready var stage_info_label: Label = $CenterContainer/VBoxContainer/StageInfoLabel
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton

func _ready() -> void:
	title_label.text = "已离开商路"
	description_label.text = "你已完成商路阶段的当前目标。\n前方的前哨区域似乎出现了新的情况。"
	stage_info_label.text = "merchant_road_stage = %s\ninventory = %s" % [GameState.merchant_road_stage, str(GameState.inventory)]

	continue_button.pressed.connect(_on_continue_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

func _on_continue_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/maps/chapter1/frontier_outpost.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/maps/chapter1/merchant_road.tscn")
