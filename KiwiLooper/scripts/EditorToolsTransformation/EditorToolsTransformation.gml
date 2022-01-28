/// @function AEditorToolStateTranslate() constructor
function AEditorToolStateTranslate() : AEditorToolStateSelect() constructor
{
	state = kEditorToolTranslate;
	
	Parent_onBegin = onBegin;
	Parent_onEnd = onEnd;
	Parent_onStep = onStep;
	Parent_onClickWorld = onClickWorld;
	
	m_transformGizmoConsumingMouse = false;
	m_transformGizmoWasConsumingMouse = false;
	
	onBegin = function()
	{
		Parent_onBegin();
		
		m_transformGizmo = m_editor.EditorGizmoGet(AEditorGizmoPointMove);
		m_transformGizmo.SetInvisible();
		m_transformGizmo.SetDisabled();
	};
	onEnd = function(trueEnd)
	{
		Parent_onEnd(trueEnd);
		if (trueEnd)
		{
			m_transformGizmo.SetInvisible();
			m_transformGizmo.SetDisabled();
		}
	};
	
	onStep = function()
	{
		if (array_length(m_editor.m_selection) > 0)
		{
			// Gather transform target first
			var target = m_editor.m_selection[0];
			if (is_struct(m_editor.m_selection[0]))
			{
				if (m_editor.m_selection[0].type == kEditorSelection_Prop)
				{
					target = m_editor.m_selection[0].object;
				}
			}
			
			// If the gizmo is not set up, then we set up initial gizmo position & reference position.
			if (!m_transformGizmo.m_enabled)
			{
				m_transformGizmo.SetVisible();
				m_transformGizmo.SetEnabled();
		
				m_transformGizmo.x = target.x;
				m_transformGizmo.y = target.y;
				m_transformGizmo.z = target.z;
			}
			// If the gizmo IS set up, then we update the selected objects' positions to the gizmo translation.
			else
			{
				var bSignalChange = 
					target.x != m_transformGizmo.x
					|| target.y != m_transformGizmo.y
					|| target.z != m_transformGizmo.z;
				
				target.x = m_transformGizmo.x;
				target.y = m_transformGizmo.y;
				target.z = m_transformGizmo.z;
				
				if (bSignalChange)
				{
					EditorGlobalSignalTransformChange(target);
				}
			}
		}
		else
		{
			m_transformGizmo.SetInvisible();
			m_transformGizmo.SetDisabled();
		}
		
		m_transformGizmoWasConsumingMouse = m_transformGizmoConsumingMouse;
		m_transformGizmoConsumingMouse = m_transformGizmo.GetConsumingMouse();
		
		// Update like normal click if not using the transform gizmo
		if (!m_transformGizmo.GetEnabled() || !(m_transformGizmoConsumingMouse || m_transformGizmoWasConsumingMouse))
		{
			Parent_onStep();
		}
		// Otherwise, minimally update the picker visuals.
		else
		{
			PickerUpdateVisuals();
		}
	};
	
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
		// Update like normal click if not using the transform gizmo
		if (!m_transformGizmo.GetEnabled() || !(m_transformGizmoConsumingMouse || m_transformGizmoWasConsumingMouse))
		{
			Parent_onClickWorld(button, buttonState, screenPosition, worldPosition);
		}
	};
}

/// @function AEditorToolStateRotate() constructor
function AEditorToolStateRotate() : AEditorToolStateTranslate() constructor
{
	onBegin = function()
	{
		Parent_onBegin();
		
		m_transformGizmo = m_editor.EditorGizmoGet(AEditorGizmoPointRotate);
		m_transformGizmo.SetInvisible();
		m_transformGizmo.SetDisabled();
	};
	
	onStep = function()
	{
		if (array_length(m_editor.m_selection) > 0)
		{
			// Gather transform target first
			var target = m_editor.m_selection[0];
			if (is_struct(m_editor.m_selection[0]))
			{
				if (m_editor.m_selection[0].type == kEditorSelection_Prop)
				{
					target = m_editor.m_selection[0].object;
				}
			}
			var bCanRotate = is_struct(target) ? variable_struct_exists(target, "xrotation") : variable_instance_exists(target, "xrotation");
			
			// Move to the target position [always]
			m_transformGizmo.x = target.x;
			m_transformGizmo.y = target.y;
			m_transformGizmo.z = target.z;
			
			// If the gizmo is not set up, then we set up initial gizmo position & reference position.
			if (!m_transformGizmo.m_enabled)
			{
				m_transformGizmo.SetVisible();
				m_transformGizmo.SetEnabled();
		
				if (bCanRotate)
				{
					m_transformGizmo.xrotation = target.xrotation;
					m_transformGizmo.yrotation = target.yrotation;
					m_transformGizmo.zrotation = target.zrotation;
				}
			}
			// If the gizmo IS set up, then we update the selected objects' positions to the gizmo translation.
			else
			{
				if (bCanRotate)
				{
					var bSignalChange = 
						target.xrotation != m_transformGizmo.xrotation
						|| target.yrotation != m_transformGizmo.yrotation
						|| target.zrotation != m_transformGizmo.zrotation;
				
					target.xrotation = m_transformGizmo.xrotation;
					target.yrotation = m_transformGizmo.yrotation;
					target.zrotation = m_transformGizmo.zrotation;
				
					if (bSignalChange)
					{
						EditorGlobalSignalTransformChange(target);
					}
				}
			}
		}
		else
		{
			m_transformGizmo.SetInvisible();
			m_transformGizmo.SetDisabled();
		}
		
		m_transformGizmoWasConsumingMouse = m_transformGizmoConsumingMouse;
		m_transformGizmoConsumingMouse = m_transformGizmo.GetConsumingMouse();
		
		// Update like normal click if not using the transform gizmo
		if (!m_transformGizmo.GetEnabled() || !(m_transformGizmoConsumingMouse || m_transformGizmoWasConsumingMouse))
		{
			Parent_onStep();
		}
		// Otherwise, minimally update the picker visuals.
		else
		{
			PickerUpdateVisuals();
		}
	};
}