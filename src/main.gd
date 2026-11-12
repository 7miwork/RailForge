extends Node
## Einstiegspunkt. In Phase 0 nur ein Platzhalter-Text.
## Ab Phase 1 kommt hier die Fortschrittsanzeige (Phase + Etappe) dazu.

var state: GameState

func _ready() -> void:
	state = GameState.new()
	var label := Label.new()
	label.text = "Railforge – Phase 0 Fundament. Ära %d" % state.era
	label.position = Vector2(32, 32)
	add_child(label)
