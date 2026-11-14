class_name EraManager
extends Node
## Verwaltet den aktiven Ära-Renderer zur Laufzeit.
## main.gd erzeugt genau einen EraManager; er mountet den Renderer passend
## zu state.era, spielt bei einem Wechsel die EraTransition-Animation ab und
## tauscht danach Renderer, Viewport-Auflösung und Welt-Skins (Tiles) aus.
## Der Spielstand (GameState) bleibt dabei immer erhalten.

signal era_changed(era_id: int)

## Renderer-Klasse pro Ära-ID (Klassen-Referenzen sind keine
## Konstanten-Ausdrücke → per Match statt const-Dict).
static func _renderer_class(era_id: int) -> GDScript:
	match era_id:
		1:
			return Era1Monoch
		2:
			return Era2Nes
		_:
			return null

## SubViewport-Auflösung je Ära (Game-Boy 160×144, NES 256×240).
const VIEWPORT_SIZES := {
	1: Vector2i(160, 144),
	2: Vector2i(256, 240),
}

## stretch_shrink je Ära: darstellung = viewport_size × shrink (immer 720 hoch).
const VIEWPORT_SHRINK := {
	1: 5, # 160×144 → 800×720
	2: 3, # 256×240 → 768×720
}

var current_renderer: EraRenderer
var transition: EraTransition
var state: GameState

var _world_view: SubViewportContainer
var _viewport: SubViewport
var _pending_renderer: EraRenderer = null
var _pending_era := 0

func setup(world_view: SubViewportContainer) -> void:
	_world_view = world_view
	_viewport = world_view.get_node_or_null("Viewport") as SubViewport
	transition = EraTransition.new()
	transition.name = "EraTransition"
	add_child(transition)
	transition.transition_finished.connect(_on_transition_finished)

func is_transitioning() -> bool:
	return transition != null and transition.is_playing()

## Erster Mount passend zum geladenen Spielstand (kein Übergang).
func mount_initial(p_state: GameState) -> void:
	state = p_state
	_apply_era(state.era)

## Ära wechseln: erst Animation, dann Tausch (unsichtbar unter Deckfläche).
## Für Ären ohne Renderer: Warning, nichts passiert.
func change_era(era_id: int, p_state: GameState = null) -> void:
	if p_state != null:
		state = p_state
	if era_id == _current_era_id():
		return
	if _renderer_class(era_id) == null:
		push_warning("EraManager: kein Renderer für Ära %d" % era_id)
		return
	var new_renderer := _make_renderer(era_id)
	var from_color := current_renderer.get_palette()[0] if current_renderer != null and not current_renderer.get_palette().is_empty() else Color.BLACK
	var to_color := new_renderer.get_palette()[0] if not new_renderer.get_palette().is_empty() else Color.WHITE
	_pending_renderer = new_renderer
	_pending_era = era_id
	transition.play_to_era(era_id, from_color, to_color)

func _current_era_id() -> int:
	return state.era if state != null else 0

func _make_renderer(era_id: int) -> EraRenderer:
	var cls: GDScript = _renderer_class(era_id)
	if cls == null:
		return null
	return (cls as GDScript).new() as EraRenderer

func _on_transition_finished(era_id: int) -> void:
	if _pending_renderer == null or era_id != _pending_era:
		return
	var renderer := _pending_renderer
	_pending_renderer = null
	_pending_era = 0
	_apply_era(era_id, renderer)

## Direkter Tausch ohne Animation (Initial-Mount) oder mit übergebenem Renderer.
func _apply_era(era_id: int, renderer: EraRenderer = null) -> void:
	if renderer == null:
		if _renderer_class(era_id) == null:
			push_warning("EraManager: kein Renderer für Ära %d" % era_id)
			return
		renderer = _make_renderer(era_id)

	if current_renderer != null:
		current_renderer.unmount()
	current_renderer = renderer
	current_renderer.mount(self)

	if state != null:
		state.era = era_id
		# Meilenstein-Marken aktualisieren (idempotent).
		EraUnlocks.mark_unlocked(state, era_id)
	_apply_viewport_for_era(era_id)
	_apply_world_skins(era_id)
	era_changed.emit(era_id)
	if state != null:
		current_renderer.draw_state(state)

## SubViewport-Auflösung und Container-Größe an die Ära anpassen.
func _apply_viewport_for_era(era_id: int) -> void:
	if _viewport == null or _world_view == null:
		return
	var vp_size: Vector2i = VIEWPORT_SIZES.get(era_id, VIEWPORT_SIZES[1])
	var shrink: int = VIEWPORT_SHRINK.get(era_id, 5)
	# SubViewport.size darf bei aktivem stretch nicht geändert werden:
	# kurz deaktivieren, Größe setzen, stretch wieder an.
	_world_view.stretch = false
	_viewport.size = vp_size
	_world_view.stretch = true
	_world_view.stretch_shrink = shrink
	# Container bleibt mittig im 1280×720-Fenster, Größe = vp × shrink.
	var disp := Vector2(vp_size) * float(shrink)
	_world_view.offset_left = -disp.x * 0.5
	_world_view.offset_top = -disp.y * 0.5
	_world_view.offset_right = disp.x * 0.5
	_world_view.offset_bottom = disp.y * 0.5
	_world_view.custom_minimum_size = disp

## Welt-Skins tauschen: Backdrop-Farbe, Ground-Textur, Ressourcen,
## Spieler – alles über set_era() der jeweiligen Welt-Nodes.
func _apply_world_skins(era_id: int) -> void:
	if _viewport == null:
		return
	var world := _viewport.get_node_or_null("World")
	if world == null:
		return
	var backdrop := world.get_node_or_null("Backdrop") as ColorRect
	if backdrop != null and current_renderer != null:
		backdrop.color = current_renderer.get_backdrop_color()
	var ground := world.get_node_or_null("Ground") as GroundLayer
	if ground != null:
		ground.set_era(era_id)
	for child in world.get_children():
		if child is ResourceNode:
			child.set_era(era_id)
	var player := world.get_node_or_null("Player") as Player
	if player != null:
		player.set_era(era_id)
