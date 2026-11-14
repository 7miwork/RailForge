class_name Progress
extends RefCounted
## Lädt data/progress.json und verwaltet den Etappen-Fortschritt (statische API).
## Unterstützt mehrere Phasen: data/progress.json enthält "phases" mit
## je einem Eintrag pro Phase (phase, phase_name, stages[]).
## Die „aktive" Phase ist die erste Phase mit mindestens einer offenen Etappe
## (falls alle done: die letzte Phase). Zähler/Index-Funktionen beziehen sich
## auf die aktive Phase; stage_by_id/is_done/mark_done suchen alle Phasen.
## Runtime-Mutationen bleiben im Speicher; data/progress.json wird niemals
## beschrieben (const-Daten, im Export read-only).

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
	_data = loaded if loaded is Dictionary else {}

## Alle Phasen als Array. Akzeptiert das Multi-Phase-Format ("phases")
## und das Legacy-Single-Phase-Format ("phase"/"stages" auf Root).
static func _phases() -> Array:
	var phases: Variant = _data.get("phases", [])
	if phases is Array and not phases.is_empty():
		return phases
	var stages: Variant = _data.get("stages", [])
	if stages is Array and not stages.is_empty():
		return [{
			"phase": int(_data.get("phase", 1)),
			"phase_name": str(_data.get("phase_name", "")),
			"stages": stages,
		}]
	return []

## Index der aktiven Phase in _phases() (-1 wenn keine Phasen).
static func _active_phase_index() -> int:
	var phases := _phases()
	for i in phases.size():
		for s: Dictionary in phases[i].get("stages", []):
			if not bool(s.get("done", false)):
				return i
	return phases.size() - 1 if not phases.is_empty() else -1

static func _active_phase() -> Dictionary:
	var idx := _active_phase_index()
	var phases := _phases()
	return phases[idx] if idx >= 0 else {}

## Nummer der aktiven Phase (z. B. 2), 0 wenn keine Phasen.
static func phase_number() -> int:
	_ensure_loaded()
	return int(_active_phase().get("phase", 0))

## Name der aktiven Phase.
static func phase_name() -> String:
	_ensure_loaded()
	return str(_active_phase().get("phase_name", ""))

## true, wenn alle Etappen aller Phasen erledigt sind.
static func all_done() -> bool:
	_ensure_loaded()
	for phase: Dictionary in _phases():
		for s: Dictionary in phase.get("stages", []):
			if not bool(s.get("done", false)):
				return false
	return not _phases().is_empty()

static func all_stages() -> Array:
	_ensure_loaded()
	return _active_phase().get("stages", [])

## Flache Liste aller Etappen aller Phasen (für Debug-Overlay).
## Jeder Eintrag: {"id", "name", "done", "phase"}.
static func all_stage_entries() -> Array:
	_ensure_loaded()
	var result: Array = []
	for phase: Dictionary in _phases():
		var phase_num := int(phase.get("phase", 0))
		for s: Dictionary in phase.get("stages", []):
			var entry := s.duplicate()
			entry["phase"] = phase_num
			result.append(entry)
	return result

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

## Erste nicht erledigte Etappe der aktiven Phase als Dictionary.
static func current_stage() -> Dictionary:
	for s: Dictionary in all_stages():
		if not bool(s.get("done", false)):
			return s
	return {}

## ID der aktuellen Etappe, z. B. "2.1".
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

## Sucht eine Etappe über ALLE Phasen (für Debug/Markierungen).
static func stage_by_id(stage_id: String) -> Dictionary:
	_ensure_loaded()
	for phase: Dictionary in _phases():
		for s: Dictionary in phase.get("stages", []):
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

## Dev/Debug: setzt alle Etappen aller Phasen im Runtime-State auf nicht erledigt.
static func reset_progress() -> void:
	_ensure_loaded()
	for phase: Dictionary in _phases():
		for s: Dictionary in phase.get("stages", []):
			s["done"] = false
