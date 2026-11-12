class_name Mining
extends RefCounted
## Abbau-Logik. Verbindet ResourceNode (Welt) mit Inventory (Core).

## Baut einen Knoten ab und legt die Items ins Inventar.
## Gibt {"item_id", "amount", "leftover"} zurück.
## Hinweis: Der Abbau erfolgt auch dann, wenn das Inventar voll ist –
## die nicht passenden Items verfallen (leftover > 0). Bewusste Entscheidung
## für Etappe 1.2, Inventar-Management kommt mit Crafting (1.3).
static func mine_node(node: ResourceNode, inventory: Inventory) -> Dictionary:
	var result := node.mine()
	if result.is_empty():
		return {"item_id": "", "amount": 0, "leftover": 0}
	var item_id := str(result.get("item_id", ""))
	var amount := int(result.get("amount", 0))
	var leftover := inventory.add_item(item_id, amount, ItemDB.max_stack(item_id))
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
