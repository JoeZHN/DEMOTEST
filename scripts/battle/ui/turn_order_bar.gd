extends Control
class_name TurnOrderBar

@onready var label: Label = $Label

func refresh_text(order_text: String) -> void:
	label.text = order_text
