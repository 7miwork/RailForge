class_name DebugOverlay
extends CanvasLayer
## Debug-Overlay (nur Entwicklung): Ära wechseln, Ressourcen +10,
## Save löschen, letzter Speicherzeitpunkt. Reine UI, keine Core-Logik.

signal era_changed(era_id: int)
signal state_changed
signal reset_requested

const COLOR_BG := Color(0.15, 0.15, 0.15, 0.9)
const COLOR_TEXT := Color(0.9, 0.9, 0.9)
const RESOURCE_ITEMS: Array[String] = ["wood", "stone", "iron_ore"]

var game_state: GameState
var main_ref: Node

var _era_ids: Array[int] = []

@onready var era_option: OptionButton = $Panel/VBox/EraRow/EraOption
@onready var item_box: HBoxContainer = $Panel/VBox/ItemRow
@onready var info_label: Label = $Panel/VBox/InfoLabel
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog

func _ready() -> void:
	add_to_group("debug_overlay")
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.set_content_margin_all(10.0)
	$Panel.add_theme_stylebox_override("panel", style)
	_build_eras()
	_build_item_buttons()
	visible = false

func bind(p_state: GameState, p_main: Node) -> void:
	game_state = p_state
	main_ref = p_main
	refresh_info()

func toggle() -> void:
	visible = not visible
	if visible:
		refresh_info()

func refresh_info() -> void:
	var ts := SaveManager.last_saved_at()
	if ts > 0:
		var dt := Time.get_datetime_dict_from_unix_time(ts)
		info_label.text = "Letzter Save: %02d.%02d.%d %02d:%02d" % [
			dt.get("day", 0), dt.get("month", 0), dt.get("year", 0),
			dt.get("hour", 0), dt.get("minute", 0),
		]
	else:
		info_label.text = "Kein Save vorhanden"

func _build_eras() -> void:
	var eras: Variant = DataLoader.load_json("res://data/eras.json")
	if not eras is Array:
		return
	for era: Dictionary in eras:
		_era_ids.append(int(era.get("id", 0)))
		era_option.add_item(str(era.get("name", "?")))
	era_option.item_selected.connect(_on_era_selected)
	_select_era_option()

func _select_era_option() -> void:
	if game_state == null:
		return
	var idx := _era_ids.find(game_state.era)
	if idx >= 0:
		era_option.select(idx)

func _on_era_selected(index: int) -> void:
	if index >= 0 and index < _era_ids.size():
		era_changed.emit(_era_ids[index])

func _build_item_buttons() -> void:
	for item_id in RESOURCE_ITEMS:
		var btn := Button.new()
		btn.text = "+10 %s" % ItemDB.display_name(item_id)
		btn.pressed.connect(_on_add_resource.bind(item_id))
		item_box.add_child(btn)

func _on_add_resource(item_id: String) -> void:
	if game_state == null:
		return
	game_state.inventory.add_item(item_id, 10, ItemDB.max_stack(item_id))
	state_changed.emit()

func _on_delete_pressed() -> void:
	confirm_dialog.popup_centered()

func _on_confirm_delete() -> void:
	SaveManager.delete()
	reset_requested.emit()
