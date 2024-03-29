function EditorGet()
{
	gml_pragma("forceinline");
	return instance_find(o_EditorLevel, 0);
}

function EditorGlobalDeleteSelection()
{
	var bRebuildTiles = false;
	var bRebuildProps = false;
	var bRebuildSplats = false;
	var bRebuildSolids = false;
	
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
				EditorGlobalSignalObjectDeleted(m_tilemap.tiles[tileIndex], kEditorSelection_Tile, true);
				m_tilemap.DeleteTileIndex(tileIndex);
				m_tilemap.RemoveHeightSlow(tileHeight);
				bRebuildTiles = true;
				break;
				
			case kEditorSelection_Prop:
				EditorGlobalSignalObjectDeleted(currentSelection.object, kEditorSelection_Prop, true);
				m_propmap.RemoveProp(currentSelection.object);
				delete currentSelection.object;
				bRebuildProps = true;
				break;
				
			case kEditorSelection_Splat:
				EditorGlobalSignalObjectDeleted(currentSelection.object, kEditorSelection_Splat, true);
				m_splatmap.RemoveSplat(currentSelection.object);
				delete currentSelection.object;
				bRebuildProps = true;
				break;
				
			case kEditorSelection_Primitive:
				EditorGlobalSignalObjectDeleted(currentSelection.object.primitive, kEditorSelection_Primitive, true);
				
				var solidIndex = array_get_index(m_state.map.solids, currentSelection.object.primitive);
				if (solidIndex != null)
				{
					delete currentSelection.object.primitive;
					array_delete(m_state.map.solids, solidIndex, 1);
					bRebuildSolids = true;
				}
				EditorGlobalMarkDirtyGeometry();
				break;
			}
		}
		// Is it an object selection?
		else if (iexists(currentSelection))
		{
			EditorGlobalSignalObjectDeleted(currentSelection, kEditorSelection_None, true);
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
		
		// If the incoming ent is a prop, we gotta rebuild prop meshes
		if (is_struct(entity)) // assume struct inputs are props
		{
			if (type == kEditorSelection_Prop)
			{
				if (!deferMeshBuilds)
					MapRebuilPropsOnly();
			}
			else if (type == kEditorSelection_Splat)
			{
				if (!deferMeshBuilds)
					MapRebuildSplats();
			}
			else if (type == kEditorSelection_Primitive)
			{
				EditorGlobalMarkDirtyGeometry();
					
				var solid_id = array_get_index(m_state.map.solids, entity);
				assert(solid_id != null);
				if (!deferMeshBuilds)
				{
					MapRebuildSolidsOnly(solid_id);
				}
				else
				{
					m_wantRebuildSolids = true;
					array_push(m_solidUpdateRequestList, solid_id);
				}
			}
		}
		// otherwise, may need to request rebuilding gizmo meshes
		else if (iexists(entity))
		{
			// Update all gizmos
			m_gizmoObject.m_entBillboards.m_dirty = true;
				
			if (!is_undefined(entity.entity.gizmoMesh))
			{
				if (entity.entity.gizmoMesh.shape == kGizmoMeshWireCube)
				{
					if (valueType == kValueTypeScale)
					{
						// Find the renderer & update it
						m_gizmoObject.m_entRenderObjects.RequestUpdate(entity);
					}
				}
				else if (entity.entity.gizmoMesh.shape == kGizmoMeshLightSphere 
					|| entity.entity.gizmoMesh.shape == kGizmoMeshLightCone
					|| entity.entity.gizmoMesh.shape == kGizmoMeshLightRect)
				{
					// Change mesh if the scale changed:
					if (valueType == kValueTypeScale)
					{
						// Find the renderer & update it
						m_gizmoObject.m_entRenderObjects.RequestUpdate(entity);
					}
				}
			}
			
			if (entity.entity.name == "ai_node")
			{
				EditorGlobalMarkDirtyAi();
			}
		}
	}
}

