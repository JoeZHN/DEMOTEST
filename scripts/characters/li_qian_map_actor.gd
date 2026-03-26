extends Area2D

signal interaction_entered
signal interaction_exited

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.name == "HuChao":
		interaction_entered.emit()

func _on_body_exited(body: Node) -> void:
	if body.name == "HuChao":
		interaction_exited.emit()
