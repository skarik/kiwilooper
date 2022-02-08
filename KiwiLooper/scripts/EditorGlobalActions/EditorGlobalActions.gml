function EditorGet()
{
	return instance_find(ot_EditorTest, 0);
}

function EditorGlobalDeleteSelection()
{
	// TODO:
	for (var i = 0; i < array_length(m_selection); ++i)
	{
		var currentSelection = m_selection[i];
		
		// Is it a struct selection?
		if (is_struct(currentSelection))
		{
			switch (currentSelection.type)
			{
			case kEditorSelection_Tile:
				// TODO: Remove the given tile mentioned in XYZ.
				break;
				
			case kEditorSelection_Prop:
				m_propmap.RemoveProp(currentSelection.object);
				delete currentSelection.object;
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
}

function EditorGlobalClearSelection()
{
	m_selection = [];
	m_selectionSingle = false;
}

function EditorGlobalSignalTransformChange(entity)
{
	with (EditorGet())
	{
		// Update all gizmos
		var gizmo;
		gizmo = EditorGizmoFind(AEditorGizmoPointMove);
		if (is_struct(gizmo))
		{
			gizmo.x = entity.x;
			gizmo.y = entity.y;
			gizmo.z = entity.z;
		}
		
		// TODO: fill with the other gizmos
		
		// Find the properties panel and update the transform
		var panel;
		panel = EditorWindowFind(AEditorWindowProperties);
		if (is_struct(panel))
		{
			panel.InitUpdateEntityInfoTransform();
		}
		
		// If the incoming ent is a prop, we gotta rebuild prop meshes
		if (is_struct(entity)) // assume struct inputs are props
		{
			MapRebuilPropsOnly();
		}
	}
}

//=============================================================================

function EditorGlobalSaveMap()
{
	EditorGlobalSaveMap_Work("test.map");
}
function EditorGlobalSaveMap_Work(filepath)
{
	var filedata = new AMapFiledata();
	
	MapSaveTilemap(filedata, EditorGet().m_tilemap);
	MapSaveProps(filedata, EditorGet().m_propmap);
	MapSaveEntities(filedata, EditorGet().m_entityInstList);
	
	MapSaveFiledata(filepath, filedata);
	MapFreeFiledata(filedata);
	
	delete filedata;
}

function EditorGlobalLoadMap()
{
	EditorGlobalNukeMap();
	EditorGlobalLoadMap_Work("test.map");
	
	with (EditorGet())
	{
		MapRebuildGraphics();
	}
}
function EditorGlobalLoadMap_Work(filepath)
{
	var filedata = MapLoadFiledata(filepath);
	
	MapLoadTilemap(filedata, EditorGet().m_tilemap);
	MapLoadProps(filedata, EditorGet().m_propmap);
	MapLoadEntities(filedata, EditorGet().m_entityInstList);
	
	MapFreeFiledata(filedata);
	delete filedata;
}

function EditorGlobalNewMap()
{
}

function EditorGlobalNukeMap()
{
}

// have a layer for the map info

// MapLoadTilemap(filedata, tilemap)
// MapSaveTilemap(filedata, tilemap)