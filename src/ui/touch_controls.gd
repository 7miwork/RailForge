class_name TouchControls
extends Control
## Virtueller Joystick (links unten) plus Aktions-Buttons (rechts unten:
## „E" für Abbau, „I" für Inventar). Übersetzt Eingabe in die
## move_*/interact/inventory_toggle-Input-Aktionen.
## Sichtbar nur auf Touch-Geräten, mobil oder im Editor (Maus-Test per
## emulate_touch_from_mouse).

const RADIUS := 64.0
const KNOB_RADIUS := 26.0
const DEADZONE := 0.25
const BUTTON_SIZE := 56.0

var _center := Vector2.ZERO
var _knob_offset := Vector2.ZERO
var _dragging := false
var _drag_index := -1

func _ready() -> void:
	var controls_visible := (
		DisplayServer.is_touchscreen_available()
		or OS.has_feature("mobile")
		or OS.has_feature("editor")
	)
	visible = controls_visible
	_center = size * 0.5
	if controls_visible:
		_make_action_button("debug_toggle", "F1", 0.0)
		_make_action_button("crafting_toggle", "C", BUTTON_SIZE + 12.0)
		_make_action_button("interact", "E", (BUTTON_SIZE + 12.0) * 2.0)
		_make_action_button("inventory_toggle", "I", (BUTTON_SIZE + 12.0) * 3.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_center = size * 0.5
		queue_redraw()

## Button unten rechts, der eine Input-Aktion per Druck/Loslassen auslöst.
func _make_action_button(action: StringName, text: String, y_offset: float) -> void:
	var btn := Button.new()
	btn.text = text
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(BUTTON_SIZE, BUTTON_SIZE)
	# Unten rechts im UI-Canvas (Elternteil ist die UI-CanvasLayer).
	btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	btn.offset_left = -BUTTON_SIZE - 16.0
	btn.offset_right = -16.0
	btn.offset_top = -BUTTON_SIZE - 16.0 - y_offset
	btn.offset_bottom = -16.0 - y_offset
	btn.button_down.connect(func() -> void: Input.action_press(action))
	btn.button_up.connect(func() -> void: Input.action_release(action))
	# Deferred: _ready läuft während des Szenen-Setups, add_child wäre sonst blockiert.
	get_parent().add_child.call_deferred(btn)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch_press(event)
	elif event is InputEventScreenDrag:
		_on_touch_drag(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var fake := InputEventScreenTouch.new()
		fake.index = 0
		fake.position = event.position
		fake.pressed = event.pressed
		_on_touch_press(fake)
	elif event is InputEventMouseMotion and _dragging:
		var fake := InputEventScreenDrag.new()
		fake.index = _drag_index
		fake.position = event.position
		fake.relative = event.relative
		_on_touch_drag(fake)

func _on_touch_press(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if not _dragging and event.position.distance_to(_center) <= RADIUS * 1.5:
			_dragging = true
			_drag_index = event.index
			_update_vector(event.position)
	else:
		if event.index == _drag_index:
			_stop_drag()

func _on_touch_drag(event: InputEventScreenDrag) -> void:
	if _dragging and event.index == _drag_index:
		_update_vector(event.position)

func _update_vector(touch_pos: Vector2) -> void:
	var v := (touch_pos - _center) / RADIUS
	v = v.limit_length(1.0)
	if v.length() < DEADZONE:
		v = Vector2.ZERO
	_knob_offset = v * RADIUS
	_apply_vector(v)
	queue_redraw()

func _stop_drag() -> void:
	_dragging = false
	_drag_index = -1
	_knob_offset = Vector2.ZERO
	_apply_vector(Vector2.ZERO)
	queue_redraw()

## Übersetzt den Joystick-Vektor in die move_*-Aktionen (inkl. analoge Stärke).
func _apply_vector(v: Vector2) -> void:
	_set_axis("move_right", "move_left", v.x)
	_set_axis("move_down", "move_up", v.y)

func _set_axis(positive: StringName, negative: StringName, value: float) -> void:
	if value > DEADZONE:
		Input.action_press(positive, value)
		Input.action_release(negative)
	elif value < -DEADZONE:
		Input.action_press(negative, -value)
		Input.action_release(positive)
	else:
		Input.action_release(positive)
		Input.action_release(negative)

func _draw() -> void:
	# Basisring
	draw_arc(_center, RADIUS, 0.0, TAU, 48, Color(1, 1, 1, 0.6), 3.0)
	draw_circle(_center, RADIUS * 0.25, Color(1, 1, 1, 0.15))
	# Knopf
	var knob := _center + _knob_offset
	draw_circle(knob, KNOB_RADIUS, Color(1, 1, 1, 0.75))
	draw_arc(knob, KNOB_RADIUS, 0.0, TAU, 32, Color(1, 1, 1, 0.9), 2.0)
