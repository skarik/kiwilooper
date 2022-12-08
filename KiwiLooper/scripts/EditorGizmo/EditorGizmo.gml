function EditorGizmoSetup()
{
	global.m_editorLineEdge_uLineColor = shader_get_uniform(sh_editorLineEdge, "uLineColor");
	global.m_editorLineEdge_uLineSizeAndFade = shader_get_uniform(sh_editorLineEdge, "uLineSizeAndFade");
	
	global.m_editorFlatShaded_uFlatColor = shader_get_uniform(sh_editorFlatShaded, "uFlatColor");
	
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
	
	/// @function EditorGizmoGetAnyConsumingMouse()
	/// @desc Checks if any existing gizmo instance is consuming the mouse.
	EditorGizmoGetAnyConsumingMouse = function()
	{
		for (var instanceIndex = 0; instanceIndex < array_length(m_gizmoInstances); ++instanceIndex)
		{
			if (m_gizmoInstances[instanceIndex][1].GetConsumingMouse())
			{
				return true;
			}
		}
		return false;
	};

	with (m_gizmoObject)
	{
		m_axes = other.EditorGizmoGet(AEditorGizmoAxes);
		m_entBillboards = other.EditorGizmoGet(AEditorGizmoEntityBillboards);
		m_entRenderObjects = other.EditorGizmoGet(AEditorGizmoEntityRenderObjects);
		m_testMouse = other.EditorGizmoGet(AEditorGizmoSelectBox3D);
		m_grid = other.EditorGizmoGet(AEditorGizmoGrid);
		m_grid_global = other.EditorGizmoGet(AEditorGizmoGridGlobal);
		
		m_aiMapRender = other.EditorGizmoGet(AEditorGizmoAiMap);
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
		// Update test mouse position to know working position
		m_testMouse.SetVisible();
		m_testMouse.SetEnabled();
		m_testMouse.m_color = merge_color(c_gray, c_blue, 0.25);
		m_testMouse.m_alpha = 0.5;
		m_testMouse.m_min.set(other.toolWorldX - 1, other.toolWorldY - 1, other.toolWorldZ - 1);
		m_testMouse.m_max.set(other.toolWorldX + 1, other.toolWorldY + 1, other.toolWorldZ + 1); // TODO: Maybe remove this on world or make optional? is personally distracting
		
		// Toggle based on view options
		if (other.m_state.view.showmask & kEditorViewMask_NodeLinks)
		{	// todo: maybe make this per-view (if we ever make this per-view editor lmao)
			m_aiMapRender.SetVisible();
		}
		else
		{
			m_aiMapRender.SetInvisible();
		}
		
		// Grid update:
		
		if (other.toolGrid && !other.toolGridTemporaryDisable)
		{
			// Ensure we only use active translation gizmos with the grid
			var gizmoTranslation = other.EditorGizmoFind(AEditorGizmoPointMove);
			var gizmoTranslation2 = other.EditorGizmoFind(AEditorGizmoAxesMove);
			
			if ((gizmoTranslation != null && gizmoTranslation.GetVisible() && gizmoTranslation.GetEnabled())
				|| (gizmoTranslation2 != null && gizmoTranslation2.GetVisible() && gizmoTranslation2.GetEnabled()))
			{
				m_grid.SetVisible();
				m_grid.SetEnabled();
			
				// Update grid orientation based on the grid options & last collided object
			
				// If we have an object selection, pull their position for the grid basis
				var last_selection = EditorSelectionGetLast();
			
				var bIsStructSelection = is_struct(last_selection);
				var bIsInstanceSelection = !bIsStructSelection && iexists(last_selection);
				
				if ( bIsInstanceSelection
						|| (bIsStructSelection && (last_selection.type == kEditorSelection_Prop || last_selection.type == kEditorSelection_Splat))
					)
				{
					m_grid.x = bIsStructSelection ? last_selection.object.x : last_selection.x;
					m_grid.y = bIsStructSelection ? last_selection.object.y : last_selection.y;
					m_grid.z = bIsStructSelection ? last_selection.object.z : last_selection.z;
				
					// Change the grid rotation based on the active tool
					if (   (gizmoTranslation != null  && (gizmoTranslation.m_mouseOverZ  || gizmoTranslation.m_dragZ))
						|| (gizmoTranslation2 != null && (gizmoTranslation2.m_mouseOverZ || gizmoTranslation2.m_dragZ))
						)
					{
						m_grid.xrotation = (abs(other.viewrayForward[1]) > abs(other.viewrayForward[0])) ? 90 : 0;
						m_grid.yrotation = (abs(other.viewrayForward[0]) > abs(other.viewrayForward[1])) ? 90 : 0;
					}
					else
					{
						m_grid.xrotation = 0;
						m_grid.yrotation = 0;
					}
				}
				// Otherwise, we limit the grid to the world
				else
				{
					if (gizmoTranslation != null)
					{
						m_grid.x = gizmoTranslation.x;
						m_grid.y = gizmoTranslation.y;
						m_grid.z = gizmoTranslation.z;
					}
					else if (gizmoTranslation2 != null)
					{
						m_grid.x = gizmoTranslation2.x;
						m_grid.y = gizmoTranslation2.y;
						m_grid.z = gizmoTranslation2.z;
					}
					else
					{
						m_grid.x = other.toolWorldValid ? other.toolWorldX : other.toolFlatX;
						m_grid.y = other.toolWorldValid ? other.toolWorldY : other.toolFlatY;
						m_grid.z = other.toolWorldValid ? other.toolWorldZ : 0;
					}
				
					m_grid.xrotation = (abs(other.toolWorldNormal.y) > 0.707) ? 90 : 0;
					m_grid.yrotation = (abs(other.toolWorldNormal.x) > 0.707) ? 90 : 0;
				}
			
				m_grid.x = round((m_grid.x + 0.01) / other.toolGridSize) * other.toolGridSize;
				m_grid.y = round((m_grid.y + 0.01) / other.toolGridSize) * other.toolGridSize;
				m_grid.z = round((m_grid.z + 0.01) / other.toolGridSize) * other.toolGridSize;
			
				m_grid.xscale = other.toolGridSize / 16;
				m_grid.yscale = other.toolGridSize / 16;
				m_grid.zscale = other.toolGridSize / 16;
			}
			else
			{
				m_grid.SetInvisible();
				m_grid.SetDisabled();
			}
		}
		else
		{
			m_grid.SetInvisible();
			m_grid.SetDisabled();
		}
		
		// Global grid update:
		
		if (other.toolGridVisible)
		{
			m_grid_global.SetVisible();
			m_grid_global.SetEnabled();
		}
		else
		{
			m_grid_global.SetInvisible();
			m_grid_global.SetDisabled();
		}
	}
	
	// create mouse state to forward
	var l_mouseState = array_create(5, false);
	var l_mouseStateDown = array_create(5, false);
	var l_mouseStateUp = array_create(5, false);
	var l_mouseAvailable = false;
	if (!m_toolbar.ContainsMouse() && !m_actionbar.ContainsMouse() && !m_minimenu.ContainsMouse() && !WindowingContainsMouse())
	{
		var kMouseInputs = [mb_left, mb_right, mb_middle, kMouseWheelUp, kMouseWheelDown];
		for (var i = 0; i < 3; ++i)
		{
			l_mouseState[i] = mouse_check_button(kMouseInputs[i]);
			l_mouseStateDown[i] = mouse_check_button_pressed(kMouseInputs[i]);
			l_mouseStateUp[i] = mouse_check_button_released(kMouseInputs[i]);
		}
		l_mouseState[3] = mouse_wheel_up();
		l_mouseState[4] = mouse_wheel_down();
		
		l_mouseAvailable = true;
	}
	
	// update all active gizmos
	for (var instanceIndex = 0; instanceIndex < array_length(m_gizmoInstances); ++instanceIndex)
	{
		var gizmoInstance = m_gizmoInstances[instanceIndex][1];
		if (gizmoInstance.GetEnabled())
		{
			// Forward mouse state
			array_copy(gizmoInstance._mouse, 0, l_mouseState, 0, 5);
			array_copy(gizmoInstance._mousePressed, 0, l_mouseStateDown, 0, 5);
			array_copy(gizmoInstance._mouseReleased, 0, l_mouseStateUp, 0, 5);
			gizmoInstance._mouseAvailable = l_mouseAvailable;
			
			// Update
			gizmoInstance.Step();
		}
	}
}
