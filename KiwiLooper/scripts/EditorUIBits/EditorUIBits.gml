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
	m_toolbar.y = 20;
	m_toolbar.Step(l_mouseX, l_mouseY);
	
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