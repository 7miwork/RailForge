class_name Player
extends CharacterBody2D
## Spieler-Figur. Bewegung läuft über die Input-Map-Aktionen
## move_up/move_down/move_left/move_right (Tastatur UND virtueller Joystick).
## Abbau läuft über "interact" (E / Touch-Button).

signal inventory_changed

@export var speed: float = 120.0
@export var world_size: Vector2 = Vector2(2000.0, 2000.0)

var state: GameState
var main_ref: Node

@onready var interaction_area: Area2D = $InteractionArea

var _era := 1

func _ready() -> void:
	_apply_era_visuals()

## Ära-Skin wechseln (Game Boy 8×8 ↔ NES 16×16), z. B. nach EraManager-Wechsel.
func set_era(era: int) -> void:
	_era = era
	if is_inside_tree():
		_apply_era_visuals()

func _apply_era_visuals() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		return
	if _era >= 2:
		sprite.texture = TilesNES.make_player()
	else:
		sprite.texture = Tiles.make_player()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func setup(p_state: GameState, p_main: Node = null) -> void:
	state = p_state
	main_ref = p_main

func _physics_process(_delta: float) -> void:
	# Während der Ära-Transition ist die Eingabe gesperrt.
	if EraTransition.input_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vec * speed
	move_and_slide()
	# Weltgrenzen (kein Wall-Clamping nötig, nur Position klemmen).
	position.x = clampf(position.x, 8.0, world_size.x - 8.0)
	position.y = clampf(position.y, 8.0, world_size.y - 8.0)

	# Abbau per Polling statt _unhandled_input: Berührungs-Buttons lösen die
	# Aktion über Input.action_press() aus, das kein InputEvent erzeugt.
	if Input.is_action_just_pressed("interact"):
		_try_mine()

func _try_mine() -> void:
	if state == null:
		return
	var nodes: Array = []
	for area: Area2D in interaction_area.get_overlapping_areas():
		if area is ResourceNode:
			nodes.append(area)
	var node := Mining.find_nearest_node(nodes, global_position)
	if node == null:
		return
	var result := Mining.mine_node(node, state.inventory, state)
	if node.is_depleted():
		node.queue_free()
	inventory_changed.emit()
	# Ergebnis (inkl. Stats-Vorher/Nachher) an main weiterreichen,
	# z. B. für Freischalt-Toasts.
	if main_ref != null and main_ref.has_method("on_resource_mined"):
		main_ref.on_resource_mined(result)
