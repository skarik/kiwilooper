function EditorUIBitsSetup()
{
	#macro kEditorUICursorNormal 0
	#macro kEditorUICursorMove 1
	#macro kEditorUICursorHSize 2
	uiCursor = kEditorUICursorNormal;
	uiNextCursor = kEditorUICursorNormal;
	
	// Create toolbar
	{
		m_toolbar = new AToolbar();
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 0, "Select", kEditorToolSelect));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 3, "Translate", kEditorToolTranslate));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 4, "Rotate", kEditorToolRotate));
		//m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 1, "Zoom", kEditorToolZoom));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 2, "Camera", kEditorToolCamera));
		m_toolbar.AddElement(new AToolbarElement());
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTiles, 1, "Add/Subtract Tiles", kEditorToolTileEditor));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTiles, 2, "Edit Elevation", kEditorToolTileHeight));
		m_toolbar.AddElement(new AToolbarElement());
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetObject, 0, "Add Prop", kEditorToolMakeProp));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetObject, 1, "Add Entity", kEditorToolMakeEntity));
		m_toolbar.AddElement(new AToolbarElement());
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTexture, 0, "Texture", kEditorToolTexture));
		m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTexture, 1, "Splats", kEditorToolSplats));
	}
	
	// Create top bar
	{
		m_actionbar = new AToolbarTop();
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 0, "New", null, null, EditorGlobalNewMap));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 1, "\"New\"ke", null, null, EditorGlobalNukeMap));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 3, "Load", null, null, EditorGlobalLoadMap));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 2, "Save", null, null, EditorGlobalSaveMap));
		m_actionbar.AddElement(AToolbarElementAsSpacer());
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 6, "Redo (No Effect)", null, null, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 5, "Undo (No Effect)", null, null, null));
		m_actionbar.AddElement(AToolbarElementAsSpacer());
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 4, "Begin testing level.", "Run", null, null));
		m_actionbar.AddElement(AToolbarElementAsSpacer());
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 7, "Toggle Grid", null, null, function(){ return true; }));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 8, "Larger Grid", null, null, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 9, "Smaller Grid", null, null, null));
		m_actionbar.AddElement(AToolbarElementAsSpacer());
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 11, "Rebuild static lighting", "Toast Lights", null, null));
		m_actionbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetBasic, 12, "Rebuild navigation information", "Cook AI", null, null));
	}
	
	// Create status bar
	m_statusbar = new AEditorStatusbar(this);
	
	// Create annotations
	EditorAnnotationsSetup();
	
	// Set up the windowing
	EditorWindowingSetup();
}

function EditorUIBitsUpdate()
{
	var l_mouseX = uPosition - GameCamera.view_x;
	var l_mouseY = vPosition - GameCamera.view_y;
	
	m_toolbar.x = 0;
	m_toolbar.y = 18;
	m_toolbar.Step(l_mouseX, l_mouseY);
	
	m_actionbar.x = 0;
	m_actionbar.y = 0;
	m_actionbar.Step(l_mouseX, l_mouseY);
	
	m_statusbar.Step();
	
	// Update annotations
	EditorAnnotationsUpdate(l_mouseX, l_mouseY);
	
	// Update windows
	EditorWindowingUpdate(l_mouseX, l_mouseY);
	
	// Update cursor
	uiCursor = uiNextCursor;
	uiNextCursor = kEditorUICursorNormal;
}

function EditorUIBitsDraw()
{
	// Draw annotations under other UI
	EditorAnnotationsDraw();
	
	// Draw windows over annotations but under special bars
	EditorWindowingDraw();
	
	m_toolbar.Draw();
	m_actionbar.Draw();
	
	// Statusbar over everything
	m_statusbar.Draw();
	
	// Draw an arrow for the mouse cursor.
	draw_set_color(c_white);
	if (uiCursor == kEditorUICursorNormal)
	{
		/*draw_arrow(10 + uPosition - GameCamera.view_x, 10 + vPosition - GameCamera.view_y,
				        uPosition - GameCamera.view_x,      vPosition - GameCamera.view_y,
				   10);*/
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
}