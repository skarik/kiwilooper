/// @function AEditorWindowEntSpawn() constructor
/// @desc Entity selection. Draws all available entities for creation.
function AEditorWindowEntSpawn() : AEditorWindow() constructor
{
	m_title = "Create Entity";
	
	m_position.x = 48;
	m_position.y = 64;
	
	m_size.x = 100;
	m_size.y = 80;
	
	item_focused = 0;
	item_mouseover = null;
	item_drag = false;
	
	drag_mouseover = false;
	drag_now = false;
	drag_y = 0;
	drag_y_target = 0;
	
	static ContainsMouse = function()
	{
		return contains_mouse || drag_now;
	}
	
	static sh_uScissorRect = shader_get_uniform(sh_editorDefaultScissor, "uScissorRect");
	static kLineHeight = 12;
	static kLineMargin = 2;
	static kDragWidth = 10;
	
	static onMouseMove = function(mouseX, mouseY)
	{
		if (mouse_position == kWindowMousePositionContent && mouseX < m_position.x + m_size.x - kDragWidth)
		{
			drag_mouseover = false;
			item_mouseover = floor((mouseY - m_position.y - 1 + drag_y) / kLineHeight);
			if (item_mouseover < 0 || item_mouseover >= entlistIterationLength())
				item_mouseover = null;
		}
		else
		{
			item_mouseover = null;
			drag_mouseover = true;
		}
	}
	static onMouseLeave = function(mouseX, mouseY)
	{
		item_mouseover = null;
		drag_mouseover = false;
	}
	static onMouseEvent = function(mouseX, mouseY, button, event)
	{
		if (event == kEditorToolButtonStateMake && mouse_position == kWindowMousePositionContent)
		{
			// If mouse wheel, attempt scroll
			if (button == kEditorButtonWheelUp || button == kEditorButtonWheelDown)
			{
				var kDragMaxY = max(0.0, entlistIterationLength() * kLineHeight - m_size.y);
				drag_y_target += (button == kEditorButtonWheelUp) ? -kLineHeight : kLineHeight;
				drag_y_target = clamp(drag_y_target, 0.0, kDragMaxY);
			}
			// If click the list, then we just change highlight
			else if (item_mouseover != null)
			{
				item_focused = item_mouseover;
				item_drag = true;
			}
			// Otherwise begin dragging the vertical
			else if (drag_mouseover)
			{
				drag_now = true;
			}
		}
		else if (event == kEditorToolButtonStateBreak)
		{
			// Stop all drags
			drag_now = false;
			item_drag = false;
		}
	}
	
	static GetCurrentEntity = function()
	{
		return entlistIterationGet(item_focused);
	}
	
	static Step = function()
	{
		if (drag_now)
		{
			var kDragMaxY = max(0.0, entlistIterationLength() * kLineHeight - m_size.y);
			
			// Move the bar based on the position
			drag_y += (m_editor.vPosition - m_editor.vPositionPrevious);
			drag_y = clamp(drag_y, 0.0, kDragMaxY);
			drag_y_target = drag_y;
		}
		else if (drag_y_target != drag_y)
		{
			var delta = drag_y_target - drag_y;
			drag_y += sign(delta) * min(abs(delta), Time.deltaTime * 200.0);
		}
	}
	
	static Draw = function()
	{
		drawWindow();
		
		// Draw the scroll bar:
		draw_set_color(focused ? c_dkgray : c_gray);
		DrawSpriteRectangle(m_position.x + m_size.x - kDragWidth, m_position.y, m_position.x + m_size.x, m_position.y + m_size.y, true);
		{
			var kDragMaxY = max(0.0, entlistIterationLength() * kLineHeight - m_size.y);
			var kDragSpeed = kDragMaxY / m_size.y;
			var l_barH = 10;
			var l_barY = (m_size.y - 4 - l_barH) * (drag_y / kDragMaxY);
			
			DrawSpriteRectangle(
				m_position.x + m_size.x - kDragWidth + 2,
				m_position.y + 2 + l_barY,
				m_position.x + m_size.x - 2,
				m_position.y + 2 + l_barY + l_barH,
				drag_mouseover ? false : true);
		}
		
		// Draw the selectable items:
		
		drawShaderSet(sh_editorDefaultScissor);
		shader_set_uniform_f(sh_uScissorRect, m_position.x, m_position.y + 1, m_position.x + m_size.x - kDragWidth, m_position.y + m_size.y);
		
		for (var entIndex = 0; entIndex < entlistIterationLength(); ++entIndex)
		{
			var entinfo = entlistIterationGet(entIndex);
			
			var l_lineY = entIndex * kLineHeight + 1 - drag_y;
			var l_bgColor = focused ? ((entIndex % 2 == 0) ? c_black : c_dkgray) : c_dkgray;
			
			// Highlight the selected item.
			if (item_focused == entIndex)
			{
				l_bgColor = kAccentColor;
			}
			if (item_mouseover == entIndex)
			{
				l_bgColor = merge_color(l_bgColor, kAccentColor, 0.25);
			}
			
			// draw property background
			draw_set_color(l_bgColor);
			DrawSpriteRectangle(m_position.x, m_position.y + l_lineY, m_position.x + m_size.x - kDragWidth, m_position.y + l_lineY + kLineHeight, false);
			
			// draw property name
			draw_set_color(focused ? c_white : c_ltgray);
			draw_set_halign(fa_left);
			draw_set_valign(fa_bottom);
			draw_set_font(f_04b03);
			draw_text(m_position.x + kLineMargin, m_position.y + l_lineY + kLineHeight - kLineMargin, entinfo.name);
		}
		
		drawShaderUnset(sh_editorDefaultScissor);
	}
}