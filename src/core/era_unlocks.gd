class_name EraUnlocks
extends RefCounted
## Prüft Ära-Freischaltungen aus data/eras.json gegen den GameState.
## Reine Core-Logik (kein Rendering). Bereits erfolgte Freischaltungen werden
## in state.features["unlocked_eras"] persistiert (überlebt Save/Load).
##
## Unlock-Typen (aus eras.json "unlock"):
##   "start"                              → immer frei (Ära 1)
##   {"type": "crafted", "item_id": X, "amount": N}
##                                      → stats["crafted_" + X] >= N
##   {"type": "collected", ...}           → stats[X + "_collected"] >= N
## Alles andere/unbekannte Typen → nicht frei (defensiv).

const ERAS_PATH := "res://data/eras.json"
const UNLOCKED_KEY := "unlocked_eras"

static func _eras() -> Array:
	var loaded: Variant = DataLoader.load_json(ERAS_PATH)
	return loaded if loaded is Array else []

static func _era_by_id(era_id: int) -> Dictionary:
	for era: Dictionary in _eras():
		if int(era.get("id", 0)) == era_id:
			return era
	return {}

## Ist die Bedingung der Ära formal erfüllt (ohne Hinweis auf bisherigen Fortschritt)?
static func is_satisfied(era_id: int, state: GameState) -> bool:
	var era := _era_by_id(era_id)
	if era.is_empty():
		return false
	return _unlock_satisfied(era.get("unlock"), state)

static func _unlock_satisfied(unlock: Variant, state: GameState) -> bool:
	if unlock is String:
		return str(unlock) == "start"
	if not unlock is Dictionary:
		return false
	var amount := int(unlock.get("amount", 0))
	match str(unlock.get("type", "")):
		"crafted":
			return int(state.stats.get("crafted_" + str(unlock.get("item_id", "")), 0)) >= amount
		"collected":
			return int(state.stats.get(str(unlock.get("item_id", "")) + "_collected", 0)) >= amount
		_:
			return false

## Bereits als freigeschaltet markierte Ären (enthält immer die Start-Ära 1).
static func unlocked_eras(state: GameState) -> Array[int]:
	var result: Array[int] = [1]
	var stored: Variant = state.features.get(UNLOCKED_KEY, [])
	if stored is Array:
		for v: Variant in stored:
			var id := int(v)
			if id > 0 and not result.has(id):
				result.append(id)
	return result

## Erfüllte, aber noch nicht markierte Freischaltungen (Meilensteine).
static func pending_unlocks(state: GameState) -> Array[int]:
	var result: Array[int] = []
	var unlocked := unlocked_eras(state)
	for era: Dictionary in _eras():
		var era_id := int(era.get("id", 0))
		if era_id <= 0 or unlocked.has(era_id):
			continue
		if _unlock_satisfied(era.get("unlock"), state):
			result.append(era_id)
	return result

## Markiert eine Ära als freigeschaltet (idempotent).
static func mark_unlocked(state: GameState, era_id: int) -> void:
	if era_id <= 0 or unlocked_eras(state).has(era_id):
		return
	var stored: Variant = state.features.get(UNLOCKED_KEY, [])
	var list: Array = stored if stored is Array else []
	list.append(era_id)
	state.features[UNLOCKED_KEY] = list

## Nächste freischaltbare Ära vor dem aktuellen Fortschritt (für Debug-Anzeige).
static func next_unlock_hint(state: GameState) -> String:
	for era: Dictionary in _eras():
		var era_id := int(era.get("id", 0))
		if era_id <= state.era:
			continue
		var unlock: Variant = era.get("unlock")
		if unlock is Dictionary and str(unlock.get("type", "")) == "crafted":
			var item := str(unlock.get("item_id", ""))
			return "%s: %dx %s" % [str(era.get("name", "?")), int(unlock.get("amount", 0)), ItemDB.display_name(item)]
	return ""
