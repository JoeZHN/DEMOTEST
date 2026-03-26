extends Node2D

@onready var player_spawn: Marker2D = $Markers/PlayerSpawn
@onready var li_qian_spawn: Marker2D = $Markers/LiQianSpawn
@onready var hu_chao: CharacterBody2D = $Characters/HuChao
@onready var li_qian: InteractableArea2D = $Characters/LiQian
@onready var sword_pickup: InteractableArea2D = $Items/SwordPickup
@onready var camera: Camera2D = $Camera2D
@onready var interaction_prompt: Label = $UI/InteractionPrompt


var dialogue_box: DialogueBox
var is_dialogue_running: bool = false
var current_interactable: InteractableArea2D = null
var current_dialogue_path: String = ""


func _ready() -> void:
	await get_tree().process_frame

	hu_chao.global_position = player_spawn.global_position
	li_qian.global_position = li_qian_spawn.global_position

	camera.reparent(hu_chao)
	camera.position = Vector2.ZERO
	camera.make_current()

	interaction_prompt.hide_prompt()

	li_qian.interaction_entered.connect(_on_interactable_entered)
	li_qian.interaction_exited.connect(_on_interactable_exited)
	sword_pickup.interaction_entered.connect(_on_interactable_entered)
	sword_pickup.interaction_exited.connect(_on_interactable_exited)

	dialogue_box = preload("res://scenes/ui/dialogue_box.tscn").instantiate()
	add_child(dialogue_box)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

func _unhandled_input(event: InputEvent) -> void:
	if is_dialogue_running:
		return

	if event.is_action_pressed("interact") and current_interactable != null:
		_handle_interaction(current_interactable)
		get_viewport().set_input_as_handled()

func _on_interactable_entered(interactable: InteractableArea2D) -> void:
	if is_dialogue_running:
		return

	current_interactable = interactable
	interaction_prompt.show_prompt(interactable.prompt_text)

func _on_interactable_exited(interactable: InteractableArea2D) -> void:
	if current_interactable == interactable:
		current_interactable = null
		interaction_prompt.hide_prompt()

func _handle_interaction(interactable: InteractableArea2D) -> void:
	if interactable == li_qian:
		_start_li_qian_dialogue()
	else:
		interactable.interact()
		_after_interaction(interactable)

func _after_interaction(interactable: InteractableArea2D) -> void:
	if current_interactable == interactable:
		current_interactable = null
		interaction_prompt.hide_prompt()

func _start_li_qian_dialogue() -> void:
	is_dialogue_running = true
	interaction_prompt.hide_prompt()
	hu_chao.can_move = false

	current_dialogue_path = _get_li_qian_dialogue_path()
	var lines := DialogueManager.load_dialogue(current_dialogue_path)
	dialogue_box.start_dialogue(lines)
	
func _get_li_qian_dialogue_path() -> String:
	if GameState.merchant_road_stage == 0:
		GameState.merchant_road_stage = 1
		return "res://data/dialogues/chapter1/li_qian_intro.json"

	if GameState.merchant_road_stage == 1:
		return "res://data/dialogues/chapter1/li_qian_intro.json"

	if GameState.merchant_road_stage == 2:
		return "res://data/dialogues/chapter1/li_qian_after_sword.json"

	return "res://data/dialogues/chapter1/li_qian_after_sword.json"
	GameState.merchant_road_stage = 1
	print("merchant_road_stage = ", GameState.merchant_road_stage)
	print("inventory = ", GameState.inventory)

func _on_dialogue_finished() -> void:
	is_dialogue_running = false
	hu_chao.can_move = true

	if current_interactable != null:
		interaction_prompt.show_prompt(current_interactable.prompt_text)
	if current_dialogue_path == "res://data/dialogues/chapter1/li_qian_after_sword.json":
		if GameState.merchant_road_stage < 3:
			GameState.merchant_road_stage = 3
			
	GameState.merchant_road_stage = 3
	print("merchant_road_stage = ", GameState.merchant_road_stage)
	print("inventory = ", GameState.inventory)