// Called when a selected object changes any non-transform property.
function EditorGlobalSignalPropertyChange(entity, type, property, value, deferMeshBuilds=false)
{
	with (EditorGet())
	{
		// If the incoming ent is a prop, we gotta rebuild prop meshes
		if (is_struct(entity)) // assume struct inputs are props
		{
			if (type == kEditorSelection_Prop)
			{
				if (!deferMeshBuilds)
				{
					// Rebuild props when changing the index
					if (property[0] == "index")
					{
						MapRebuilPropsOnly();
					}
				}
			}
			else if (type == kEditorSelection_Splat)
			{
				if (!deferMeshBuilds)
					MapRebuildSplats();
			}
		}
		// otherwise, may need to request rebuilding gizmo meshes
		else if (iexists(entity))
		{
			// Update all gizmos
			m_gizmoObject.m_entBillboards.m_dirty = true;
			
			if (!is_undefined(entity.entity.gizmoMesh))
			{
				if (entity.entity.gizmoMesh.shape == kGizmoMeshLightSphere 
					|| entity.entity.gizmoMesh.shape == kGizmoMeshLightCone
					|| entity.entity.gizmoMesh.shape == kGizmoMeshLightRect)
				{
					// Change mesh if the light radius or color changed (color is via vertex colors):
					if (property[0] == "range" || property[0] == "color"
						// For spotlights, change if the shape changed at all
						|| property[0] == "inner_angle" || property[0] == "outer_angle")
					{
						// Find the renderer & update it
						m_gizmoObject.m_entRenderObjects.RequestUpdate(entity);
					}
				}
			}
			
			if (entity.entity.name == "ai_node")
			{
				EditorGlobalMarkDirtyAi();
			}
		}
	}
}

function EditorGlobalSignalObjectCreated(entity, type, deferMeshBuilds=false)
{
	if (is_struct(entity))
	{
	}
	else if (iexists(entity))
	{
		EditorGet().m_gizmoObject.m_entBillboards.m_dirty = true;
		
		if (entity.entity.name == "ai_node")
		{
			EditorGlobalMarkDirtyAi();
		}
	}
}

function EditorGlobalSignalObjectDeleted(entity, type, deferMeshBuilds=false)
{
	if (is_struct(entity))
	{
	}
	else if (iexists(entity))
	{
		EditorGet().m_gizmoObject.m_entBillboards.m_dirty = true;
		
		if (entity.entity.name == "ai_node")
		{
			EditorGlobalMarkDirtyAi();
		}
	}
}

function EditorGlobalSignalLoaded(deferMeshBuilds=false)
{
	EditorGet().m_gizmoObject.m_entBillboards.m_dirty = true;
	EditorGet().m_gizmoObject.m_aiMapRender.m_dirty = true;
}

//=============================================================================

function EditorGlobalMarkDirtyGeometry()
{
	with (EditorGet())
	{
		m_state.map.geometry_valid = false;
		m_state.map.ai_valid = false;
		m_state.map.lighting_valid = false;
		
		m_state.cached_solids_bboxes = array_create(0);
	}
}

function EditorGlobalMarkDirtyAi()
{
	with (EditorGet())
	{
		m_state.map.ai_valid = false;
		
		m_gizmoObject.m_aiMapRender.m_dirty = true;
	}
}

function EditorGlobalMarkDirtyLighting()
{
	with (EditorGet())
	{
		m_state.map.lighting_valid = false;
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
	// Patch up all entity required values
	for (var entIndex = 0; entIndex < EditorGet().m_entityInstList.GetEntityCount(); ++entIndex)
	{
		var instance = EditorGet().m_entityInstList.GetEntity(entIndex);
		if (!variable_instance_exists(instance, "entityMapIndex"))
		{
			instance.entityMapIndex = EditorState_GetNextEntityIdentifier();
		}
	}
	
	// Save data
	var filedata = new AMapFiledata();
	
	MapSaveTilemap(filedata, EditorGet().m_tilemap);
	MapSaveProps(filedata, EditorGet().m_propmap);
	MapSaveEntities(filedata, EditorGet().m_entityInstList);
	MapSaveSplats(filedata, EditorGet().m_splatmap);
	MapSaveEditor(filedata, EditorGet().m_state);
	MapSaveAi(filedata, EditorGet().m_aimap);
	MapSaveGeometry(filedata, EditorGet().m_mapgeometry);
	
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
		
		EditorState_UpdateLastEntityIdentifier(); // Update indetifier for new ents.
		// Clear out the other state that needs to be recreated:
		EditorGet().m_state.cached_solids_bboxes = array_create(0);
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
	MapLoadGeometry(filedata, EditorGet().m_mapgeometry);
	
	MapFreeFiledata(filedata);
	delete filedata;
	
	// Setup all callbacks for the entities now.
	EditorEntities_SetupCallbacks();
	// Force everything to update
	EditorGlobalSignalLoaded();
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
	
	// Force everything to update
	EditorGlobalSignalLoaded();
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
		.addTask(method(EditorGet(),
			function() {
				m_gizmoObject.m_aiMapRender.m_dirty = true;
			}))
		 // Run the task with 2ms limits to keep the UI responsive
		.execute(2000);
		
	// Save the task in case we need to cancel
	EditorGet().m_taskRebuildAi = tasker;
}

function EditorGlobalRebuildLights()
{
	// TODO
}

function EditorGlobalCompileGeo()
{
	// TODO
	EditorGet().m_mapgeometry = MapGeo_BuildAll(EditorGet().m_state.map);
	EditorGet().m_state.map.geometry_valid = true;
}