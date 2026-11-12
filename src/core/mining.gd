class_name Mining
extends RefCounted
## Abbau-Logik. Verbindet ResourceNode (Welt) mit Inventory und GameState (Core).

## Baut einen Knoten ab, legt die Items ins Inventar und zählt die
## Abbau-Statistik (z. B. "wood_collected") hoch – auch dann, wenn das
## Inventar voll ist und Items verfallen (siehe Hinweis unten).
## Gibt {"item_id", "amount", "leftover"} zurück.
static func mine_node(node: ResourceNode, inventory: Inventory, game_state: GameState = null) -> Dictionary:
	var result := node.mine()
	if result.is_empty():
		return {"item_id": "", "amount": 0, "leftover": 0}
	var item_id := str(result.get("item_id", ""))
	var amount := int(result.get("amount", 0))
	var leftover := inventory.add_item(item_id, amount, ItemDB.max_stack(item_id))
	if game_state != null:
		game_state.add_stat(item_id + "_collected", amount)
	return {"item_id": item_id, "amount": amount, "leftover": leftover}

## Nächsten ResourceNode aus einer Liste ab Position `from` finden.
static func find_nearest_node(nodes: Array, from: Vector2) -> ResourceNode:
	var best: ResourceNode = null
	var best_dist := INF
	for n in nodes:
		if n is ResourceNode:
			var dist := from.distance_to(n.global_position)
			if dist < best_dist:
				best_dist = dist
				best = n
	return best
