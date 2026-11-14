class_name EraTransition
extends Node
## Übergangsanimation zwischen Ären (~1,5 s, Tween-basiert).
## Ablauf: Farb-Flackern (alt↔neu) → Deckfläche deckt Bildschirm komplett
## (Signal transition_finished → EraManager tauscht Renderer, unsichtbar)
## → Deckfläche blendet aus → Eingabe wieder frei.
## Während der Animation ist input_locked = true (statisch): Player,
## main.gd und die Toggle-UIs prüfen das und ignorieren Eingaben.

signal transition_finished(new_era_id: int)

## Globaler Eingabe-Lock während der Transition (von Player/main/UI gelesen).
static var input_locked := false

const FLICKER_STEPS := 6
const FLICKER_STEP_TIME := 0.12
const COVER_TIME := 0.25
const REVEAL_TIME := 0.65

var _canvas: CanvasLayer
var _overlay: ColorRect
var _playing := false
var _pending_era := 0

func _ready() -> void:
	# Eigenes CanvasLayer oben (layer 100), deckt alles inkl. UI ab.
	_canvas = CanvasLayer.new()
	_canvas.layer = 100
	_canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_canvas)

	_overlay = ColorRect.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP # blockt Klicks
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.visible = false
	_canvas.add_child(_overlay)

func is_playing() -> bool:
	return _playing

## Startet die Transition zu `new_era_id`. `from_color`/`to_color` sind die
## repräsentativen Farben der alten/neuen Ära (z. B. Palette[0]).
func play_to_era(new_era_id: int, from_color := Color.BLACK, to_color := Color.WHITE) -> void:
	if _playing:
		return
	_playing = true
	_pending_era = new_era_id
	input_locked = true
	get_tree().root.gui_disable_input = true

	_overlay.visible = true
	_overlay.color = Color(from_color, 0.0)

	var tween := create_tween()
	# Flackern: abwechselnd alt/neue Farbe, jeweils auf und wieder transparent.
	for i in FLICKER_STEPS:
		var c := from_color if i % 2 == 0 else to_color
		var a := 0.35 + 0.15 * float(i % 3)
		tween.tween_property(_overlay, "color", Color(c, a), FLICKER_STEP_TIME * 0.5)
		tween.tween_property(_overlay, "color", Color(c, 0.0), FLICKER_STEP_TIME * 0.5)
	# Deckfläche wird komplett deckend: Tausch passiert unsichtbar darunter.
	tween.tween_property(_overlay, "color", Color(to_color, 1.0), COVER_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_on_covered)
	# Reveal: neue Ära blendet ein.
	tween.tween_property(_overlay, "color", Color(to_color, 0.0), REVEAL_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_finish)

func _on_covered() -> void:
	transition_finished.emit(_pending_era)

func _finish() -> void:
	_overlay.visible = false
	_overlay.color = Color(0, 0, 0, 0)
	input_locked = false
	get_tree().root.gui_disable_input = false
	_playing = false
	_pending_era = 0
