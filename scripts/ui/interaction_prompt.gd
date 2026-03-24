extends Label

func show_prompt(text_value: String) -> void:
	text = text_value
	visible = true

func hide_prompt() -> void:
	visible = false
