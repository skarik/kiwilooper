/// @function AEditorToolStateMakeEntity() constructor
function AEditorToolStateMakeEntity() : AEditorToolState() constructor
{
	state = kEditorToolMakeEntity;
	
	m_hasEntityToMake = false;
	m_entityToMake = ob_3DLight;
	m_gizmo = null;
	
	onBegin = function()
	{
		m_gizmo = m_editor.EditorGizmoGet(AEditorGizmoAxesMove);
		if (m_hasEntityToMake)
		{
			m_gizmo.SetEnabled();
			m_gizmo.SetVisible();
		}
		else
		{
			m_gizmo.SetDisabled();
			m_gizmo.SetInvisible();
		}
	}
	onEnd = function(trueEnd)
	{
		if (trueEnd)
		{
			m_gizmo.SetDisabled();
			m_gizmo.SetInvisible();
		}
	}
	
	onStep = function()
	{
		if (m_hasEntityToMake)
		{
			m_gizmo.SetEnabled();
			m_gizmo.SetVisible();
			
			if (keyboard_check_pressed(vk_enter))
			{
				m_hasEntityToMake = false;
				
				// MAKE the item at the gizmo position
				var ent = inew(m_entityToMake);
				ent.x = m_gizmo.x;
				ent.y = m_gizmo.y;
				ent.z = m_gizmo.z;
			}
			else if (keyboard_check_pressed(vk_backspace)
				|| keyboard_check_pressed(vk_delete)
				|| keyboard_check_pressed(vk_escape))
			{
				m_hasEntityToMake = false;
			}
		}
		else
		{
			m_gizmo.SetDisabled();
			m_gizmo.SetInvisible();
		}
	};
	
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
		if (!m_hasEntityToMake)
		{
			m_hasEntityToMake = true;
			
			// set up initial MAKE position
			m_gizmo.x = worldPosition.x;
			m_gizmo.y = worldPosition.y;
			m_gizmo.z = worldPosition.z;
		}
	};
}