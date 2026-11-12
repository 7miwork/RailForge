class_name GameState
extends RefCounted
## Spielstand. KEIN Rendering, keine Nodes in src/core!
## Bleibt bei einem Ära-Wechsel vollständig erhalten.

const SAVE_VERSION := 1

var version: int = SAVE_VERSION
var era: int = 1
var tick: int = 0
var features: Dictionary = {} # Feature-Flags pro Ära
var phase: int = 1
var stage: String = "1.1" # Legacy-Feld, HUD liest aus Progress
var stage_name: String = "Bewegung & Kamera" # Legacy-Feld
var inventory: Inventory
var stats: Dictionary = {} # z. B. {"wood_collected": 5}

func _init() -> void:
	inventory = Inventory.new()

func add_stat(key: String, amount: int) -> void:
	stats[key] = int(stats.get(key, 0)) + amount

func to_dict() -> Dictionary:
	return {
		"version": version,
		"era": era,
		"tick": tick,
		"features": features,
		"phase": phase,
		"stage": stage,
		"stage_name": stage_name,
		"inventory": inventory.to_dict(),
		"stats": stats.duplicate(),
	}

static func from_dict(data: Dictionary) -> GameState:
	var s := GameState.new()
	s.version = data.get("version", SAVE_VERSION)
	s.era = data.get("era", 1)
	s.tick = data.get("tick", 0)
	s.features = data.get("features", {})
	s.phase = data.get("phase", 1)
	s.stage = data.get("stage", "1.1")
	s.stage_name = data.get("stage_name", "Bewegung & Kamera")
	s.inventory = Inventory.from_dict(data.get("inventory", {}))
	var saved_stats: Variant = data.get("stats", {})
	if saved_stats is Dictionary:
		s.stats = saved_stats.duplicate()
	return s
