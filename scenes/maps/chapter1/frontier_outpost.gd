extends Node2D

@onready var player_spawn: Marker2D = $Markers/PlayerSpawn
@onready var scout_spawn: Marker2D = $Markers/ScoutSpawn
@onready var battle_trigger_spawn: Marker2D = $Markers/BattleTriggerSpawn

@onready var hu_chao: CharacterBody2D = $Characters/HuChao
@onready var frontier_scout: InteractableArea2D = $Characters/FrontierScout
@onready var battle_trigger_point: InteractableArea2D = $Interactables/BattleTriggerPoint

@onready var camera: Camera2D = $Camera2D
@onready var interaction_prompt: Label = $UI/InteractionPrompt

var dialogue_box: DialogueBox
var is_dialogue_running: bool = false
var current_interactable: InteractableArea2D = null
var current_dialogue_path: String = ""

func _ready() -> void:
	await get_tree().process_frame

	hu_chao.global_position = player_spawn.global_position
	frontier_scout.global_position = scout_spawn.global_position
	battle_trigger_point.global_position = battle_trigger_spawn.global_position

	camera.reparent(hu_chao)
	camera.position = Vector2.ZERO
	camera.make_current()

	interaction_prompt.visible = false

	if not GameState.has("frontier_outpost_stage"):
		GameState.frontier_outpost_stage = 0




	frontier_scout.interaction_entered.connect(_on_interactable_entered)
	frontier_scout.interaction_exited.connect(_on_interactable_exited)
	battle_trigger_point.interaction_entered.connect(_on_interactable_entered)
	battle_trigger_point.interaction_exited.connect(_on_interactable_exited)

	dialogue_box = preload("res://scenes/ui/dialogue_box.tscn").instantiate()
	add_child(dialogue_box)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

func _unhandled_input(event: InputEvent) -> void:
	if is_dialogue_running:
		return

	if event.is_action_pressed("interact") and current_interactable != null:
		get_viewport().set_input_as_handled()
		_handle_interaction(current_interactable)

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
	if interactable == frontier_scout:
		_start_scout_dialogue()
	else:
		interactable.interact()
		_after_interaction(interactable)

func _after_interaction(interactable: InteractableArea2D) -> void:
	if current_interactable == interactable:
		current_interactable = null
		interaction_prompt.hide_prompt()

func _start_scout_dialogue() -> void:
	is_dialogue_running = true
	interaction_prompt.hide_prompt()
	hu_chao.can_move = false

	current_dialogue_path = "res://data/dialogues/chapter1/frontier_scout_intro.json"
	var lines := DialogueManager.load_dialogue(current_dialogue_path)
	dialogue_box.start_dialogue(lines)

func _on_dialogue_finished() -> void:
	is_dialogue_running = false
	hu_chao.can_move = true

	if current_interactable != null:
		interaction_prompt.show_prompt(current_interactable.prompt_text)

	if current_dialogue_path == "res://data/dialogues/chapter1/frontier_scout_intro.json":
		if GameState.frontier_outpost_stage < 1:
			GameState.frontier_outpost_stage = 1
