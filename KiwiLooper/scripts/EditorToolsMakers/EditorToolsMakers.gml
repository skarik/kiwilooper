/// @function AEditorToolStateMakeEntity() constructor
function AEditorToolStateMakeEntity() : AEditorToolState() constructor
{
	state = kEditorToolMakeEntity;
	
	m_hasEntityToMake = false;
	m_entityToMake = ob_3DLight;
	m_entityToMakeIsProxy = false;
	m_gizmo = null;
	m_window = null;
	
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
		
		if (m_window == null)
		{
			m_window = m_editor.EditorWindowAlloc(AEditorWindowEntSpawn);
		}
		m_window.Open();
		m_editor.EditorWindowSetFocus(m_window);
		
		m_editor.m_statusbar.m_toolHelpText = "Click anywhere to place position for new selected entity, or drag from entity list. ESC to reset.";
	}
	onEnd = function(trueEnd)
	{
		if (trueEnd)
		{
			m_gizmo.SetDisabled();
			m_gizmo.SetInvisible();
			
			m_editor.EditorWindowFree(m_window);
			m_window = null;
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
				
				UpdateEntityToMake();
				
				if (!m_entityToMakeIsProxy)
				{
					// MAKE the item at the gizmo position
					var ent = inew(m_entityToMake);
					ent.x = m_gizmo.x;
					ent.y = m_gizmo.y;
					ent.z = m_gizmo.z;
					ent.entity = entlistFindWithObjectIndex(m_entityToMake);
					
					m_editor.m_entityInstList.Add(ent);
				}
				else
				{
					// MAKE the item at the gizmo position
					var ent = inew(m_editor.OProxyClass);
					ent.x = m_gizmo.x;
					ent.y = m_gizmo.y;
					ent.z = m_gizmo.z;
					ent.xscale = 1.0;
					ent.yscale = 1.0;
					ent.zscale = 1.0;
					ent.xrotation = 0.0;
					ent.yrotation = 0.0;
					ent.zrotation = 0.0;
					ent.entity = m_entityToMake;
					
					m_editor.m_entityInstList.Add(ent);
				}
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
	
	static UpdateEntityToMake = function()
	{
		var entity = m_window.GetCurrentEntity();
		
		// Is this a proxy object?
		m_entityToMakeIsProxy = (entity.proxy != kProxyTypeNone);
		
		// If it's not a proxy, just make the object
		if (!m_entityToMakeIsProxy)
		{
			m_entityToMake = entity.objectIndex;
		}
		// If it is a proxy, we just save the ent info for now.
		else
		{
			m_entityToMake = entity;
		}
	};
}

/// @function AEditorToolStateMakeProp() constructor
function AEditorToolStateMakeProp() : AEditorToolState() constructor
{
	state = kEditorToolMakeProp;
	
	m_hasPropToMake = false;
	//m_entityToMake = ob_3DLight;
	//m_entityToMakeIsProxy = false;
	m_gizmo = null;
	m_window = null;
	
	onBegin = function()
	{
		m_gizmo = m_editor.EditorGizmoGet(AEditorGizmoAxesMove);
		if (m_hasPropToMake)
		{
			m_gizmo.SetEnabled();
			m_gizmo.SetVisible();
		}
		else
		{
			m_gizmo.SetDisabled();
			m_gizmo.SetInvisible();
		}
		
		// Set up the prop listing when we enter this state
		if (m_window == null)
		{
			m_window = m_editor.EditorWindowAlloc(AEditorWindowPropSpawn);
		}
		m_window.Open();
		m_window.InitPropListing();
		
		m_editor.EditorWindowSetFocus(m_window);
		
		m_editor.m_statusbar.m_toolHelpText = "Click anywhere to place position for new selected prop, or drag from prop list. ESC to reset.";
	}
	onEnd = function(trueEnd)
	{
		if (trueEnd)
		{
			m_gizmo.SetDisabled();
			m_gizmo.SetInvisible();
			
			m_editor.EditorWindowFree(m_window);
			m_window = null;
		}
	}
	
	onStep = function()
	{
		if (m_hasPropToMake)
		{
			m_gizmo.SetEnabled();
			m_gizmo.SetVisible();
			
			if (keyboard_check_pressed(vk_enter))
			{
				m_hasPropToMake = false;
				
				/*UpdateEntityToMake();
				
				if (!m_entityToMakeIsProxy)
				{
					// MAKE the item at the gizmo position
					var ent = inew(m_entityToMake);
					ent.x = m_gizmo.x;
					ent.y = m_gizmo.y;
					ent.z = m_gizmo.z;
					ent.entity = entlistFindWithObjectIndex(m_entityToMake);
				}
				else
				{
					// MAKE the item at the gizmo position
					var ent = inew(m_editor.OProxyClass);
					ent.x = m_gizmo.x;
					ent.y = m_gizmo.y;
					ent.z = m_gizmo.z;
					ent.xscale = 1.0;
					ent.yscale = 1.0;
					ent.zscale = 1.0;
					ent.xrotation = 0.0;
					ent.yrotation = 0.0;
					ent.zrotation = 0.0;
					ent.entity = m_entityToMake;
				}*/
				
				//
				prop_base = m_window.GetCurrentProp();
				
				var prop = new APropEntry();
					prop.sprite = prop_base;
					prop.x = m_gizmo.x;
					prop.y = m_gizmo.y;
					prop.z = m_gizmo.z;
					
				m_editor.m_propmap.AddProp(prop);
				
				m_editor.MapRebuilPropsOnly();
				
			}
			else if (keyboard_check_pressed(vk_backspace)
				|| keyboard_check_pressed(vk_delete)
				|| keyboard_check_pressed(vk_escape))
			{
				m_hasPropToMake = false;
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
		if (!m_hasPropToMake)
		{
			m_hasPropToMake = true;
			
			// set up initial MAKE position
			m_gizmo.x = worldPosition.x;
			m_gizmo.y = worldPosition.y;
			m_gizmo.z = worldPosition.z;
		}
	};
	
	/*static UpdateEntityToMake = function()
	{
		var entity = m_window.GetCurrentEntity();
		
		// Is this a proxy object?
		m_entityToMakeIsProxy = (entity.proxy != kProxyTypeNone);
		
		// If it's not a proxy, just make the object
		if (!m_entityToMakeIsProxy)
		{
			m_entityToMake = entity.objectIndex;
		}
		// If it is a proxy, we just save the ent info for now.
		else
		{
			m_entityToMake = entity;
		}
	};*/
}