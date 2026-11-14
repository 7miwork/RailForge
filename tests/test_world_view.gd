extends GutTest
## Smoke-Test: world_view.tscn muss die komplette SubViewport-Hierarchie
## enthalten, die main.gd und die World-Skripte per Pfad erwarten.
## Verhindert, dass Node-Pfade (z. B. Viewport/World) unbemerkt brechen.

func test_world_view_hierarchy() -> void:
	var packed := load("res://scenes/world_view.tscn") as PackedScene
	assert_not_null(packed, "world_view.tscn konnte nicht geladen werden")
	var view := packed.instantiate()
	add_child(view)

	# Root: SubViewportContainer
	assert_true(view is SubViewportContainer)

	# SubViewport mit Game-Boy-Auflösung
	var viewport := view.get_node_or_null("Viewport") as SubViewport
	assert_not_null(viewport, "Viewport (SubViewport) fehlt")
	if viewport != null:
		assert_eq(viewport.size, Vector2i(160, 144))
		assert_eq(viewport.render_target_update_mode, SubViewport.UPDATE_ALWAYS)

	# World-Knoten mit allen Welt-Kindern
	var world := viewport.get_node_or_null("World") as Node2D if viewport != null else null
	assert_not_null(world, "World (Node2D) im SubViewport fehlt")
	if world == null:
		view.free()
		return

	assert_not_null(world.get_node_or_null("Backdrop"), "Backdrop fehlt")

	var ground := world.get_node_or_null("Ground") as TileMapLayer
	assert_not_null(ground, "Ground (TileMapLayer) fehlt")
	if ground != null:
		assert_eq(ground.get_used_cells().size(), GroundLayer.WORLD_CELLS * GroundLayer.WORLD_CELLS)

	# Resource-Nodes
	for node_name in ["WoodNode", "StoneNode", "IronNode"]:
		var res := world.get_node_or_null(node_name)
		assert_not_null(res, "%s fehlt" % node_name)
		if res != null:
			assert_true(res is ResourceNode, "%s ist kein ResourceNode" % node_name)
			assert_not_null(res.get_node_or_null("Sprite2D"), "%s/Sprite2D fehlt" % node_name)
			assert_not_null(res.get_node_or_null("AmountLabel"), "%s/AmountLabel fehlt" % node_name)

	# Player + Kamera (Pfade, die main.gd benutzt)
	var player := world.get_node_or_null("Player") as Player
	assert_not_null(player, "Player fehlt")
	if player != null:
		assert_not_null(player.get_node_or_null("Sprite2D"), "Player/Sprite2D fehlt")
		assert_not_null(player.get_node_or_null("InteractionArea"), "Player/InteractionArea fehlt")

	var cam := world.get_node_or_null("Camera2D") as Camera2D
	assert_not_null(cam, "Camera2D fehlt")

	view.free()

func test_main_scene_world_view_path() -> void:
	# main.gd erwartet $WorldView/Viewport/World/Player und .../Camera2D.
	var packed := load("res://scenes/main.tscn") as PackedScene
	assert_not_null(packed, "main.tscn konnte nicht geladen werden")
	var main := packed.instantiate()
	add_child(main)

	assert_not_null(main.get_node_or_null("WorldView"), "Main/WorldView fehlt")
	assert_not_null(
		main.get_node_or_null("WorldView/Viewport/World/Player"),
		"WorldView/Viewport/World/Player fehlt"
	)
	assert_not_null(
		main.get_node_or_null("WorldView/Viewport/World/Camera2D"),
		"WorldView/Viewport/World/Camera2D fehlt"
	)
	for ui_name in ["ProgressHud", "InventoryUI", "CraftingUI", "DebugOverlay", "TouchControls"]:
		assert_not_null(main.get_node_or_null("UI/" + ui_name), "UI/%s fehlt" % ui_name)

	# TouchControls erstellt Buttons via call_deferred – erst einen Frame
	# warten, damit sie eingehängt sind, bevor main freigegeben wird.
	await get_tree().process_frame
	main.free()
