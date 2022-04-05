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
					// fill in missing transformation values (even if they're unused)
					variable_instance_set_if_not_exists(ent, "xscale", 1.0);
					variable_instance_set_if_not_exists(ent, "yscale", 1.0);
					variable_instance_set_if_not_exists(ent, "zscale", 1.0);
					variable_instance_set_if_not_exists(ent, "xrotation", 0.0);
					variable_instance_set_if_not_exists(ent, "yrotation", 0.0);
					variable_instance_set_if_not_exists(ent, "zrotation", 0.0);
					// save ent
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
					// save ent
					ent.entity = m_entityToMake;
					
					for (var propIndex = 0; propIndex < array_length(ent.entity.properties); ++propIndex)
					{
						var property = ent.entity.properties[propIndex];
						if (entpropHasDefaultValue(property))
						{
							variable_instance_set(ent, property[0], property[2]);
						}
					}
					
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
}

/// @function AEditorToolStateMakeSplat() constructor
function AEditorToolStateMakeSplat() : AEditorToolState() constructor
{
	state = kEditorToolSplats;
	
	m_hasSplatToMake = false;
	m_gizmo = null;
	m_window = null;
	
	onBegin = function()
	{
		m_gizmo = m_editor.EditorGizmoGet(AEditorGizmoAxesMove);
		if (m_hasSplatToMake)
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
			m_window = m_editor.EditorWindowAlloc(AEditorWindowSplatSpawn);
		}
		m_window.Open();
		m_window.InitSplatListing();
		
		m_editor.EditorWindowSetFocus(m_window);
		
		m_editor.m_statusbar.m_toolHelpText = "Click anywhere to place new splat, or drag from splat list. ESC to reset.";
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
		if (m_hasSplatToMake)
		{
			m_gizmo.SetEnabled();
			m_gizmo.SetVisible();
			
			if (keyboard_check_pressed(vk_enter))
			{
				m_hasSplatToMake = false;
				
				/*prop_base = m_window.GetCurrentProp();
				
				var prop = new APropEntry();
					prop.sprite = prop_base;
					prop.x = m_gizmo.x;
					prop.y = m_gizmo.y;
					prop.z = m_gizmo.z;
					
				m_editor.m_propmap.AddProp(prop);
				
				m_editor.MapRebuilPropsOnly();*/
				
				var splat_sprite = m_window.GetCurrentSprite();
				var splat_index = m_window.GetCurrentIndex();
				
				// create the new shit
				/*var splat = inew(ob_splatter);
					splat.sprite_index = splat_sprite;
					splat.image_index = splat_index;
					splat.x = m_gizmo.x;
					splat.y = m_gizmo.y;
					splat.z = m_gizmo.z;*/
					
				var splat = new ASplatEntry();
					splat.x = m_gizmo.x;
					splat.y = m_gizmo.y;
					splat.z = m_gizmo.z;
					
					splat.xrotation = 0;
					splat.yrotation = 0;
					splat.zrotation = 0;
					
					splat.xscale = 1.0;
					splat.yscale = 1.0;
					splat.zscale = 1.0;
					
					splat.blend = bm_normal;
					splat.color = c_white;
					
					splat.sprite = splat_sprite;
					splat.index = splat_index;
					
				m_editor.m_splatmap.AddSplat(splat);
				
				// TODO: Create splat
				idelete(ob_splatter);
				m_editor.m_splatmap.SpawnSplats();
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
		if (!m_hasSplatToMake)
		{
			m_hasSplatToMake = true;
			
			// set up initial MAKE position
			m_gizmo.x = worldPosition.x;
			m_gizmo.y = worldPosition.y;
			m_gizmo.z = worldPosition.z;
		}
	};
}
