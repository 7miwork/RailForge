extends GutTest
## Tests für RecipeDB (Unlock-Logik) und Crafting (Transaktion, Gründe).

var state: GameState
var inv: Inventory

func before_each() -> void:
	state = GameState.new()
	inv = state.inventory

func test_can_craft_plank_requires_wood() -> void:
	assert_false(Crafting.can_craft("plank", inv, state))
	inv.add_item("wood", 2, 99)
	assert_true(Crafting.can_craft("plank", inv, state))

func test_craft_plank_success() -> void:
	inv.add_item("wood", 2, 99)
	var result := Crafting.craft("plank", inv, state)
	assert_true(bool(result.get("ok")))
	assert_eq(str(result.get("output_item")), "plank")
	assert_eq(int(result.get("output_amount")), 1)
	assert_eq(inv.count_item("wood"), 0)
	assert_eq(inv.count_item("plank"), 1)

func test_craft_missing_inputs() -> void:
	inv.add_item("wood", 1, 99)
	var result := Crafting.craft("plank", inv, state)
	assert_false(bool(result.get("ok")))
	assert_eq(str(result.get("reason")), "missing")
	assert_eq(inv.count_item("wood"), 1) # unverändert

func test_craft_locked_recipe() -> void:
	inv.add_item("wood", 3, 99)
	inv.add_item("stone", 2, 99)
	var result := Crafting.craft("stone_pickaxe", inv, state)
	assert_false(bool(result.get("ok")))
	assert_eq(str(result.get("reason")), "locked")
	assert_eq(inv.count_item("wood"), 3) # unverändert

func test_craft_pickaxe_after_unlock() -> void:
	state.stats["wood_collected"] = 5
	inv.add_item("wood", 3, 99)
	inv.add_item("stone", 2, 99)
	var result := Crafting.craft("stone_pickaxe", inv, state)
	assert_true(bool(result.get("ok")))
	assert_eq(inv.count_item("wood"), 0)
	assert_eq(inv.count_item("stone"), 0)
	assert_eq(inv.count_item("stone_pickaxe"), 1)

func test_craft_unknown_recipe() -> void:
	var result := Crafting.craft("does_not_exist", inv, state)
	assert_false(bool(result.get("ok")))
	assert_eq(str(result.get("reason")), "unknown")

func test_craft_inventory_full_keeps_inputs() -> void:
	# 19 Slots Stein + 1 Slot Holz: plank-Input (2x wood) ist vorhanden,
	# aber plank-Output passt nicht (0 leere Slots, kein plank-Stack).
	for i in Inventory.MAX_SLOTS - 1:
		inv.slots[i] = {"item_id": "stone", "amount": 99}
	inv.slots[Inventory.MAX_SLOTS - 1] = {"item_id": "wood", "amount": 99}

	var result := Crafting.craft("plank", inv, state)
	assert_false(bool(result.get("ok")))
	assert_eq(str(result.get("reason")), "inventory_full")
	assert_eq(inv.count_item("wood"), 99) # wood NICHT abgebucht
	assert_eq(inv.count_item("plank"), 0)

func test_unlocked_recipes_counts() -> void:
	assert_eq(RecipeDB.unlocked_recipes(state).size(), 2) # plank, brick
	state.stats["wood_collected"] = 5
	assert_eq(RecipeDB.unlocked_recipes(state).size(), 3) # + stone_pickaxe
	state.stats["iron_ore_collected"] = 5
	assert_eq(RecipeDB.unlocked_recipes(state).size(), 4) # + iron_ingot

func test_is_unlocked_unknown_type() -> void:
	var fake := {"id": "x", "unlock": {"type": "mystery"}}
	assert_false(RecipeDB.is_unlocked(fake, state))
