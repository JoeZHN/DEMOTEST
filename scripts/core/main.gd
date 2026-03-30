extends Node2D

func _ready() -> void:
	# Keep this scene usable as a fallback entry and redirect to the real main menu.
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
