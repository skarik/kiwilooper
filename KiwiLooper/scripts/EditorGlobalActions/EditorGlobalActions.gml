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
			case kEditorObjectTypeTile:
				// TODO: Remove the given tile mentioned in XYZ.
				break;
			}
		}
		// Is it an object selection?
		else if (iexists(currentSelection))
		{
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
	with (ot_EditorTest)
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

function EditorGlobalSaveMap()
{
}

function EditorGlobalLoadMap()
{
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