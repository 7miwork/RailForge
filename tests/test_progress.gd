extends GutTest
## Tests für Progress (statische API: Zähler, Index, Lookup, Reset, Defensiv).

func before_each() -> void:
	Progress._reload_for_test()

func after_each() -> void:
	Progress._reload_for_test()

func test_counts() -> void:
	# data/progress.json: 1.1–1.4 done, 1.5 aktuell, 1.6 offen.
	assert_eq(Progress.total_count(), 6)
	assert_eq(Progress.done_count(), 4)
	assert_almost_eq(Progress.progress_ratio(), 4.0 / 6.0, 0.001)

func test_current_stage() -> void:
	assert_eq(Progress.current_stage_id(), "1.5")
	assert_eq(Progress.current_stage_name(), "Fortschrittsanzeige & GUT-Tests")
	var stage := Progress.current_stage()
	assert_eq(str(stage.get("id")), "1.5")
	assert_false(bool(stage.get("done")))

func test_current_index() -> void:
	assert_eq(Progress.current_index(), 5)

func test_stage_by_id() -> void:
	assert_eq(str(Progress.stage_by_id("1.3").get("name")), "Handcrafting")
	assert_true(Progress.stage_by_id("99.99").is_empty())

func test_is_done() -> void:
	assert_true(Progress.is_done("1.1"))
	assert_true(Progress.is_done("1.4"))
	assert_false(Progress.is_done("1.6"))

func test_mark_done_advances() -> void:
	Progress.mark_done("1.5")
	assert_eq(Progress.current_stage_id(), "1.6")
	assert_eq(Progress.current_stage_name(), "Game-Boy-Look & Polish")

func test_all_done_state() -> void:
	for stage: Dictionary in Progress.all_stages():
		stage["done"] = true
	assert_eq(Progress.current_stage_id(), "")
	assert_eq(Progress.current_index(), 7) # total_count + 1
	assert_almost_eq(Progress.progress_ratio(), 1.0, 0.001)

func test_reset_progress() -> void:
	Progress.reset_progress()
	assert_eq(Progress.done_count(), 0)
	assert_eq(Progress.current_stage_id(), "1.1")
	assert_almost_eq(Progress.progress_ratio(), 0.0, 0.001)
	assert_false(Progress.is_done("1.1"))

func test_defensive_empty_progress_file() -> void:
	# Leere progress.json in user:// → Defaults, kein Crash.
	var old_path := Progress.data_path
	Progress.data_path = "user://progress_test_empty.json"
	var file := FileAccess.open(Progress.data_path, FileAccess.WRITE)
	file.store_string("{}")
	file.close()

	Progress._reload_for_test()
	assert_eq(Progress.total_count(), 0)
	assert_eq(Progress.done_count(), 0)
	assert_eq(Progress.progress_ratio(), 0.0)
	assert_eq(Progress.current_stage_id(), "")
	assert_eq(Progress.current_index(), 1)

	# Aufräumen + Original wiederherstellen.
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progress.data_path))
	Progress.data_path = old_path
	Progress._reload_for_test()
