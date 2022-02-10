/// @function AEditorWindowTileBrowser() constructor
/// @desc Entity selection. Draws all available entities for creation.
function AEditorWindowTileBrowser() : AEditorWindow() constructor
{
	m_title = "Tiles";
	
	m_position.x = 20;
	m_position.y = 36;
	
	m_size.x = 200;
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
	static kItemMarginsY = 3 + 8;
	static kDragWidth = 10;
	
	static InitTileListing = function()
	{
		tile_items = [];
		tile_item_group_counts = array_create(4 * 4, 0);
		tile_item_group_name = array_create(4 * 4, "");
		tile_item_group_layoutPos = array_create(4 * 4, null);
		for (var i = 0; i < 16; ++i)
		{
			tile_item_group_layoutPos[i] = {x: 0, y: 0};
		}
		
		// add them in quadrants at a time
		for (var iy = 0; iy < 4; ++iy)
		{
			for (var ix = 0; ix < 4; ++ix)
			{
				for (var it = 0; it < 16; ++it)
				{
					var it_x = it % 4;
					var it_y = int64(it / 4);
					var i = (ix * 4 + it_x) + (it_y + iy * 4) * 16;
					if (i == 0) continue;
			
					if (TileIsValidToPlaceFloor(i) || TileIsValidToPlaceWall(i))
					{
						array_push(tile_items,
						{
							tile: i,
							name: TileGetName(i),
							isLowerWall: TileIsValidToPlaceWall(i),
							isUpperWall: TileIsTopWall(i),
							layoutX: 0,
							layoutY: 0,
						});
						
						tile_item_group_counts[ix + iy * 4] += 1;
						tile_item_group_name[ix + iy * 4] = TileGetGroupName(i);
					}
				}
			}
		}
		
		InitTileLayout();
	}
	static InitTileLayout = function()
	{
		var pen = {x: kItemMarginsX, y: kItemMarginsX};
		
		static GetGroupResetWidth = function(groupIndex)
		{
			if (tile_item_group_counts[groupIndex] <= 4)
			{
				return 2;
			}
			else if (tile_item_group_counts[groupIndex] <= 6)
			{
				return 3;
			}
			else
			{
				return 4;
			}
		}
		
		// Assume that each item is in a quadrant
		var subpen = {x : 0, y: 0};
		var max_x = 0;
		var max_y = 0;
		var current_group = 0;
		var current_group_is_wall = false;
		var current_group_count = 0;
		var group_reset_width = GetGroupResetWidth(0);
		for (var i = 0; i < array_length(tile_items); ++i)
		{
			var tileinfo = tile_items[i];
			var tx = tileinfo.tile % 16;
			var ty = int64(tileinfo.tile / 16);
			var t_group = int64(tx / 4) + int64(ty / 4) * 4;
			
			if (t_group != current_group)
			{
				current_group_count = 0;
				
				// set up for drawing
				subpen.x = 0;
				subpen.y = 0;
			
				// advance the pen & reset max's
				pen.x += max_x + 16;
				if (pen.x >= m_size.x - kItemMarginsX * 2.0 - kDragWidth - max_x - 16)
				{
					pen.x = kItemMarginsX;
					pen.y += max_y + kItemMarginsY + 16;
					max_y = 0;
				}
				max_x = 0;
				
				// update group and drawing
				current_group = t_group;
				current_group_is_wall = tileinfo.isLowerWall || tileinfo.isUpperWall;
				
				// check max widths
				group_reset_width = GetGroupResetWidth(t_group);
			}
			
			// Add the block to the current position
			tileinfo.layoutX = pen.x + subpen.x;
			tileinfo.layoutY = pen.y + subpen.y;
			// save max-drawn positions
			max_x = max(max_x, subpen.x);
			max_y = max(max_y, subpen.y);
			// count number of drawings
			current_group_count++;
			
			// Advance the subpen
			subpen.x += 16;
			// Newline at end of group
			if (subpen.x >= 16 * group_reset_width
				// Newline if halfway through a wall group
				|| (current_group_is_wall && current_group_count == floor(tile_item_group_counts[t_group] / 2)))
			{
				subpen.x = 0;
				subpen.y += 16;
			}
			
			// Update the max position of the group for text
			tile_item_group_layoutPos[t_group].x = pen.x;
			tile_item_group_layoutPos[t_group].y = pen.y + max_y + 16;
		}
		
		drag_max_y = pen.y + max_y + 16 + kItemMarginsY - m_size.y;
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
						tile_items[i].layoutX + 16, tile_items[i].layoutY + 16))
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
	
	static kFocusedBGColor = merge_color(kAccentColor, c_black, 0.75);
	static kUnfocusedBGColor = c_dkgray;
	
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
			
			// draw tile sprite
			draw_sprite_part_ext(stl_lab0, 0,
				(tileinfo.tile % 16) * 16, int64(tileinfo.tile / 16) * 16,
				16, 16,
				l_dx, l_dy,
				1.0, 1.0, c_white, 1.0);
		}
		
		// draw the tile group names
		for (var i = 0; i < 16; ++i)
		{
			if (tile_item_group_name[i] != "")
			{
				var l_dx = m_position.x + tile_item_group_layoutPos[i].x;
				var l_dy = m_position.y + tile_item_group_layoutPos[i].y - drag_y;
			
				draw_set_color(focused ? c_gray : c_black);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				draw_set_font(f_04b03);
				draw_text(l_dx, l_dy, tile_item_group_name[i]);
			}
		}
		
		// draw the selection rect
		if (item_focused != noone)
		{
			var tileinfo = tile_items[item_focused];
			var l_dx = m_position.x + tileinfo.layoutX;
			var l_dy = m_position.y + tileinfo.layoutY - drag_y;
			
			draw_set_color(focused ? kAccentColor : c_white);
			DrawSpriteRectangle(l_dx - 1, l_dy - 1, l_dx + 16 + 1, l_dy + 16 + 1, true);
			
			if (TileIsValidToPlaceWall(tileinfo.tile))
			{
				// Find the position of the accompanying wall
				for (var i = 0; i < array_length(tile_items); ++i)
				{
					if (tile_items[i].tile == tileinfo.tile - 32)
					{
						tileinfo = tile_items[i];
						break;
					}
				}
				var l_dx = m_position.x + tileinfo.layoutX;
				var l_dy = m_position.y + tileinfo.layoutY - drag_y;
				
				draw_set_color(focused ? c_ltgray : c_white);
				DrawSpriteRectangle(l_dx - 1, l_dy - 1, l_dx + 16 + 1, l_dy + 16 + 1, true);
			}
		}
		
		drawShaderUnset(sh_editorDefaultScissor);
	}
}