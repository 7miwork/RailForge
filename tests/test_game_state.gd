extends GutTest
## Tests für GameState.to_dict/from_dict (Feld-Vollständigkeit, Defaults).

func test_to_dict_contains_all_fields() -> void:
	var s := GameState.new()
	var d := s.to_dict()
	for key in ["version", "era", "tick", "features", "phase", "stage", "stage_name", "stats", "inventory"]:
		assert_true(d.has(key), "to_dict fehlt Feld: %s" % key)

func test_from_dict_empty_gives_defaults() -> void:
	var s := GameState.from_dict({})
	assert_eq(s.era, 1)
	assert_eq(s.phase, 1)
	assert_eq(s.stage, "1.1")
	assert_eq(s.inventory.count_item("wood"), 0)
	assert_eq(int(s.stats.get("wood_collected", -1)), -1) # stats bleibt leer

func test_from_dict_missing_inventory_gives_empty() -> void:
	var s := GameState.from_dict({"era": 2, "tick": 9})
	assert_eq(s.era, 2)
	assert_eq(s.tick, 9)
	assert_eq(s.inventory.slots.size(), Inventory.MAX_SLOTS)
	assert_eq(s.inventory.count_item("wood"), 0)

func test_stats_roundtrip() -> void:
	var s := GameState.new()
	s.add_stat("wood_collected", 5)
	s.add_stat("wood_collected", 3)
	s.add_stat("iron_ore_collected", 2)
	var restored := GameState.from_dict(s.to_dict())
	assert_eq(int(restored.stats.get("wood_collected", 0)), 8)
	assert_eq(int(restored.stats.get("iron_ore_collected", 0)), 2)
