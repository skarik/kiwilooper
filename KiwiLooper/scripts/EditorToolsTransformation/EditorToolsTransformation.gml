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
		m_transformGizmo.m_visible = false;
		m_transformGizmo.m_enabled = false;
	};
	onEnd = function(trueEnd)
	{
		Parent_onEnd(trueEnd);
		if (trueEnd)
		{
			m_transformGizmo.m_visible = false;
			m_transformGizmo.m_enabled = false;
		}
	};
	
	onStep = function()
	{
		if (array_length(m_editor.m_selection) > 0)
		{
			// If the gizmo is not set up, then we set up initial gizmo position & reference position.
			if (!m_transformGizmo.m_enabled)
			{
				m_transformGizmo.m_visible = true;
				m_transformGizmo.m_enabled = true;
				
				m_transformGizmo.x = m_editor.m_selection[0].x;
				m_transformGizmo.y = m_editor.m_selection[0].y;
				m_transformGizmo.z = m_editor.m_selection[0].z;
			}
			// If the gizmo IS set up, then we update the selected objects' positions to the gizmo translation.
			else
			{
				m_editor.m_selection[0].x = m_transformGizmo.x;
				m_editor.m_selection[0].y = m_transformGizmo.y;
				m_editor.m_selection[0].z = m_transformGizmo.z;
			}
		}
		else
		{
			m_transformGizmo.m_visible = false;
			m_transformGizmo.m_enabled = false;
		}
		
		m_transformGizmoWasConsumingMouse = m_transformGizmoConsumingMouse;
		m_transformGizmoConsumingMouse = m_transformGizmo.GetConsumingMouse();
		
		// Update like normal click if not using the transform gizmo
		if (!m_transformGizmo.m_enabled || !(m_transformGizmoConsumingMouse || m_transformGizmoWasConsumingMouse))
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
		if (!m_transformGizmo.m_enabled || !(m_transformGizmoConsumingMouse || m_transformGizmoWasConsumingMouse))
		{
			Parent_onClickWorld(button, buttonState, screenPosition, worldPosition);
		}
	};
}