extends GutTest
## Tests für Inventory (Slots, Stacks, Remove, Save-Round-Trip).

var inv: Inventory

func before_each() -> void:
	inv = Inventory.new()

func test_empty_inventory() -> void:
	assert_eq(inv.count_item("wood"), 0)
	assert_false(inv.has_item("wood", 1))
	assert_eq(inv.slots.size(), Inventory.MAX_SLOTS)

func test_add_item_basic() -> void:
	var leftover := inv.add_item("wood", 5, 99)
	assert_eq(leftover, 0)
	assert_eq(inv.count_item("wood"), 5)
	assert_eq(inv.slots[0].get("item_id"), "wood")
	assert_eq(int(inv.slots[0].get("amount")), 5)

func test_add_item_stacks_across_slots() -> void:
	var leftover := inv.add_item("wood", 200, 99)
	assert_eq(leftover, 0)
	assert_eq(int(inv.slots[0].get("amount")), 99)
	assert_eq(int(inv.slots[1].get("amount")), 99)
	assert_eq(int(inv.slots[2].get("amount")), 2)
	assert_eq(inv.count_item("wood"), 200)

func test_add_item_leftover_when_full() -> void:
	# Kapazität: 20 Slots * 99 = 1980
	var leftover := inv.add_item("wood", 2000, 99)
	assert_eq(leftover, 20)
	assert_eq(inv.count_item("wood"), 1980)

func test_remove_item() -> void:
	inv.add_item("wood", 200, 99)
	var removed := inv.remove_item("wood", 3)
	assert_eq(removed, 3)
	assert_eq(inv.count_item("wood"), 197)

func test_remove_item_more_than_available() -> void:
	inv.add_item("wood", 200, 99)
	var removed := inv.remove_item("wood", 999)
	assert_eq(removed, 200)
	assert_eq(inv.count_item("wood"), 0)
	for slot: Dictionary in inv.slots:
		assert_true(slot.is_empty())

func test_has_item() -> void:
	inv.add_item("wood", 10, 99)
	assert_true(inv.has_item("wood", 10))
	assert_true(inv.has_item("wood", 5))
	assert_false(inv.has_item("wood", 11))

func test_to_from_dict_roundtrip() -> void:
	inv.add_item("wood", 50, 99)
	inv.add_item("stone", 7, 99)
	var restored := Inventory.from_dict(inv.to_dict())
	assert_eq(restored.count_item("wood"), 50)
	assert_eq(restored.count_item("stone"), 7)
	assert_eq(restored.slots.size(), Inventory.MAX_SLOTS)
	assert_eq(int(restored.slots[0].get("amount")), 50)
	assert_eq(str(restored.slots[1].get("item_id")), "stone")
