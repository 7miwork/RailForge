extends GutTest
## Tests für RecipeDB: Lookup, Unlock-Logik (Stats-basiert), newly_unlocked.

func test_get_recipe() -> void:
	var plank := RecipeDB.get_recipe("plank")
	assert_false(plank.is_empty())
	assert_eq(str(plank.get("id")), "plank")
	assert_true(RecipeDB.get_recipe("unknown").is_empty())

func test_all_recipes_count() -> void:
	assert_eq(RecipeDB.all_recipes().size(), 4)

func test_is_recipe_unlocked_with_stats() -> void:
	var pickaxe := RecipeDB.get_recipe("stone_pickaxe")
	assert_false(RecipeDB.is_recipe_unlocked(pickaxe, {}))
	assert_true(RecipeDB.is_recipe_unlocked(pickaxe, {"wood_collected": 5}))
	assert_false(RecipeDB.is_recipe_unlocked(pickaxe, {"wood_collected": 4}))
	# start-Rezept ist immer frei
	var plank := RecipeDB.get_recipe("plank")
	assert_true(RecipeDB.is_recipe_unlocked(plank, {}))

func test_is_unlocked_delegates_to_stats() -> void:
	var state := GameState.new()
	state.stats["wood_collected"] = 5
	assert_true(RecipeDB.is_unlocked(RecipeDB.get_recipe("stone_pickaxe"), state))

func test_newly_unlocked() -> void:
	# wood 0→5: schaltet stone_pickaxe frei, nicht iron_ingot.
	var ids := RecipeDB.newly_unlocked({}, {"wood_collected": 5})
	assert_has(ids, "stone_pickaxe")
	assert_does_not_have(ids, "iron_ingot")
	assert_does_not_have(ids, "plank") # start-Rezept ignoriert

	# 4→5: Grenzfall, wird frei.
	ids = RecipeDB.newly_unlocked({"wood_collected": 4}, {"wood_collected": 5})
	assert_has(ids, "stone_pickaxe")

	# 5→5: schon frei → nichts Neues.
	ids = RecipeDB.newly_unlocked({"wood_collected": 5}, {"wood_collected": 5})
	assert_eq(ids.size(), 0)

	# leer→leer: nichts.
	ids = RecipeDB.newly_unlocked({}, {})
	assert_eq(ids.size(), 0)

	# iron_ore 0→5: iron_ingot.
	ids = RecipeDB.newly_unlocked({}, {"iron_ore_collected": 5})
	assert_has(ids, "iron_ingot")
	assert_does_not_have(ids, "stone_pickaxe")

func test_unlocked_recipes() -> void:
	var state := GameState.new()
	assert_eq(RecipeDB.unlocked_recipes(state).size(), 2)
	state.stats["wood_collected"] = 5
	assert_eq(RecipeDB.unlocked_recipes(state).size(), 3)
