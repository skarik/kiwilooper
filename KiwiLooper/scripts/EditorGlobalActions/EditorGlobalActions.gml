function EditorGet()
{
	return instance_find(o_EditorLevel, 0);
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
				
			case kEditorSelection_Primitive:
				var solidIndex = array_get_index(m_state.map.solids, currentSelection.object.primitive);
				if (solidIndex != null)
				{
					delete currentSelection.object.primitive;
					array_delete(m_state.map.solids, solidIndex, 1);
					bRebuildTiles = true;
				}
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
		var toolsToUpdate = [kEditorToolTranslate, kEditorToolRotate, kEditorToolScale];
		for (var updateIndex = 0; updateIndex < array_length(toolsToUpdate); ++updateIndex)
		{
			var tool = toolStates[toolsToUpdate[updateIndex]];
			tool.onSignalTransformChange(entity, type);
		}
		
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
				else if (type == kEditorSelection_Primitive)
				{
					MapRebuildSolidsOnly();
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
		else
		{
			if (is_struct(entity)) // assume struct inputs are props
			{
				if (type == kEditorSelection_Primitive)
				{
					m_wantRebuildSolids = true;
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
	MapSaveAi(filedata, EditorGet().m_aimap);
	
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
	MapLoadAi(filedata, EditorGet().m_aimap);
	
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
	EditorGlobalClearSelection(); // Clear selection so not holding onto anything that's getting nuked.
	
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
		
		// Clear the ai map
		m_aimap = new AMapAiInfo();
		
		// Clear solids
		m_state.map.solids = [];
		
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

//=============================================================================

function EditorGlobalRebuildAI()
{
	// Stop any existing ai building task
	var existing_task = EditorGet().m_taskRebuildAi;
	if (is_struct(existing_task))
	{
		if (!existing_task.isDone())
		{
			existing_task.stop();
		}
	}
	
	var ai_map = EditorGet().m_aimap;
	var entityInstanceList = EditorGet().m_entityInstList;
	
	// Let's roll.
	
	// Clear out all the nodes in the map
	ai_map.nodes = array_create(0);
	
	// Loop through all the ents and create nodes
	for (var entIndex = 0; entIndex < entityInstanceList.GetEntityCount(); ++entIndex)
	{
		var instance = entityInstanceList.GetEntity(entIndex);
		var ent = instance.entity;
		
		if (ent.name == "ai_node")
		{
			var node = new AAiNode();
			node.position.copyFrom(instance);
			node.rotation.x = instance.xrotation;
			node.rotation.y = instance.yrotation;
			node.rotation.z = instance.zrotation;
			
			array_push(ai_map.nodes, node);
		}
	}
	
	var tasker = new ATaskRunner(); // Next step can be super slow, so we need to make a tasker
	tasker
		.addTask(method(ai_map,
			function() {
				// Immediately mark the ai map as invalid (it should be at this point, but we do so anyways.
				bNeedsRebuild = true; 
			}));
		
	// Rebuild the node map now that we've set it up with a bunch of unconnected nodes:
	AiRebuildPathing(ai_map, tasker);
	
	tasker
		.addTask(method(ai_map,
			function() {
				// And we're okay now at the end of it!
				bNeedsRebuild = false; 
			}))
		 // Run the task with 2ms limits to keep the UI responsive
		.execute(2000);
		
	// Save the task in case we need to cancel
	EditorGet().m_taskRebuildAi = tasker;
}