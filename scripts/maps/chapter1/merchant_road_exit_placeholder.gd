extends Control

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $CenterContainer/VBoxContainer/DescriptionLabel
@onready var stage_info_label: Label = $CenterContainer/VBoxContainer/StageInfoLabel
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton

func _ready() -> void:
	title_label.text = "Merchant Road Complete"
	description_label.text = "Current stage is complete. You can continue to the next map."
	stage_info_label.text = "merchant_road_stage = %s\ninventory = %s" % [GameState.merchant_road_stage, str(GameState.inventory)]

	continue_button.pressed.connect(_on_continue_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

func _on_continue_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/maps/chapter1/frontier_outpost.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/maps/chapter1/merchant_road.tscn")
