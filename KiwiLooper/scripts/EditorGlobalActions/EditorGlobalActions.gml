function EditorGet()
{
	return instance_find(ot_EditorTest, 0);
}

function EditorGlobalDeleteSelection()
{
	var bRebuildTiles = false;
	var bRebuildProps = false;
	var bRebuildSplats = false;
	
	for (var i = 0; i < array_length(m_selection); ++i)
	{
		var currentSelection = m_selection[i];
		
		// Is it a struct selection?
		if (is_struct(currentSelection))
		{
			switch (currentSelection.type)
			{
			case kEditorSelection_Tile:
				var tileIndex = m_tilemap.GetPositionIndex(currentSelection.object.x, currentSelection.object.y);
				var tileHeight = m_tilemap.tiles[tileIndex].height;
				m_tilemap.DeleteTileIndex(tileIndex);
				m_tilemap.RemoveHeightSlow(tileHeight);
				bRebuildTiles = true;
				break;
				
			case kEditorSelection_Prop:
				m_propmap.RemoveProp(currentSelection.object);
				delete currentSelection.object;
				bRebuildProps = true;
				break;
				
			case kEditorSelection_Splat:
				m_splatmap.RemoveSplat(currentSelection.object);
				delete currentSelection.object;
				bRebuildProps = true;
				break;
			}
		}
		// Is it an object selection?
		else if (iexists(currentSelection))
		{
			m_entityInstList.Remove(currentSelection); // Remove it from the entlist.
			idelete(currentSelection);
		}
	}
	
	m_selection = [];
	
	// Update gfx outside of the loop so that we don't overload anything
	if (bRebuildTiles)
	{
		MapRebuildGraphics();
	}
	else
	{
		if (bRebuildProps)
		{
			MapRebuilPropsOnly();
		}
		if (bRebuildSplats)
		{
			MapRebuildSplats();
		}
	}
}

function EditorGlobalClearSelection()
{
	m_selection = [];
	m_selectionSingle = false;
}

// Called when a selected object changes any transform property.
function EditorGlobalSignalTransformChange(entity, type, valueType, deferMeshBuilds=false)
{
	with (EditorGet())
	{
		// Update all tools:
		var tool = toolStates[kEditorToolTranslate, kEditorToolRotate, kEditorToolScale];
		tool.onSignalTransformChange(entity, type);
		
		// TODO: fill with the other gizmos
		
		// Find the properties panel and update the transform
		var panel;
		panel = EditorWindowFind(AEditorWindowProperties);
		if (is_struct(panel))
		{
			panel.InitUpdateEntityInfoTransform(entity);
		}
		
		if (!deferMeshBuilds)
		{
			// If the incoming ent is a prop, we gotta rebuild prop meshes
			if (is_struct(entity)) // assume struct inputs are props
			{
				if (type == kEditorSelection_Prop)
				{
					MapRebuilPropsOnly();
				}
				else if (type == kEditorSelection_Splat)
				{
					MapRebuildSplats();
				}
			}
			// otherwise, may need to request rebuilding gizmo meshes
			else if (iexists(entity))
			{
				if (!is_undefined(entity.entity.gizmoMesh) && entity.entity.gizmoMesh.shape == kGizmoMeshWireCube)
				{
					if (valueType == kValueTypeScale)
					{
						// Find the renderer & update it
						m_gizmoObject.m_entRenderObjects.RequestUpdate(entity);
					}
				}
			}
		}
	}
}

// Called when a selected object changes any non-transform property.
function EditorGlobalSignalPropertyChange(entity, type, property, value, deferMeshBuilds=false)
{
	with (EditorGet())
	{
		if (!deferMeshBuilds)
		{
			// If the incoming ent is a prop, we gotta rebuild prop meshes
			if (is_struct(entity)) // assume struct inputs are props
			{
				if (type == kEditorSelection_Prop)
				{
					// Rebuild props when changing the index
					if (property[0] == "index")
					{
						MapRebuilPropsOnly();
					}
				}
				else if (type == kEditorSelection_Splat)
				{
					MapRebuildSplats();
				}
			}
			// otherwise, may need to request rebuilding gizmo meshes
			else if (iexists(entity))
			{
				
			}
		}
	}
}

