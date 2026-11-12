class_name GameState
extends RefCounted
## Spielstand. KEIN Rendering, keine Nodes in src/core!
## Bleibt bei einem Ära-Wechsel vollständig erhalten.

const SAVE_VERSION := 1

var version: int = SAVE_VERSION
var era: int = 1
var tick: int = 0
var features: Dictionary = {} # Feature-Flags pro Ära

func to_dict() -> Dictionary:
	return {"version": version, "era": era, "tick": tick, "features": features}

static func from_dict(data: Dictionary) -> GameState:
	var s := GameState.new()
	s.version = data.get("version", SAVE_VERSION)
	s.era = data.get("era", 1)
	s.tick = data.get("tick", 0)
	s.features = data.get("features", {})
	return s
