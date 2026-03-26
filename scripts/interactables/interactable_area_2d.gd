extends Area2D
class_name InteractableArea2D

signal interaction_entered(interactable: InteractableArea2D)
signal interaction_exited(interactable: InteractableArea2D)

@export var prompt_text: String = "E"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.name == "HuChao":
		interaction_entered.emit(self)

func _on_body_exited(body: Node) -> void:
	if body.name == "HuChao":
		interaction_exited.emit(self)

func interact() -> void:
	pass
