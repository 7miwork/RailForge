extends GutTest
## Tests für Progress (statische API, Multi-Phase).
## data/progress.json: Phase 1 komplett done, Phase 2 aktiv mit 2.1 offen.

func before_each() -> void:
	Progress._reload_for_test()

func after_each() -> void:
	Progress._reload_for_test()

func test_active_phase_is_phase_2() -> void:
	assert_eq(Progress.phase_number(), 2)
	assert_eq(Progress.phase_name(), "8-Bit-Farbe (NES)")

func test_counts() -> void:
	# Aktive Phase 2: 6 Etappen, 0 done.
	assert_eq(Progress.total_count(), 6)
	assert_eq(Progress.done_count(), 0)
	assert_almost_eq(Progress.progress_ratio(), 0.0, 0.001)

func test_current_stage() -> void:
	assert_eq(Progress.current_stage_id(), "2.1")
	assert_eq(Progress.current_stage_name(), "Ära-Wechsel und NES-Renderer")
	var stage := Progress.current_stage()
	assert_eq(str(stage.get("id")), "2.1")
	assert_false(bool(stage.get("done")))

func test_current_index() -> void:
	assert_eq(Progress.current_index(), 1)

func test_phase_1_stages_are_done() -> void:
	# Phase 1 ist abgeschlossen (alle 6 Etappen done).
	assert_true(Progress.is_done("1.1"))
	assert_true(Progress.is_done("1.6"))
	var phase1_done := true
	for entry: Dictionary in Progress.all_stage_entries():
		if int(entry.get("phase", 0)) == 1 and not bool(entry.get("done", false)):
			phase1_done = false
	assert_true(phase1_done)

func test_stage_by_id() -> void:
	assert_eq(str(Progress.stage_by_id("1.3").get("name")), "Handcrafting")
	assert_eq(str(Progress.stage_by_id("2.4").get("name")), "Förderbänder")
	assert_true(Progress.stage_by_id("99.99").is_empty())

func test_is_done() -> void:
	assert_true(Progress.is_done("1.5"))
	assert_false(Progress.is_done("2.1"))
	assert_false(Progress.is_done("2.6"))

func test_mark_done_advances_within_phase() -> void:
	Progress.mark_done("2.1")
	assert_eq(Progress.current_stage_id(), "2.2")
	assert_eq(Progress.current_index(), 2)
	# Phase bleibt 2.
	assert_eq(Progress.phase_number(), 2)

func test_all_phases_done_state() -> void:
	# all_stage_entries() liefert Duplikate – mark_done schreibt in die echten Dicts.
	for entry: Dictionary in Progress.all_stage_entries():
		Progress.mark_done(str(entry.get("id", "")))
	assert_true(Progress.all_done())
	assert_eq(Progress.current_stage_id(), "")
	assert_eq(Progress.current_index(), 7) # total_count + 1
	assert_almost_eq(Progress.progress_ratio(), 1.0, 0.001)

func test_reset_progress_returns_to_phase_1() -> void:
	Progress.reset_progress()
	assert_eq(Progress.done_count(), 0)
	# Erste Phase mit offenen Etappen ist wieder Phase 1.
	assert_eq(Progress.phase_number(), 1)
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
	assert_eq(Progress.phase_number(), 0)
	assert_false(Progress.all_done())

	# Aufräumen + Original wiederherstellen.
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Progress.data_path))
	Progress.data_path = old_path
	Progress._reload_for_test()
