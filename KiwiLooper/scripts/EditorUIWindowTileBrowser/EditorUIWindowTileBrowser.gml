/// @function AEditorWindowTileBrowser() constructor
/// @desc Entity selection. Draws all available entities for creation.
function AEditorWindowTileBrowser() : AEditorWindow() constructor
{
	m_title = "Tiles";
	
	m_position.x = 20;
	m_position.y = 36;
	
	m_size.x = 180;
	m_size.y = 90;
	
	item_focused = 0;
	item_mouseover = null;
	item_drag = false;
	
	drag_mouseover = false;
	drag_now = false;
	drag_y = 0;
	drag_y_target = 0;
	drag_max_y = 0;
	
	tile_items = [];
	
	static ContainsMouse = function()
	{
		return contains_mouse || drag_now;
	}
	
	static sh_uScissorRect = shader_get_uniform(sh_editorDefaultScissor, "uScissorRect");
	static kItemMarginsX = 3;
	static kItemMarginsY = 4 + 8;
	static kItemPaddingX = 7;
	static kDragWidth = 10;
	
	static InitTileListing = function()
	{
		tile_items = [];
		for (var i = 1; i < 16 * 16; ++i)
		{
			if (TileIsValidToPlace(i))
			{
				array_push(tile_items,
				{
					tile: i,
					name: TileGetName(i),
					layoutX: 0,
					layoutY: 0,
				});
			}
		}
		
		InitTileLayout();
	}
	static InitTileLayout = function()
	{
		var pen = {x: kItemMarginsX, y: kItemMarginsX};
		for (var i = 0; i < array_length(tile_items); ++i)
		{
			tile_items[i].layoutX = pen.x;
			tile_items[i].layoutY = pen.y;
			
			// Advance the pen
			pen.x += 16 + kItemPaddingX;
			if (pen.x > m_size.x - (16 + kItemMarginsX))
			{
				pen.x = kItemMarginsX;
				pen.y += 16 + kItemMarginsY;
			}
		}
		
		drag_max_y = pen.y + 16 + kItemMarginsY - m_size.y;
	}
	
	static GetCurrentTile = function()
	{
		return tile_items[item_focused].tile;
	}
	static SetCurrentTile = function(inputTile)
	{
		for (var i = 0; i < array_length(tile_items); ++i)
		{
			if (tile_items[i].tile == inputTile)
			{
				item_focused = i;
			}
		}
	}
	
	static onMouseMove = function(mouseX, mouseY)
	{
		if (mouseX < m_position.x + m_size.x - kDragWidth)
		{
			drag_mouseover = false;
			item_mouseover = null;
			
			var localMouseX = mouseX - m_position.x;
			var localMouseY = mouseY - m_position.y + drag_y;
			for (var i = 0; i < array_length(tile_items); ++i) // TODO: narrow this based on the scroll
			{
				if (point_in_rectangle(localMouseX, localMouseY,
						tile_items[i].layoutX, tile_items[i].layoutY,
						tile_items[i].layoutX + 16, tile_items[i].layoutY + 16 + 8))
				{
					item_mouseover = i;
					break;
				}
			}
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
		if (event == kEditorToolButtonStateMake)
		{
			// If mouse wheel, attempt scroll
			if (button == kEditorButtonWheelUp || button == kEditorButtonWheelDown)
			{
				drag_y_target += (button == kEditorButtonWheelUp) ? -16 : 16;
				drag_y_target = clamp(drag_y_target, 0.0, drag_max_y);
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
	
	static Step = function()
	{
		if (drag_now)
		{
			// Move the bar based on the position
			drag_y += (m_editor.vPosition - m_editor.vPositionPrevious) * (drag_max_y / m_size.y);
			drag_y = clamp(drag_y, 0.0, drag_max_y);
			drag_y_target = drag_y;
		}
		else if (drag_y_target != drag_y)
		{
			var delta = drag_y_target - drag_y;
			drag_y += sign(delta) * min(abs(delta), Time.deltaTime * 500.0);
		}
	}
	
	static Draw = function()
	{
		drawWindow();
		
		// Draw the scroll bar:
		draw_set_color(focused ? c_dkgray : c_gray);
		DrawSpriteRectangle(m_position.x + m_size.x - kDragWidth, m_position.y, m_position.x + m_size.x, m_position.y + m_size.y, true);
		{
			var l_barH = 10;
			var l_barY = (m_size.y - 4 - l_barH) * (drag_y / drag_max_y);
			
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
		
		for (var i = 0; i < array_length(tile_items); ++i) // TODO: narrow this based on the scroll
		{
			var tileinfo = tile_items[i];
			
			var l_bgColor = focused ? c_black : c_dkgray;
			
			var l_dx = m_position.x + tileinfo.layoutX;
			var l_dy = m_position.y + tileinfo.layoutY - drag_y;
			
			// Highlight the selected item.
			if (item_focused == i)
			{
				l_bgColor = kAccentColor;
			}
			if (item_mouseover == i)
			{
				l_bgColor = merge_color(l_bgColor, kAccentColor, 0.25);
			}
			
			// draw property background
			draw_set_color(l_bgColor);
			DrawSpriteRectangle(l_dx - 1, l_dy - 1, l_dx + 16 + 1, l_dy + 16 + 8 + 1, false);
			
			// draw tile sprite
			draw_sprite_part_ext(stl_lab0, 0,
				(tileinfo.tile % 16) * 16, int64(tileinfo.tile / 16) * 16,
				16, 16,
				l_dx, l_dy,
				1.0, 1.0, c_white, 1.0);
				
			// draw tile name
			draw_set_color(focused ? c_dkgray : c_dkgray);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(f_04b03);
			draw_text(l_dx, l_dy + 16, tileinfo.name);
		}
		
		drawShaderUnset(sh_editorDefaultScissor);
	}
}