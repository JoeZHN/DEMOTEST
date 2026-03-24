extends Node2D

@onready var player_spawn: Marker2D = $Markers/PlayerSpawn
@onready var hu_chao: CharacterBody2D = $Characters/HuChao
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	await get_tree().process_frame

	hu_chao.position = player_spawn.position

	camera.reparent(hu_chao)
	camera.position = Vector2.ZERO
	camera.make_current()

	print("PlayerSpawn position = ", player_spawn.position)
	print("HuChao position = ", hu_chao.position)
