extends GutTest
## Tests für SaveManager (speichern, laden, Versionierung, Fehlerfälle).
## user:// wird in den Tests beschrieben und in after_each aufgeräumt.

func after_each() -> void:
	SaveManager.delete()

func _write_raw(content: String) -> void:
	var file := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
	file.store_string(content)
	file.close()

func test_save_creates_file() -> void:
	var state := GameState.new()
	assert_true(SaveManager.save(state))
	assert_true(SaveManager.exists())

func test_roundtrip_preserves_state() -> void:
	var state := GameState.new()
	state.inventory.add_item("wood", 15, 99)
	state.stats["wood_collected"] = 20
	state.era = 3
	state.tick = 42
	state.phase = 1

	assert_true(SaveManager.save(state))
	var loaded := SaveManager.load_state()
	assert_eq(loaded.to_dict(), state.to_dict())

func test_load_without_file_returns_new_state() -> void:
	assert_false(SaveManager.exists())
	var loaded := SaveManager.load_state()
	assert_eq(loaded.era, 1)
	assert_eq(loaded.inventory.count_item("wood"), 0)

func test_load_corrupt_json_returns_new_state() -> void:
	_write_raw("das ist kein json {{{")
	var loaded := SaveManager.load_state()
	assert_eq(loaded.era, 1)
	assert_eq(loaded.inventory.count_item("wood"), 0)

func test_load_too_new_version_returns_new_state() -> void:
	_write_raw(JSON.stringify({"version": 999, "state": {"era": 5}}))
	var loaded := SaveManager.load_state()
	assert_eq(loaded.era, 1) # nicht 5 → Default

func test_load_missing_state_field_returns_new_state() -> void:
	_write_raw(JSON.stringify({"version": 1}))
	var loaded := SaveManager.load_state()
	assert_eq(loaded.era, 1)

func test_delete() -> void:
	SaveManager.save(GameState.new())
	assert_true(SaveManager.exists())
	assert_true(SaveManager.delete())
	assert_false(SaveManager.exists())

func test_last_saved_at() -> void:
	assert_eq(SaveManager.last_saved_at(), 0)
	SaveManager.save(GameState.new())
	assert_gt(SaveManager.last_saved_at(), 0)
