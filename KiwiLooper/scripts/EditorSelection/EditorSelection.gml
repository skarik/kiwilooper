#macro kEditorSelection_None			0
#macro kEditorSelection_Prop			1
#macro kEditorSelection_Tile			2
#macro kEditorSelection_TileFace		3
#macro kEditorSelection_Splat			4
#macro kEditorSelection_Voxel			5 // unused
#macro kEditorSelection_VoxelFace		6 // unused
#macro kEditorSelection_Primitive		7
#macro kEditorSelection_PrimitiveFace	8 // subset of Primitive. Only used in specific cases.
#macro kEditorSelection_PrimitiveEdge	9
#macro kEditorSelection_PrimitiveVertex	10

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
function EditorSelectionWrapPrimitive( mapSolid, faceIndex )
{
	var selection = new AEditorSelection();
	selection.type = kEditorSelection_Primitive;
	selection.object = {
		primitive:	mapSolid,
		face:		faceIndex,
		};
	return selection;
}

function EditorSelectionWrap( ent, type )
{
	switch (type)
	{
	case kEditorSelection_None:			return ent;
	case kEditorSelection_Prop:			return EditorSelectionWrapProp(ent);
	case kEditorSelection_Tile:			return EditorSelectionWrapTile(ent);
	case kEditorSelection_TileFace:		return EditorSelectionWrapTileFace(ent.tile, ent.normal);
	case kEditorSelection_Splat:		return EditorSelectionWrapSplat(ent);
	case kEditorSelection_Primitive:		return EditorSelectionWrapPrimitive(ent.primitive, ent.face);
	case kEditorSelection_PrimitiveFace:	return EditorSelectionWrapPrimitive(ent.primitive, ent.face);
	}
	return null;
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
				if (is_struct(window) && window.GetCurrentEntity() != currentSelection.object.Id())
				{
					window.InitWithProp(currentSelection.object);
					window.Open();
					EditorWindowSavePositions(window);
				}
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
			if (is_struct(window) && window.GetCurrentEntity() != currentSelection)
			{
				window.InitWithEntityInfo(currentSelection, entityInfo);
				window.Open();
				EditorWindowSavePositions(window);
			}
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

/// @function EditorSelectionGetPosition(selection)
/// @param selection {Selection} Editor struct or ent instance
function EditorSelectionGetPosition(selection)
{
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
			else if (selection.type == kEditorSelection_Primitive)
			{
				if (selection.object.face == null)
				{
					return selection.object.primitive.GetBBox().center;
				}
				else
				{
					return selection.object.primitive.GetFaceBBox(selection.object.face).center;
				}
			}
		}
		else if (iexists(selection))
		{
			return Vector3FromTranslation(selection);
		}
	}
	return new Vector3(0, 0, 0);
}

/// @function EditorSelectionGetLastPosition()
function EditorSelectionGetLastPosition()
{
	return EditorSelectionGetPosition(EditorSelectionGetLast());
}

/// @function EditorSelectionGetAveragePosition()
function EditorSelectionGetAveragePosition()
{
	var editor = EditorGet();
	
	var positionAcculm = new Vector3(0, 0, 0);
	if (array_length(editor.m_selection) <= 0)
	{
		return positionAcculm
	}
	else for (var selectionIndex = 0; selectionIndex < array_length(editor.m_selection); ++selectionIndex)
	{
		positionAcculm.addSelf(EditorSelectionGetPosition(editor.m_selection[selectionIndex]));
	}
	return positionAcculm.divide(array_length(editor.m_selection));
}

/// @function EditorSelectionContains(entity_or_array)
function EditorSelectionContains(entity_or_array)
{
	var editor = EditorGet();

	if (!is_array(entity_or_array))
	{
		var entity = entity_or_array;
		return array_contains_pred(editor.m_selection, entity,
			function(array_value, value)
			{
				if (is_struct(array_value))
					return array_value.object == value;
				else
					return array_value == value;
			});
	}
	else
	{
		// TODO
		return false;
	}
}

/// @function EditorSelectionEqual(value1, value2)
function EditorSelectionEqual(value1, value2)
{
	var b1IsStruct = is_struct(value1);
	if (b1IsStruct != is_struct(value2))
	{
		return false;
	}
	else if (b1IsStruct)
	{
		if (value1.type == value2.type
			&& (   (value1.type == kEditorSelection_TileFace && value1.object.tile == value2.object.tile && value1.object.normal.equals(value2.object.normal))
				|| (value1.type == kEditorSelection_Primitive && value1.object.primitive == value2.object.primitive && value1.object.face == value2.object.face)
				|| (value1.object == value2.object)
				)
			)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		return value1 == value2;
	}
}
