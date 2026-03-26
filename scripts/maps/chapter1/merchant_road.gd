extends Node2D

@onready var player_spawn: Marker2D = $Markers/PlayerSpawn
@onready var li_qian_spawn: Marker2D = $Markers/LiQianSpawn
@onready var hu_chao: CharacterBody2D = $Characters/HuChao
@onready var li_qian: Area2D = $Characters/LiQian
@onready var camera: Camera2D = $Camera2D
@onready var interaction_prompt: Label = $UI/InteractionPrompt

var dialogue_box: DialogueBox
var can_interact_with_li_qian: bool = false
var is_dialogue_running: bool = false

func _ready() -> void:
	await get_tree().process_frame

	hu_chao.global_position = player_spawn.global_position
	li_qian.global_position = li_qian_spawn.global_position

	camera.reparent(hu_chao)
	camera.position = Vector2.ZERO
	camera.make_current()

	interaction_prompt.visible = false
	interaction_prompt.text = "E"

	li_qian.interaction_entered.connect(_on_li_qian_interaction_entered)
	li_qian.interaction_exited.connect(_on_li_qian_interaction_exited)

	dialogue_box = preload("res://scenes/ui/dialogue_box.tscn").instantiate()
	add_child(dialogue_box)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

	print("PlayerSpawn global_position = ", player_spawn.global_position)
	print("HuChao global_position = ", hu_chao.global_position)
	print("LiQianSpawn global_position = ", li_qian_spawn.global_position)
	print("LiQian global_position = ", li_qian.global_position)

func _unhandled_input(event: InputEvent) -> void:
	if is_dialogue_running:
		return

	if event.is_action_pressed("interact") and can_interact_with_li_qian:
		_start_li_qian_dialogue()
		get_viewport().set_input_as_handled()

func _on_li_qian_interaction_entered() -> void:
	if is_dialogue_running:
		return

	can_interact_with_li_qian = true
	interaction_prompt.visible = true

func _on_li_qian_interaction_exited() -> void:
	can_interact_with_li_qian = false
	interaction_prompt.visible = false

func _start_li_qian_dialogue() -> void:
	is_dialogue_running = true
	interaction_prompt.visible = false

	var lines := DialogueManager.load_dialogue("res://data/dialogues/chapter1/li_qian_intro.json")
	dialogue_box.start_dialogue(lines)

	hu_chao.can_move = false

func _on_dialogue_finished() -> void:
	is_dialogue_running = false
	hu_chao.can_move = true

	if can_interact_with_li_qian:
		interaction_prompt.visible = true
