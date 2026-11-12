class_name Progress
extends RefCounted
## Lädt data/progress.json und verwaltet den Etappen-Fortschritt der aktuellen Phase.
## Reiner Daten-Holder (RefCounted), kein Rendering.

var data: Dictionary = {}

func _init() -> void:
	var loaded: Variant = DataLoader.load_json("res://data/progress.json")
	if loaded is Dictionary:
		data = loaded
	else:
		data = {"phase": 1, "phase_name": "", "stages": []}

## Erste nicht erledigte Etappe als Dictionary {"id", "name", "done"}.
func current_stage() -> Dictionary:
	for stage: Dictionary in data.get("stages", []):
		if not stage.get("done", false):
			return stage
	return {}

## ID der aktuellen Etappe, z. B. "1.1".
func current_stage_id() -> String:
	return str(current_stage().get("id", ""))

## Markiert eine Etappe als erledigt.
func mark_done(stage_id: String) -> void:
	for stage: Dictionary in data.get("stages", []):
		if stage.get("id") == stage_id:
			stage["done"] = true
			return
