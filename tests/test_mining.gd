extends GutTest
## Tests für ResourceNode.mine() und Mining (mine_node, find_nearest_node).

func test_mine_decrements_and_grants() -> void:
	var node := ResourceNode.new()
	node.item_id = "wood"
	node.amount = 3
	node.amount_per_hit = 1

	for i in 3:
		var result := node.mine()
		assert_eq(str(result.get("item_id")), "wood")
		assert_eq(int(result.get("amount")), 1)
		assert_eq(node.amount, 2 - i)
	assert_true(node.is_depleted())

	var empty := node.mine()
	assert_true(empty.is_empty())
	node.free()

func test_mine_node_fills_inventory() -> void:
	var node := ResourceNode.new()
	node.item_id = "wood"
	node.amount = 3
	node.amount_per_hit = 2
	var inv := Inventory.new()

	var result := Mining.mine_node(node, inv)
	assert_eq(str(result.get("item_id")), "wood")
	assert_eq(int(result.get("amount")), 2)
	assert_eq(int(result.get("leftover")), 0)
	assert_eq(inv.count_item("wood"), 2)
	assert_eq(node.amount, 1)
	node.free()

func test_mine_node_leftover_when_inventory_full() -> void:
	# Bewusste Entscheidung (siehe mining.gd): Abbau passiert auch bei vollem
	# Inventar, nicht passende Items verfallen (leftover > 0).
	var node := ResourceNode.new()
	node.item_id = "wood"
	node.amount = 5
	node.amount_per_hit = 1
	var inv := Inventory.new()
	inv.add_item("wood", Inventory.MAX_SLOTS * 99, 99) # Inventar komplett voll

	var result := Mining.mine_node(node, inv)
	assert_gt(int(result.get("leftover")), 0)
	assert_eq(node.amount, 4) # Knoten wurde trotzdem abgebaut
	assert_eq(inv.count_item("wood"), Inventory.MAX_SLOTS * 99)
	node.free()

func test_mine_node_depleted_returns_empty() -> void:
	var node := ResourceNode.new()
	node.amount = 0
	var result := Mining.mine_node(node, Inventory.new())
	assert_eq(int(result.get("amount")), 0)
	assert_eq(str(result.get("item_id")), "")
	node.free()

func test_mine_node_counts_stats() -> void:
	var node := ResourceNode.new()
	node.item_id = "wood"
	node.amount = 3
	node.amount_per_hit = 1
	var state := GameState.new()

	Mining.mine_node(node, state.inventory, state)
	Mining.mine_node(node, state.inventory, state)
	assert_eq(int(state.stats.get("wood_collected", 0)), 2)
	node.free()

func test_mine_node_returns_before_after_stats() -> void:
	var node := ResourceNode.new()
	node.item_id = "wood"
	node.amount = 2
	node.amount_per_hit = 1
	var state := GameState.new()

	var result := Mining.mine_node(node, state.inventory, state)
	var before: Dictionary = result.get("before_stats", {})
	var after: Dictionary = result.get("after_stats", {})
	assert_eq(int(before.get("wood_collected", 0)), 0)
	assert_eq(int(after.get("wood_collected", 0)), 1)
	# Deep-Duplicate: Änderungen an after_stats dürfen before_stats nicht beeinflussen.
	after["wood_collected"] = 999
	assert_eq(int(before.get("wood_collected", 0)), 0)
	node.free()

func test_mine_node_stats_even_with_leftover() -> void:
	# Abbau passiert physisch auch bei vollem Inventar → Stats zählen trotzdem.
	var node := ResourceNode.new()
	node.item_id = "iron_ore"
	node.amount = 5
	node.amount_per_hit = 1
	var state := GameState.new()
	state.inventory.add_item("iron_ore", Inventory.MAX_SLOTS * 99, 99)

	var result := Mining.mine_node(node, state.inventory, state)
	assert_gt(int(result.get("leftover")), 0)
	assert_eq(int(state.stats.get("iron_ore_collected", 0)), 1)
	node.free()

func test_find_nearest_node() -> void:
	var near := ResourceNode.new()
	near.position = Vector2(90, 0)
	var far := ResourceNode.new()
	far.position = Vector2(500, 0)
	var other_type := Area2D.new()

	var nodes: Array = [far, near, other_type]
	var best := Mining.find_nearest_node(nodes, Vector2(100, 0))
	assert_eq(best, near)

	near.free()
	far.free()
	other_type.free()
