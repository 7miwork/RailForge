extends Node
## Einstiegspunkt. Verdrahtet GameState, Progress, Ära-Renderer, HUD,
## Inventar-UI, Crafting-UI und Touch-Steuerung.

@onready var world: Node2D = $World
@onready var player: Player = $World/Player
@onready var camera: Camera2D = $Camera2D
@onready var progress_hud: ProgressHud = $UI/ProgressHud
@onready var inventory_ui: InventoryUI = $UI/InventoryUI
@onready var crafting_ui: CraftingUI = $UI/CraftingUI
@onready var touch_controls: TouchControls = $UI/TouchControls

var state: GameState
var progress: Progress
var renderer: EraRenderer

func _ready() -> void:
	state = GameState.new()
	progress = Progress.new()

	renderer = Era1Monoch.new()
	renderer.mount(self)
	renderer.draw_state(state)

	progress_hud.setup(progress, state)

	player.setup(state)
	player.inventory_changed.connect(inventory_ui.refresh)
	inventory_ui.bind_inventory(state.inventory)

	crafting_ui.bind(state)
	crafting_ui.crafted.connect(func(_id: String) -> void: inventory_ui.refresh())

	# Spieler startet in der Mitte der Welt, Kamera darauf.
	player.position = world_size() * 0.5
	camera.position = player.position

func _process(_delta: float) -> void:
	camera.position = player.position

func world_size() -> Vector2:
	return player.world_size
