extends InteractableArea2D

@export var item_name: String = "剑"
@export var item_id: String = "merchant_road_sword"

func interact() -> void:
	print("已拾取道具：", item_name, " / ID: ", item_id)
	queue_free()
