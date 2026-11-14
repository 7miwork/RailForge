class_name EraRenderer
extends Node
## Basisklasse für Ära-Renderer. Jede Ära (src/render/eras/) erbt hiervon.
## Ein Ära-Wechsel tauscht nur den Renderer, der Spielstand bleibt.
## Jede Ära liefert ihre Farbpalette über get_palette() (für Übergänge/Tests).

## Die Palette der Ära (Standard: leer, wird pro Ära überschrieben).
func get_palette() -> Array[Color]:
	return []

func mount(_parent: Node) -> void:
	pass

func draw_state(_state: GameState) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func unmount() -> void:
	queue_free()
