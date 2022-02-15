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
	
	// create mouse state to forward
	var l_mouseState = array_create(5, false);
	var l_mouseStateDown = array_create(5, false);
	var l_mouseStateUp = array_create(5, false);
	var l_mouseAvailable = false;
	if (!m_toolbar.ContainsMouse() && !m_actionbar.ContainsMouse() && !WindowingContainsMouse())
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
