class_name Crafting
extends RefCounted
## Crafting-Logik. Transaktional: Oder alles (Inputs ab, Output rein),
## oder nichts (z. B. inventory_full → Inputs bleiben unangetastet).

## Kann das Rezept aktuell Crafted werden? (existiert, freigeschaltet, Inputs vorhanden)
static func can_craft(recipe_id: String, inventory: Inventory, game_state: GameState) -> bool:
	var recipe := RecipeDB.get_recipe(recipe_id)
	if recipe.is_empty():
		return false
	if not RecipeDB.is_unlocked(recipe, game_state):
		return false
	return _has_inputs(recipe, inventory)

## Führt den Craft-Vorgang aus.
## Rückgabe: {"ok": bool, "reason": "ok"|"unknown"|"locked"|"missing"|"inventory_full",
##            "output_item": String, "output_amount": int}
static func craft(recipe_id: String, inventory: Inventory, game_state: GameState) -> Dictionary:
	var recipe := RecipeDB.get_recipe(recipe_id)
	if recipe.is_empty():
		return _fail(recipe_id, "unknown")
	if not RecipeDB.is_unlocked(recipe, game_state):
		return _fail(recipe_id, "locked")
	if not _has_inputs(recipe, inventory):
		return _fail(recipe_id, "missing")

	var output: Dictionary = recipe.get("output", {})
	var output_item := str(output.get("item_id", ""))
	var output_amount := int(output.get("amount", 0))

	# Output-Platz prüfen, BEVOR Inputs abgebucht werden (Transaktion).
	if not _output_fits(output_item, output_amount, inventory):
		return _fail(recipe_id, "inventory_full", output_item, output_amount)

	for input_entry: Dictionary in recipe.get("inputs", []):
		inventory.remove_item(str(input_entry.get("item_id", "")), int(input_entry.get("amount", 0)))
	inventory.add_item(output_item, output_amount, ItemDB.max_stack(output_item))
	return {
		"ok": true,
		"reason": "ok",
		"output_item": output_item,
		"output_amount": output_amount,
	}

static func _fail(recipe_id: String, reason: String, output_item := "", output_amount := 0) -> Dictionary:
	var recipe := RecipeDB.get_recipe(recipe_id)
	var output: Dictionary = recipe.get("output", {}) if not recipe.is_empty() else {}
	return {
		"ok": false,
		"reason": reason,
		"output_item": output_item if not output_item.is_empty() else str(output.get("item_id", "")),
		"output_amount": output_amount if output_amount > 0 else int(output.get("amount", 0)),
	}

static func _has_inputs(recipe: Dictionary, inventory: Inventory) -> bool:
	for input_entry: Dictionary in recipe.get("inputs", []):
		if not inventory.has_item(str(input_entry.get("item_id", "")), int(input_entry.get("amount", 0))):
			return false
	return true

## Reicht freier Platz für `amount` des Items? (Stacks auffüllbar + leere Slots)
static func _output_fits(item_id: String, amount: int, inventory: Inventory) -> bool:
	var max_stack := ItemDB.max_stack(item_id)
	var capacity := 0
	for slot: Dictionary in inventory.slots:
		if slot.is_empty():
			capacity += max_stack
		elif str(slot.get("item_id", "")) == item_id:
			capacity += max_stack - int(slot.get("amount", 0))
	return amount <= capacity
