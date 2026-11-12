extends GutTest
## Tests für ItemDB (Laden, Lookup, Fallbacks).

func test_load_items() -> void:
	ItemDB.load_items()
	var wood := ItemDB.get_item("wood")
	assert_false(wood.is_empty())
	assert_eq(str(wood.get("name")), "Holz")
	assert_true(wood.has("stack"))
	assert_true(wood.has("color"))

func test_get_item_unknown_returns_empty() -> void:
	assert_true(ItemDB.get_item("does_not_exist").is_empty())

func test_max_stack() -> void:
	assert_eq(ItemDB.max_stack("wood"), 99)
	assert_eq(ItemDB.max_stack("stone_pickaxe"), 1)
	assert_eq(ItemDB.max_stack("unknown"), 99) # Default

func test_display_name() -> void:
	assert_eq(ItemDB.display_name("wood"), "Holz")
	assert_eq(ItemDB.display_name("iron_ingot"), "Eisenbarren")
	assert_eq(ItemDB.display_name("unknown"), "unknown") # Fallback: ID

func test_color() -> void:
	assert_eq(ItemDB.color("wood"), Color("#8b4513"))
	assert_eq(ItemDB.color("unknown"), Color.WHITE) # Fallback
