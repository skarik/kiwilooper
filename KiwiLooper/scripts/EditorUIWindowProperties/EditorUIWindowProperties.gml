/// @function AEditorWindowProperties() constructor
/// @desc Entity properties window. Allows for editing properties.
function AEditorWindowProperties() : AEditorWindow() constructor
{
	m_title = "Properties";
	
	entity_instance = null;
	entity_info = null;
	
	property_values = [];
	property_focused = null;
	property_mouseover = null;
	
	m_size.x = 150;
	m_size.y = 180;
	
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
		if (!has_stored_position)
		{
			m_position.x = ent_screenpos[0] + 32;
			m_position.y = ent_screenpos[1] + 32;
		}
		// Begin clamping check:
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
		
		// Since editing everything is based around key-values, we need to generate string values for each entry now.
		for (var iProperty = 0; iProperty < array_length(entity_info.properties); ++iProperty)
		{
			var property = entity_info.properties[iProperty];
			property_values[iProperty] = entpropToString(entity_instance, property);
		}
	} // End InitWithEntityInfo()
	
	static Draw = function()
	{
		drawWindow();
		
		if (!iexists(entity_instance))
		{
			draw_set_color(focused ? c_white : c_ltgray);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(f_04b03);
			
			draw_text(m_position.x + 2, m_position.y + 2, "No selection.");
			return;
		}
		
		static kPropertyHeight = 12;
		static kPropertyColumn = 50;
		static kPropertyMargin = 2;
		
		// Run through all the properties and draw them
		for (var iProperty = 0; iProperty < array_length(entity_info.properties); ++iProperty)
		{
			var property = entity_info.properties[iProperty];
			
			var l_propY = iProperty * kPropertyHeight;
			var l_bgColor = focused ? ((iProperty % 2 == 0) ? c_black : c_dkgray) : c_dkgray;
			
			// draw property background
			draw_set_color(l_bgColor);
			DrawSpriteRectangle(m_position.x, m_position.y + l_propY, m_position.x + m_size.x, m_position.y + l_propY + kPropertyHeight, false);
			
			draw_set_color(focused ? c_white : c_ltgray);
			draw_set_halign(fa_left);
			draw_set_valign(fa_bottom);
			draw_set_font(f_04b03);
			
			// draw the property name:
			var l_textX = m_position.x + kPropertyMargin;
			var l_textY = m_position.y + l_propY + kPropertyHeight - kPropertyMargin;
			
			var l_bSpecialPosition = (property[0] == "") && (property[1] == kValueTypePosition);
			var l_bSpecialRotation = (property[0] == "") && (property[1] == kValueTypeRotation);
			var l_bSpecialScale = (property[0] == "") && (property[1] == kValueTypeScale);
			
			if (l_bSpecialPosition) draw_text(l_textX, l_textY, "(position)");
			else if (l_bSpecialRotation) draw_text(l_textX, l_textY, "(rotation)");
			else if (l_bSpecialScale) draw_text(l_textX, l_textY, "(scale)");
			else
			{
				draw_text(l_textX, l_textY, property[0]);
			}
			
			// draw the property value:
			l_textX = m_position.x + kPropertyColumn + kPropertyMargin;
			
			if (property[1] == kValueTypeColor)
			{
				var color = variable_instance_get(entity_instance, property[0]);
				// Draw the color as background
				draw_set_color(color);
				DrawSpriteRectangle(m_position.x + kPropertyColumn, m_position.y + l_propY, m_position.x + m_size.x, m_position.y + l_propY + kPropertyHeight, false);
				
				// Draw the text for the color values behind
				draw_set_color(color_get_value(color) > 128 ? c_black : c_white);
				draw_text(l_textX, l_textY, property_values[iProperty]);
			}
			else
			{
				// Draw property as normal
				draw_text(l_textX, l_textY, property_values[iProperty]);
			}
			
		}
	}
}