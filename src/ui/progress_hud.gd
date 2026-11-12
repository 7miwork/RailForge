class_name ProgressHud
extends CanvasLayer
## Fortschrittsanzeige (oben links): Etappenzähler, Etappenname,
## Fortschrittsbalken und Ressourcen-Kompaktanzeige – alles aus
## Progress (statisch) und GameState. Plus temporäre flash()/toast()-Nachrichten.
## Game-Boy-Palette als Platzhalter (echte Optik ab Etappe 1.6).

const COLOR_BG := Color("#9bbc0f")
const COLOR_TEXT := Color("#0f380f")
const COLOR_BAR_BG := Color("#9bbc0f")
const COLOR_BAR_FILL := Color("#0f380f")

@onready var stage_line: Label = $Panel/VBox/StageLine
@onready var name_line: Label = $Panel/VBox/NameLine
@onready var bar: ProgressBar = $Panel/VBox/Bar
@onready var stats_line: Label = $Panel/VBox/StatsLine
@onready var flash_label: Label = $Panel/VBox/FlashLabel
@onready var toast_panel: PanelContainer = $ToastPanel
@onready var toast_label: Label = $ToastPanel/VBox/ToastLabel

var state: GameState
var _toast_tween: Tween

func _ready() -> void:
	add_to_group("progress_hud")
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.set_content_margin_all(8.0)
	$Panel.add_theme_stylebox_override("panel", style)
	for l: Label in [stage_line, name_line, stats_line, flash_label, toast_label]:
		l.add_theme_color_override("font_color", COLOR_TEXT)
	bar.add_theme_stylebox_override("background", _flat_style(COLOR_BAR_BG))
	bar.add_theme_stylebox_override("fill", _flat_style(COLOR_BAR_FILL))
	toast_panel.visible = false
	toast_panel.modulate.a = 1.0

func _flat_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	return s

func setup(p_state: GameState) -> void:
	state = p_state
	refresh()

func refresh() -> void:
	if state == null:
		return
	var total := Progress.total_count()
	var done := Progress.done_count()
	var current := Progress.current_stage()

	if total > 0 and done >= total:
		# Alle Etappen erledigt: letzte Etappe als Name anzeigen.
		var stages := Progress.all_stages()
		var last_name := str(stages[stages.size() - 1].get("name", "")) if not stages.is_empty() else ""
		stage_line.text = "Phase %d – alle Etappen abgeschlossen" % state.phase
		name_line.text = last_name
	else:
		stage_line.text = "Phase %d – Etappe %d/%d" % [state.phase, Progress.current_index(), total]
		name_line.text = str(current.get("name", state.stage_name))

	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.value = Progress.progress_ratio()

	var stats: Dictionary = state.stats
	stats_line.text = "Holz %d · Stein %d · Erz %d" % [
		int(stats.get("wood_collected", 0)),
		int(stats.get("stone_collected", 0)),
		int(stats.get("iron_ore_collected", 0)),
	]

## Zeigt eine temporäre Nachricht unter dem Fortschrittstext.
func flash(text: String, duration: float = 1.0) -> void:
	flash_label.text = text
	flash_label.visible = true
	get_tree().create_timer(duration).timeout.connect(_hide_flash)

func _hide_flash() -> void:
	flash_label.visible = false

## Milestone-Toast unten mittig, fadet nach `duration` aus.
## Ein neuer Toast ersetzt den laufenden (keine Stapelung).
func toast(text: String, duration: float = 2.5) -> void:
	toast_label.text = text
	toast_panel.visible = true
	toast_panel.modulate.a = 1.0
	if _toast_tween != null:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(maxf(0.0, duration - 0.5))
	_toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.5)
	_toast_tween.tween_callback(func() -> void: toast_panel.visible = false)
