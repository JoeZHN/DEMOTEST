extends InteractableArea2D

@export var item_name: String = "剑"
@export var item_id: String = "merchant_road_sword"

func interact() -> void:
	if GameState.has_item(item_id):
		return

	GameState.add_item(item_id)
	print("已拾取道具：", item_name, " / ID: ", item_id)

	if item_id == "merchant_road_sword" and GameState.merchant_road_stage < 2:
		GameState.merchant_road_stage = 2

	queue_free()
	
