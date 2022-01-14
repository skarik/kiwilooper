/// @function AEditorWindowEntSpawn() constructor
/// @desc Entity selection. Draws all available entities for creation.
function AEditorWindowEntSpawn() : AEditorWindow() constructor
{
	m_title = "Create Entity";
	
	m_position.x = 48;
	m_position.y = 64;
	
	m_size.x = 100;
	m_size.y = 120;
	
	item_focused = 0;
	item_mouseover = null;
	
	static Draw = function()
	{
		drawWindow();
		
		static kLineHeight = 12;
		static kLineMargin = 2;
		
		for (var entIndex = 0; entIndex < entlistIterationLength(); ++entIndex)
		{
			var entinfo = entlistIterationGet(entIndex);
			
			var l_lineY = entIndex * kLineHeight + 1;
			var l_bgColor = focused ? ((entIndex % 2 == 0) ? c_black : c_dkgray) : c_dkgray;
			
			// Highlight the selected item.
			if (item_focused == entIndex)
			{
				l_bgColor = kAccentColor;
			}
			
			// draw property background
			draw_set_color(l_bgColor);
			DrawSpriteRectangle(m_position.x, m_position.y + l_lineY, m_position.x + m_size.x, m_position.y + l_lineY + kLineHeight, false);
			
			// draw property name
			draw_set_color(focused ? c_white : c_ltgray);
			draw_set_halign(fa_left);
			draw_set_valign(fa_bottom);
			draw_set_font(f_04b03);
			draw_text(m_position.x + kLineMargin, m_position.y + l_lineY + kLineHeight - kLineMargin, entinfo.name);
		}
	}
}