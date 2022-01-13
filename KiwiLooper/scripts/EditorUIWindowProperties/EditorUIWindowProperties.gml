/// @function AEditorWindowProperties() constructor
/// @desc Base class for a window.
function AEditorWindowProperties() : AEditorWindow() constructor
{
	m_title = "Properties";
	
	entity_instance = null;
	entity_info = null;
	
	static GetCurrentEntity = function()
	{
		return entity_instance;
	}
	
	static InitWithEntityInfo = function(entityInstance, entityInfo)
	{
		entity_instance = entityInstance;
		entity_info = entityInfo;
		
		// We also want to get the XYZ position of the ent, and put the window somewhere nearby there
		var ent_screenpos = o_Camera3D.positionToView(entity_instance.x, entity_instance.y, entity_instance.z);
		m_position.x = ent_screenpos[0] + 32;
		m_position.y = ent_screenpos[1] + 32;
		{
			var clampPosition = function()
			{
				// Clamp the window position
				m_position.x = round(max(48, min(m_position.x, GameCamera.width - 48 - m_size.x)));
				m_position.y = round(max(48, min(m_position.y, GameCamera.height - 48 - m_size.y)));
			}
			clampPosition();
			
			// If we're covering the ent position, move to other corners and clamp
			if (point_in_rectangle(ent_screenpos[0], ent_screenpos[1], m_position.x, m_position.y, m_position.x + m_size.x, m_position.y + m_size.y))
			{
				m_position.x = ent_screenpos[0] - m_size.x - 32;
				m_position.y = ent_screenpos[1] + 32;
				clampPosition();
				
				if (point_in_rectangle(ent_screenpos[0], ent_screenpos[1], m_position.x, m_position.y, m_position.x + m_size.x, m_position.y + m_size.y))
				{
					m_position.x = ent_screenpos[0] - m_size.x - 32;
					m_position.y = ent_screenpos[1] - m_size.y - 32;
					clampPosition();
					
					if (point_in_rectangle(ent_screenpos[0], ent_screenpos[1], m_position.x, m_position.y, m_position.x + m_size.x, m_position.y + m_size.y))
					{
						m_position.x = ent_screenpos[0] + 32;
						m_position.y = ent_screenpos[1] - m_size.y - 32;
						clampPosition();
					}
				}
			}
		} // End best corner search
	} // End InitWithEntityInfo()
	
	static Draw = function()
	{
		drawWindow();
		
		static kPropertyHeight = 12;
		static kPropertyColumn = 40;
		static kPropertyMargin = 2;
		
		// Run through all the properties and draw them
		for (var iProperty = 0; iProperty < array_length(entity_info.properties); ++iProperty)
		{
			var property = entity_info.properties[iProperty];
			
			var l_propY = iProperty * kPropertyHeight;
			var l_bgColor = focused ? ((iProperty % 2 == 0) ? c_black : c_dkgray) : c_dkgray;
			
			// draw property background
			draw_set_color(l_bgColor);
			DrawSpriteRectangle(m_position.x + 1, m_position.y + l_propY, m_position.x + m_size.x - 1, m_position.y + l_propY + kPropertyHeight, false);
			
			draw_set_color(c_white);
			draw_set_halign(fa_left);
			draw_set_valign(fa_bottom);
			draw_set_font(f_04b03);
			
			// draw the property name
			draw_text(
				m_position.x + 1 + kPropertyMargin,
				m_position.y + l_propY + kPropertyHeight - kPropertyMargin,
				property[0]
				);
				
			// draw the property value
			draw_text(
				m_position.x + kPropertyColumn + kPropertyMargin,
				m_position.y + l_propY + kPropertyHeight - kPropertyMargin,
				string(variable_instance_get(entity_instance, property[0]))
				);
		}
	}
}