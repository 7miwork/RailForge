class_name EraRenderer
extends Node
## Basisklasse für Ära-Renderer. Jede Ära (src/render/eras/) erbt hiervon.
## Ein Ära-Wechsel tauscht nur den Renderer, der Spielstand bleibt.
## Ab Phase 1: Renderer zeigt zusätzlich die Fortschrittsanzeige (Phase + Etappe) an.

func mount(_parent: Node) -> void:
	pass

func draw_state(_state: GameState) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func unmount() -> void:
	queue_free()
