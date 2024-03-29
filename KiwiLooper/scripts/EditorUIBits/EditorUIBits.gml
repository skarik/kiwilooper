function EditorUIBitsSetup()
{
	#macro kEditorUICursorNormal	0
	#macro kEditorUICursorMove		1
	#macro kEditorUICursorHSize		2
	#macro kEditorUICursorWSize		3
	uiCursor = kEditorUICursorNormal;
	uiNextCursor = kEditorUICursorNormal;
	
	uiScale = 1.5 * display_get_dpi_x() / 96.0; // TODO?
	
	// Create toolbar
	{
		m_toolbar = new AToolbar();
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 0, "Select", kEditorToolSelect));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 3, "Translate", kEditorToolTranslate));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 4, "Rotate", kEditorToolRotate));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 5, "Scale", kEditorToolScale));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 2, "Camera", kEditorToolCamera));
		m_toolbar.AddElement(new AToolbarElement());
		m_toolbar.AddElement(new AToolbarElement());
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTiles, 1, "Make Solids", kEditorToolMakeSolids));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTexture, 0, "Texture Tool", kEditorToolTextureSolids));
		m_toolbar.AddElement(new AToolbarElement());
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetObject, 0, "Add Prop", kEditorToolMakeProp));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetObject, 1, "Add Entity", kEditorToolMakeEntity));
		m_toolbar.AddElement(new AToolbarElement());
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTexture, 1, "Splats", kEditorToolSplats));
	}
	
	// Create top bar
	{
		m_actionbar = new AToolbarTop();
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 0, "New", null, EditorGlobalNewMap, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 1, "\"New\"ke", null, EditorGlobalNukeMap, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 3, "Load", null, EditorGlobalLoadMap, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 2, "Save", null, EditorGlobalSaveMap, null));
		m_actionbar.AddElement(AToolbarElementAsSpacer());
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 16, "Clear Tiles", null, function() { EditorTileMapSetup(); MapRebuildSolidsOnly(); }, null));
		m_actionbar.AddElement(AToolbarElementAsSpacer());
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 6, "Redo (No Effect)", null, null, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 5, "Undo (No Effect)", null, null, null));
		m_actionbar.AddElement(AToolbarElementAsSpacer());
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 4, "Begin testing level.", "Run", EditorGlobalTestMap, null, function(){ return m_state.map.geometry_valid; }));
		m_actionbar.AddElement(AToolbarElementAsSpacer());
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 7, "Toggle Grid Visible", null, function() { toolGridVisible = !toolGridVisible; }, function(){ return toolGridVisible; }));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 17, "Toggle Snap", null, EditorToolGridToggle, function(){ return toolGrid; }));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 8, "Larger Grid", null, EditorToolGridLarger, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 9, "Smaller Grid", null, EditorToolGridSmaller, null));
		m_actionbar.labelGridSize = m_actionbar.AddElement(AToolbarElementAsLabel(null, 0, "Current grid size", "Grid: 16", 15));
		m_actionbar.AddElement(AToolbarElementAsSpacer());
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetExtra, 2, "Toggle First Person Camera", null, function(){ m_state.camera.mode = !m_state.camera.mode; }, function() { return m_state.camera.mode; }));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetExtra, 0, "Center on selection", null, EditorCameraCenterOnSelection, null, function(){ return EditorSelectionGetLast() != null; }));
		m_actionbar.AddElement(AToolbarElementAsSpacer());
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 15, "Rebuild geometry information", "Compile", EditorGlobalCompileGeo, null, function(){ return !m_state.map.geometry_valid; })); // TODO: make a ui popup in case this takes forever
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 11, "Rebuild static lighting", "Toast Lights", EditorGlobalRebuildLights, null, function(){ return m_state.map.geometry_valid; }));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 12, "Rebuild navigation information", "Cook AI", EditorGlobalRebuildAI, null, function(){ return m_state.map.geometry_valid; })); // TODO: make a ui popup in case this takes forever
		// experimental stuff w/ view modes
		m_actionbar.AddElement(AToolbarElementAsSpacer());
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetRendering, 0, "Default", null, function() { global.shadeType = kShadeTypeDefault; }, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetRendering, 2, "Albedo", null, function() { global.shadeType = kShadeTypeDebug_Albedo; }, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetRendering, 3, "Albedo LD Utility", null, function() { global.shadeType = kShadeTypeDebug_AlbedoDarken; }, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetRendering, 1, "Lighting", null, function() { global.shadeType = kShadeTypeDebug_Lighting; }, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetRendering, 4, "Normals", null, function() { global.shadeType = kShadeTypeDebug_Normals; }, null));
	}
	
	// Create shortcuts (TODO)
	/*{
		m_shortcuts = new AShortcutManager();
		m_shortcuts.AddShortcut(ord("["), "Smaller Grid", EditorToolGridSmaller, null, null);
		m_shortcuts.AddShortcut(ord("]"), "Larger Grid", EditorToolGridLarger, null, null);
	}*/
	
	// Create status bar
	m_statusbar = new AEditorStatusbar(this);
	
	// Create minimenu
	m_minimenu = new AToolbarMini();
	
	// Create annotations
	EditorAnnotationsSetup();
	
	// Set up the windowing
	EditorWindowingSetup();
}

