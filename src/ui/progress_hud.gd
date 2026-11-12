class_name ProgressHud
extends CanvasLayer
## Fortschrittsanzeige: „Phase X – Etappe Y: Name" aus Progress.current_stage()
## plus temporäre Flash-Nachrichten (z. B. „Gespeichert").
## Game-Boy-Palette als Platzhalter (echte Optik ab Etappe 1.6).

const COLOR_BG := Color("#9bbc0f")
const COLOR_TEXT := Color("#0f380f")

@onready var panel: PanelContainer = $Panel
@onready var label: Label = $Panel/VBox/Label
@onready var flash_label: Label = $Panel/VBox/FlashLabel

var progress: Progress
var state: GameState

func _ready() -> void:
	add_to_group("progress_hud")
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.set_content_margin_all(8.0)
	panel.add_theme_stylebox_override("panel", style)
	label.add_theme_color_override("font_color", COLOR_TEXT)
	flash_label.add_theme_color_override("font_color", COLOR_TEXT)

func setup(p_progress: Progress, p_state: GameState) -> void:
	progress = p_progress
	state = p_state
	refresh()

func refresh() -> void:
	if progress == null or state == null:
		return
	var current := progress.current_stage()
	var stage_id := str(current.get("id", state.stage))
	var stage_label := str(current.get("name", state.stage_name))
	label.text = "Phase %d – Etappe %s: %s" % [state.phase, stage_id, stage_label]

## Zeigt eine temporäre Nachricht unter dem Fortschrittstext.
func flash(text: String, duration: float = 1.0) -> void:
	flash_label.text = text
	flash_label.visible = true
	get_tree().create_timer(duration).timeout.connect(_hide_flash)

func _hide_flash() -> void:
	flash_label.visible = false