//=============================================================================

function EditorGlobalSaveMap()
{
	var default_name = "untitled.kmf";
	var map_filename = get_save_filename_ext("Tallymarks Map (.kmf)|*.kmf", default_name, fioLocalPathFindAbsoluteFilepath("maps"), "Save Map As");
	
	if (map_filename != "")
	{
		EditorGlobalSaveMap_Work(map_filename);
		EditorGet().m_currentMapName = map_filename;
	}
}
function EditorGlobalSaveMap_Work(filepath)
{
	var filedata = new AMapFiledata();
	
	MapSaveTilemap(filedata, EditorGet().m_tilemap);
	MapSaveProps(filedata, EditorGet().m_propmap);
	MapSaveEntities(filedata, EditorGet().m_entityInstList);
	MapSaveSplats(filedata, EditorGet().m_splatmap);
	MapSaveEditor(filedata, EditorGet().m_state);
	
	MapSaveFiledata(filepath, filedata);
	MapFreeFiledata(filedata);
	
	delete filedata;
}

function EditorGlobalLoadMap()
{
	var map_filename = get_open_filename_ext("Tallymarks File (.kmf)|*.kmf", "", fioLocalPathFindAbsoluteFilepath("maps"), "Open Map");
	
	if (map_filename != "")
	{
		EditorGlobalNukeMap_Work();
		EditorGet().m_currentMapName = map_filename;
		EditorGlobalLoadMap_Work(map_filename);
	
		with (EditorGet())
		{
			MapRebuildGraphics();
		}
	}
}
function EditorGlobalLoadMap_Work(filepath)
{
	var filedata = MapLoadFiledata(filepath);
	
	MapLoadTilemap(filedata, EditorGet().m_tilemap);
	MapLoadProps(filedata, EditorGet().m_propmap);
	MapLoadEntities(filedata, EditorGet().m_entityInstList);
	MapLoadSplats(filedata, EditorGet().m_splatmap);
	MapLoadEditor(filedata, EditorGet().m_state);
	
	MapFreeFiledata(filedata);
	delete filedata;
	
	// Setup all callbacks for the entities now.
	EditorEntities_SetupCallbacks();
}

function EditorGlobalNewMap()
{
	with (EditorGet())
	{
		// create the AEditorWindowDialog
		var dialog = EditorWindowAlloc(AEditorWindowDialog);
		dialog.content = "Warning: about to destroy the current map.";
		dialog.AddChoice(new dialog.AChoice("Continue", EditorGlobalNukeMap_Work));
		dialog.AddChoice(new dialog.AChoice("Cancel", null));
		dialog.Open();
	}
}

function EditorGlobalNukeMap()
{
	with (EditorGet())
	{
		// create the AEditorWindowDialog
		var dialog = EditorWindowAlloc(AEditorWindowDialog);
		dialog.content = "Warning: about to nuke the current map and settings.";
		dialog.AddChoice(new dialog.AChoice("Continue", EditorGlobalNukeMap_Work));
		dialog.AddChoice(new dialog.AChoice("Cancel", null));
		dialog.Open();
	}
}

function EditorGlobalNukeMap_Work()
{
	with (EditorGet())
	{
		// Go through the tiles
		m_tilemap.Clear();
		
		// Go through the props
		m_propmap.Clear();

		// Go through the ents
		m_entityInstList.Clear(); // this clears the list
		
		// Clear the splats
		m_splatmap.Clear();
		
		
		// Now rebuild everything
		// TODO: Is there a beter way to do this
		MapRebuildGraphics();
	}
}

//=============================================================================

function EditorGlobalTestMap()
{
	// First off, we need to save the map somewhere to use it
	var temp_mapname = fioLocalPathFindAbsoluteFilepath("maps") + "/_temp_testing.kmf";
	if (EditorGet().m_currentMapName != "")
	{
		temp_mapname = EditorGet().m_currentMapName;
	}
	
	EditorGlobalSaveMap_Work(temp_mapname);
	
	// Make this current room persistent & save state
	room_persistent = true;
	
	// Remove all the prop & tile layers
	EditorGet().MapFreeAllIntermediateLayers();
	
	// Go to the new map
	Game_LoadMap(temp_mapname, true);
}