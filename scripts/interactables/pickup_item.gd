extends Area2D

@export var prompt_text: String = "按 E 拾取"
@export var item_name: String = "剑"

var can_interact: bool = false
var player_in_range: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if can_interact and Input.is_action_just_pressed("interact"):
		print("已拾取道具：", item_name)
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.name == "HuChao":
		can_interact = true
		player_in_range = body
		var merchant_road = get_tree().current_scene
		var prompt = merchant_road.get_node("UI/InteractionPrompt")
		prompt.show_prompt(prompt_text)

func _on_body_exited(body: Node) -> void:
	if body.name == "HuChao":
		can_interact = false
		player_in_range = null
		var merchant_road = get_tree().current_scene
		var prompt = merchant_road.get_node("UI/InteractionPrompt")
		prompt.hide_prompt()
