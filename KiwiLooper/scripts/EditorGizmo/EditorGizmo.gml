#macro kEditorSelection_None 0
#macro kEditorSelection_Prop 1
#macro kEditorSelection_Tile 2

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

function EditorGizmoSetup()
{
	global.m_editorLineEdge_uLineColor = shader_get_uniform(sh_editorLineEdge, "uLineColor");
	global.m_editorLineEdge_uLineSizeAndFade = shader_get_uniform(sh_editorLineEdge, "uLineSizeAndFade");
	
	global.m_editorFlatShaded_uFlatColor = shader_get_uniform(sh_editorFlatShaded, "uFlatColor");
	
	m_entList = [
		// type, sprite, index, hullsize
		[ob_3DLight, suie_gizmoEnts, 0, 8],
		[o_ambientOverride, suie_gizmoEnts, 1, 8],
		[o_livelyDoor, suie_gizmoEnts, 5, 8],
		];
	
	m_selection = [];
	m_selectionSingle = true;
	
	m_gizmoObject = inew(ob_3DObject);
	m_gizmoObject.translucent = false;
	m_gizmoObject.lit = false;
	
	m_gizmoInstances = [];
	
	/// @function EditorGizmoGet(factory)
	/// @desc Grabs existing or instantiates the given gizmo object.
	EditorGizmoGet = function(factory)
	{
		for (var instanceIndex = 0; instanceIndex < array_length(m_gizmoInstances); ++instanceIndex)
		{
			if (m_gizmoInstances[instanceIndex][0] == factory)
			{
				m_gizmoInstances[instanceIndex][1].wants_release = false;
				return m_gizmoInstances[instanceIndex][1];
			}
		}
	
		var gizmoInstance = new factory();
		array_push(m_gizmoInstances, [factory, gizmoInstance]);
		return gizmoInstance;
	};
	
	/// @function EditorGizmoFind(factory)
	/// @desc Grabs existing given gizmo object.
	EditorGizmoFind = function(factory)
	{
		for (var instanceIndex = 0; instanceIndex < array_length(m_gizmoInstances); ++instanceIndex)
		{
			if (m_gizmoInstances[instanceIndex][0] == factory)
			{
				return m_gizmoInstances[instanceIndex][1];
			}
		}
		
		return null;
	};
	
	/// @function EditorGizmoRelease(instance)
	/// @desc Marks the given gizmo as unused and ready to release.
	EditorGizmoRelease = function(instance)
	{
		instance.wants_release = true;
	};

	with (m_gizmoObject)
	{
		//m_axes = new AEditorGizmoAxes();
		m_axes = other.EditorGizmoGet(AEditorGizmoAxes);
		//m_select = new AEditorGizmoSelectBox();
		// need a move gizmo (x, y, z)
		//m_mover = new AEditorGizmoPointMove();
		//m_movertest = new AEditorGizmoAxesMove();
		
		m_entRenderers = other.EditorGizmoGet(AEditorGizmoEntityBillboards);
		
		m_testMouse = other.EditorGizmoGet(AEditorGizmoSelectBox3D);
	}
	
	m_gizmoObject.m_renderEvent = function()
	{
		// Draw 3D tools.
		depth = 0;
		
		for (var instanceIndex = 0; instanceIndex < array_length(m_gizmoInstances); ++instanceIndex)
		{
			var gizmoInstance = m_gizmoInstances[instanceIndex][1];
			if (gizmoInstance.m_visible)
			{
				gizmoInstance.Draw();
			}
		}
	}
}

function EditorGizmoUpdate()
{
	with (m_gizmoObject)
	{
		// Nothing right now.
		
		m_testMouse.SetVisible();
		m_testMouse.SetEnabled();
		m_testMouse.m_color = merge_color(c_gray, c_blue, 0.25);
		m_testMouse.m_alpha = 0.5;
		m_testMouse.m_min.set(other.toolWorldX - 4, other.toolWorldY - 4, other.toolWorldZ - 4);
		m_testMouse.m_max.set(other.toolWorldX + 4, other.toolWorldY + 4, other.toolWorldZ + 4);
	}
	
	for (var instanceIndex = 0; instanceIndex < array_length(m_gizmoInstances); ++instanceIndex)
	{
		var gizmoInstance = m_gizmoInstances[instanceIndex][1];
		if (gizmoInstance.GetEnabled())
		{
			gizmoInstance.Step();
		}
	}
	
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