class_name Progress
extends RefCounted
## Lädt data/progress.json und verwaltet den Etappen-Fortschritt (statische API).
## Reine Daten-Logik, kein Rendering. Runtime-Mutationen (z. B. per Debug-Overlay)
## bleiben im Speicher; data/progress.json wird niemals beschrieben
## (const-Daten, im Export read-only).

static var data_path := "res://data/progress.json"
static var _data: Dictionary = {}
static var _loaded := false

static func _ensure_loaded() -> void:
	if not _loaded:
		_reload_for_test()

## Lädt den internen Cache neu (Test-Hilfe, keine Produktions-API).
static func _reload_for_test() -> void:
	_loaded = true
	var loaded: Variant = DataLoader.load_json(data_path)
	_data = loaded if loaded is Dictionary else {"phase": 1, "phase_name": "", "stages": []}

static func all_stages() -> Array:
	_ensure_loaded()
	return _data.get("stages", [])

static func total_count() -> int:
	return all_stages().size()

static func done_count() -> int:
	var n := 0
	for s: Dictionary in all_stages():
		if bool(s.get("done", false)):
			n += 1
	return n

static func progress_ratio() -> float:
	var total := total_count()
	return float(done_count()) / float(total) if total > 0 else 0.0

## Erste nicht erledigte Etappe als Dictionary {"id", "name", "done"}.
static func current_stage() -> Dictionary:
	for s: Dictionary in all_stages():
		if not bool(s.get("done", false)):
			return s
	return {}

## ID der aktuellen Etappe, z. B. "1.5".
static func current_stage_id() -> String:
	return str(current_stage().get("id", ""))

## Name der aktuellen Etappe.
static func current_stage_name() -> String:
	return str(current_stage().get("name", ""))

## 1-basierter Index der aktuellen Etappe (total_count + 1 wenn alle done).
static func current_index() -> int:
	var stages := all_stages()
	for i in stages.size():
		var s: Dictionary = stages[i]
		if not bool(s.get("done", false)):
			return i + 1
	return stages.size() + 1

static func stage_by_id(stage_id: String) -> Dictionary:
	for s: Dictionary in all_stages():
		if str(s.get("id", "")) == stage_id:
			return s
	return {}

static func is_done(stage_id: String) -> bool:
	return bool(stage_by_id(stage_id).get("done", false))

## Markiert eine Etappe als erledigt (Runtime-State, nicht persistiert).
static func mark_done(stage_id: String) -> void:
	var s := stage_by_id(stage_id)
	if not s.is_empty():
		s["done"] = true

## Dev/Debug: setzt alle Etappen im Runtime-State auf nicht erledigt.
static func reset_progress() -> void:
	_ensure_loaded()
	for s: Dictionary in all_stages():
		s["done"] = false
