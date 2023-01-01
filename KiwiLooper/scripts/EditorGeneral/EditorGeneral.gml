function EditorLevel_Init()
{
	x = 0;
	y = 0;
	z = 0;

	// Kill the gameplay now
	idelete(Gameplay);

	// Update the screen now
	Screen.scaleMode = kScreenscalemode_Expand;
	Screen.pixelScale = 1.0;

	// Set up serialized state
	m_state = new AMapEditorState();

	EditorToolsSetup();

	m_currentMapName = "";

	// List of all layers currently used for the tiles and props.
	//solidsRenderer = null;
	EditorSolidsRendererDeclare();
	
	// Rebuilds all the graphics for the map: props, tilemap, and splats
	MapRebuildGraphics = function()
	{
		// Delete existing renderers
		idelete(o_tileset3DIze2);
	
		// Delete all current intermediate layers
		MapFreeAllIntermediateLayers();
	
		// Build tilemap rendering
		var tilemap_renderer = inew(o_tileset3DIze2);
		tilemap_renderer.SetTilemap(m_tilemap);
		tilemap_renderer.BuildMesh();
		
		// Build solids
		EditorSolidsRendererFree();
		EditorSolidsRendererCreate();
		
		// Rebuild props now
		MapRebuilPropsOnly();
	
		// Now that we have collision, recreate the splats
		MapRebuildSplats();
	}
	
	// Rebuilds only the solids graphics
	MapRebuildSolidsOnly = function(solid_id = null)
	{
		// Delete existing renderers
		idelete(o_tileset3DIze2);
		
		// Delete all current intermediate layers
		MapFreeAllIntermediateLayers();
		
		// Build tilemap rendering
		var tilemap_renderer = inew(o_tileset3DIze2);
		tilemap_renderer.SetTilemap(m_tilemap);
		tilemap_renderer.BuildMesh();
		
		// Build solids
		if (solid_id == null)
		{
			EditorSolidsRendererFree();
			EditorSolidsRendererCreate();
		}
		else
		{
			EditorSolidsRendererRecreate(solid_id);
		}
	
		// Now that we have collision, recreate the splats
		MapRebuildSplats();
	}
	
	// Rebuilds all the grphics for the map: props only
	MapRebuilPropsOnly = function()
	{
		// Delete existing renderers
		idelete(o_props3DIze2);
	
		// Set up the props
		var props = inew(o_props3DIze2);
		props.SetMap(m_propmap);
		props.BuildMesh();
	}
	
	// Rebuilds all the graphics for the map: splats only
	MapRebuildSplats = function()
	{
		// Delete all splats
		idelete(ob_splatter);
	
		// Trigger the splats
		m_splatmap.SpawnSplats();
	
		// Force splats to update
		if (instance_number(ob_splatter) == 0)
		{
			if (iexists(o_splatterRenderer))
			{
				o_splatterRenderer.update();
			}
		}
	}
	MapFreeAllIntermediateLayers = function()
	{
		// Done.
	}

	EditorUIBitsSetup();
	EditorCameraSetup();
	EditorGizmoSetup();
	EditorSelectionSetup();
	EditorClipboardSetup();

	EditorTileMapSetup();
	EditorPropAndSplatSetup();
	m_entityInstList = new AEntityList();
	m_aimap = new AMapAiInfo();
	m_mapgeometry = new AMapGeometry();

	m_taskRebuildAi = null;
	m_taskRebuildLighting = null;

	// TODO: combine with [m_solidUpdateRequestList]
	m_wantRebuildSolids = false;
	m_solidUpdateRequestList = [];
	
	
	// Everything is set up, load options
	EditorSettingsLoad();
}

function EditorLevel_Cleanup()
{
	// Save options on quit
	EditorSettingsSave();
	
	EditorSolidsRendererFree(); // TODO: Other
	EditorSolidsRendererEnd();
}

//=============================================================================