function EditorUIBitsUpdate()
{
	var l_mouseX = uPosition - GameCamera.view_x;
	var l_mouseY = vPosition - GameCamera.view_y;
	var l_bMouseAvailable = !EditorGizmoGetAnyConsumingMouse();
	
	m_toolbar.x = 0;
	m_toolbar.y = 18 * EditorGetUIScale();
	m_toolbar.Step(l_mouseX, l_mouseY, l_bMouseAvailable);
	
	m_actionbar.x = 0;
	m_actionbar.y = 0;
	m_actionbar.Step(l_mouseX, l_mouseY, l_bMouseAvailable);
	
	m_minimenu.Step(l_mouseX, l_mouseY, l_bMouseAvailable);
	
	m_statusbar.Step();
	
	// Update annotations
	EditorAnnotationsUpdate(l_mouseX, l_mouseY, l_bMouseAvailable);
	
	// Update windows
	EditorWindowingUpdate(l_mouseX, l_mouseY, l_bMouseAvailable);
	
	// Update cursor
	uiCursor = uiNextCursor;
	uiNextCursor = kEditorUICursorNormal;
	
	// size debug
	if (keyboard_check_pressed(vk_pageup))
	{
		uiScale += 0.25;
	}
	if (keyboard_check_pressed(vk_pagedown))
	{
		uiScale -= 0.25;
	}
}

function EditorUIBitsDraw()
{
	// Draw annotations under other UI
	EditorAnnotationsDraw();
	
	// Draw windows over annotations but under special bars
	EditorWindowingDraw();
	
	m_minimenu.Draw();
	m_toolbar.Draw();
	m_actionbar.Draw();
	
	// Statusbar over everything
	m_statusbar.Draw();
	
	// Draw an arrow for the mouse cursor.
	draw_set_color(c_white);
	if (uiCursor == kEditorUICursorNormal)
	{
		draw_sprite_ext(suie_cursors, 0, uPosition - GameCamera.view_x, vPosition - GameCamera.view_y, 1.0, 1.0, 0.0, c_white, 1.0);
	}
	else if (uiCursor == kEditorUICursorMove)
	{
		draw_sprite_ext(suie_cursors, 1, uPosition - GameCamera.view_x, vPosition - GameCamera.view_y, 1.0, 1.0, 0.0, c_white, 1.0);
	}
	else if (uiCursor == kEditorUICursorHSize)
	{
		draw_sprite_ext(suie_cursors, 2, uPosition - GameCamera.view_x, vPosition - GameCamera.view_y, 1.0, 1.0, 0.0, c_white, 1.0);
	}
	else if (uiCursor == kEditorUICursorWSize)
	{
		draw_sprite_ext(suie_cursors, 3, uPosition - GameCamera.view_x, vPosition - GameCamera.view_y, 1.0, 1.0, 0.0, c_white, 1.0);
	}
}