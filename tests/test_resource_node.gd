extends GutTest
## Basis-Test für ResourceNode (Node-Verhalten; mine()-Logik in test_mining.gd).

func test_ready_builds_sprite_and_label() -> void:
	var node := ResourceNode.new()
	node.item_id = "wood"
	add_child(node) # triggert _ready
	assert_not_null(node.get_node_or_null("Sprite2D"))
	assert_not_null(node.get_node_or_null("AmountLabel"))
	assert_eq(node.collision_layer, 2)
	node.free()

func test_unknown_item_uses_ground_texture() -> void:
	var node := ResourceNode.new()
	node.item_id = "unknown_item"
	add_child(node)
	var sprite := node.get_node("Sprite2D") as Sprite2D
	assert_not_null(sprite.texture)
	node.free()
