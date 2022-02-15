#macro kEditorSelection_None		0
#macro kEditorSelection_Prop		1
#macro kEditorSelection_Tile		2
#macro kEditorSelection_TileFace	3
#macro kEditorSelection_Splat		4

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