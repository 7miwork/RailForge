class_name InventoryUI
extends CanvasLayer
## Inventar-UI: 20 Slots (5x4), mittig, per "inventory_toggle" (I / Touch-Button)
## ein-/ausblendbar. Startet ausgeblendet.

const SLOT_COUNT := Inventory.MAX_SLOTS
const COLUMNS := 5
const COLOR_EMPTY := Color("#2f4f2f")
const COLOR_TEXT := Color("#0f380f")

var inventory: Inventory

var _grid: GridContainer
var _slot_panels: Array[PanelContainer] = []
var _slot_labels: Array[Label] = []
var _slot_styles: Array[StyleBoxFlat] = []

func _ready() -> void:
	add_to_group("inventory_ui")
	_grid = $Panel/Grid
	_build_slots()
	visible = false

func bind_inventory(inv: Inventory) -> void:
	inventory = inv
	refresh()

func _build_slots() -> void:
	for i in SLOT_COUNT:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(56, 56)
		var style := StyleBoxFlat.new()
		style.bg_color = COLOR_EMPTY
		style.set_content_margin_all(4.0)
		panel.add_theme_stylebox_override("panel", style)

		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.add_theme_color_override("font_color", COLOR_TEXT)
		panel.add_child(label)

		_grid.add_child(panel)
		_slot_panels.append(panel)
		_slot_labels.append(label)
		_slot_styles.append(style)

func _process(_delta: float) -> void:
	# Polling statt _unhandled_input: Touch-Button nutzt Input.action_press().
	if Input.is_action_just_pressed("inventory_toggle"):
		visible = not visible

func refresh() -> void:
	if inventory == null:
		return
	for i in SLOT_COUNT:
		var slot: Dictionary = inventory.slots[i]
		var item_id := str(slot.get("item_id", ""))
		var label := _slot_labels[i]
		var style := _slot_styles[i]
		if item_id.is_empty():
			label.text = ""
			style.bg_color = COLOR_EMPTY
		else:
			label.text = "%s\nx%d" % [ItemDB.display_name(item_id), int(slot.get("amount", 0))]
			style.bg_color = ItemDB.color(item_id)
