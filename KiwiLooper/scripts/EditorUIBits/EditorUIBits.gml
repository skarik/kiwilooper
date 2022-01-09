function EditorUIBitsSetup()
{
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
}

function EditorUIBitsUpdate()
{
	var l_mouseX = uPosition - GameCamera.view_x;
	var l_mouseY = vPosition - GameCamera.view_y
	
	m_toolbar.x = 10;
	m_toolbar.y = 20;
	m_toolbar.Step(l_mouseX, l_mouseY);
	
	m_statusbar.Step();
	
	// Update annotations
	EditorAnnotationsUpdate(l_mouseX, l_mouseY);
}

function EditorUIBitsDraw()
{
	// Draw annotations under other UI
	EditorAnnotationsDraw();
	
	m_toolbar.Draw();
	
	// Statusbar over everything
	m_statusbar.Draw();
}