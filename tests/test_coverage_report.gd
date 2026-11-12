extends GutTest
## Coverage-Report: Jede Core-Datei in src/core/ muss eine zugehörige
## Test-Datei tests/test_<name>.gd haben. Schlägt fehl, wenn eine
## Core-Datei ohne Test gefunden wird.

func test_every_core_file_has_test() -> void:
	var core_dir := DirAccess.open("res://src/core")
	assert_not_null(core_dir, "src/core nicht gefunden")
	if core_dir == null:
		return
	var missing: Array[String] = []
	for file_name in core_dir.get_files():
		if not file_name.ends_with(".gd"):
			continue
		var base := file_name.trim_suffix(".gd")
		var test_path := "res://tests/test_%s.gd" % base
		if not FileAccess.file_exists(test_path):
			missing.append(file_name)
	assert_eq(missing, [], "Core-Dateien ohne Test: %s" % str(missing))
