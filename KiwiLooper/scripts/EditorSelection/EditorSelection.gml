#macro kEditorSelection_None		0
#macro kEditorSelection_Prop		1
#macro kEditorSelection_Tile		2
#macro kEditorSelection_TileFace	3
#macro kEditorSelection_Splat		4
#macro kEditorSelection_Voxel		5
#macro kEditorSelection_VoxelFace	6

function AEditorSelection() constructor
{
	type	= kEditorSelection_Prop;
	object	= null;
}
function EditorSelectionWrapProp( prop )
{
	var selection = new AEditorSelection();
	selection.type = kEditorSelection_Prop;
	selection.object = prop;
	return selection;
}
function EditorSelectionWrapTile( tile )
{
	var selection = new AEditorSelection();
	selection.type = kEditorSelection_Tile;
	selection.object = tile;
	return selection;
}
function EditorSelectionWrapTileFace( tile, normal )
{
	var selection = new AEditorSelection();
	selection.type = kEditorSelection_TileFace;
	selection.object = {
		tile:		tile,
		normal:		new Vector3(normal.x, normal.y, normal.z),
		};
	return selection;
}
function EditorSelectionWrapSplat( splat )
{
	var selection = new AEditorSelection();
	selection.type = kEditorSelection_Splat;
	selection.object = splat;
	return selection;
}

function EditorSelectionSetup()
{
	m_selection = [];
	m_selectionSingle = true;
}

function EditorSelectionUpdate()
{
	// show window if we have a selection
	static window = null;
	if (array_length(m_selection) > 0)
	{
		var currentSelection = m_selection[0];
		if (is_struct(currentSelection))
		{
			if (currentSelection.type == kEditorSelection_Prop)
			{
				if (!is_struct(window) || window == null)
				{
					window = EditorWindowAlloc(AEditorWindowProperties);
					EditorWindowSetFocus(window);
				}
				if (window.GetCurrentEntity() != currentSelection.object.Id())
					window.InitWithProp(currentSelection.object);
				window.Open();
			}
			else
			{
				EditorWindowFree(window);
				window = null;
			}
		}
		else if (iexists(currentSelection))
		{
			// find in the ent table
			var entityInfo;
			if (currentSelection.object_index != OProxyClass)
			{
				entityInfo = entlistFindWithObjectIndex(currentSelection.object_index);
			}
			else
			{
				entityInfo = currentSelection.entity;
			}
			// todo: set up the window with the given ent info
			
			if (!is_struct(window) || window == null)
			{
				window = EditorWindowAlloc(AEditorWindowProperties);
				EditorWindowSetFocus(window);
			}
			if (window.GetCurrentEntity() != currentSelection)
				window.InitWithEntityInfo(currentSelection, entityInfo);
			window.Open();
		}
		else
		{
			EditorWindowFree(window);
			window = null;
		}
	}
	else
	{
		EditorWindowFree(window);
		window = null;
	}
}

/// @function EditorSelectionGetLast()
/// @desc Returns the last selected object in the current selection group. ``null`` if nothing has been selected.
function EditorSelectionGetLast()
{
	var editor = EditorGet();
	if (array_length(editor.m_selection) > 0)
	{
		return editor.m_selection[array_length(editor.m_selection) - 1];
	}
	return null;
}

/// @function EditorSelectionGetPosition()
function EditorSelectionGetPosition()
{
	// TODO check average position of all objects
	var selection = EditorSelectionGetLast();
	if (selection != null)
	{
		if (is_struct(selection)) 
		{
			if (selection.type == kEditorSelection_Prop || selection.type == kEditorSelection_Splat)
			{
				return Vector3FromTranslation(selection.object);
			}
			else if (selection.type == kEditorSelection_Tile)
			{
				return new Vector3(selection.object.x * 16, selection.object.y * 16, selection.object.height * 16);
			}
			else if (selection.type == kEditorSelection_TileFace)
			{
				return new Vector3(selection.object.tile.x * 16, selection.object.tile.y * 16, selection.object.tile.height * 16);
			}
		}
		else if (iexists(selection))
		{
			return Vector3FromTranslation(selection);
		}
	}
	return new Vector3(0, 0, 0);
}
