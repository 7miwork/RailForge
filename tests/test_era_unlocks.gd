extends GutTest
## Tests für EraUnlocks: Erfüllung, Pending, Markieren, Save-Persistenz.

var state: GameState

func before_each() -> void:
	state = GameState.new()

func test_era1_always_unlocked() -> void:
	assert_true(EraUnlocks.unlocked_eras(state).has(1))
	assert_false(EraUnlocks.unlocked_eras(state).has(2))

func test_era2_locked_initially() -> void:
	assert_false(EraUnlocks.is_satisfied(2, state))
	assert_eq(EraUnlocks.pending_unlocks(state), [])

func test_era2_unlock_after_5_iron_ingots() -> void:
	state.stats["crafted_iron_ingot"] = 4
	assert_false(EraUnlocks.is_satisfied(2, state))
	state.stats["crafted_iron_ingot"] = 5
	assert_true(EraUnlocks.is_satisfied(2, state))
	assert_eq(EraUnlocks.pending_unlocks(state), [2])

func test_pending_unlocks_excludes_marked() -> void:
	state.stats["crafted_iron_ingot"] = 10
	EraUnlocks.mark_unlocked(state, 2)
	assert_eq(EraUnlocks.pending_unlocks(state), [])
	assert_true(EraUnlocks.unlocked_eras(state).has(2))

func test_mark_unlocked_idempotent() -> void:
	EraUnlocks.mark_unlocked(state, 2)
	EraUnlocks.mark_unlocked(state, 2)
	var stored: Array = state.features.get("unlocked_eras", [])
	assert_eq(stored.count(2), 1)

func test_unlocks_survive_save_roundtrip() -> void:
	state.stats["crafted_iron_ingot"] = 5
	EraUnlocks.mark_unlocked(state, 2)
	var loaded := GameState.from_dict(state.to_dict())
	assert_true(EraUnlocks.unlocked_eras(loaded).has(2))
	assert_false(EraUnlocks.pending_unlocks(loaded).has(2))

func test_crafted_stat_via_crafting() -> void:
	# Eisenbarren-Rezept: 2x Erz + 1x Holz → crafted_iron_ingot-Stat.
	state.stats["iron_ore_collected"] = 5 # Rezept freischalten
	state.inventory.add_item("iron_ore", 2, 99)
	state.inventory.add_item("wood", 1, 99)
	var result := Crafting.craft("iron_ingot", state.inventory, state)
	assert_true(bool(result.get("ok")))
	assert_eq(int(state.stats.get("crafted_iron_ingot", 0)), 1)
