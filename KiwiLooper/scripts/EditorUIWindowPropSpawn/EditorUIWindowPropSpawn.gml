/// @function AEditorWindowPropSpawn() constructor
/// @desc Entity selection. Draws all available entities for creation.
function AEditorWindowPropSpawn() : AEditorWindow() constructor
{
	m_title = "Create Prop";
	
	m_position.x = 48;
	m_position.y = 160;
	
	m_size.x = 120;
	m_size.y = 120;
	
	item_focused = 0;
	item_mouseover = null;
	item_drag = false;
	
	drag_mouseover = false;
	drag_now = false;
	drag_y = 0;
	drag_y_target = 0;
	drag_max_y = 0;
	
	prop_items = [];
	
	static ContainsMouse = function()
	{
		return contains_mouse || drag_now;
	}
	
	static sh_uScissorRect = shader_get_uniform(sh_editorDefaultScissor, "uScissorRect");
	static kLineHeight = 12+18;
	static kLineMargin = 5;
	static kLineLabelHeight = 8;
	static kDragWidth = 10;
	
	static InitPropListing = function()
	{
		//var props = tag_get_asset_ids([], asset_sprite);
		//var props = tag_get_asset_ids("", asset_sprite);
		var props = tag_get_asset_ids("objects", asset_sprite);
		for (var i = 0; i < array_length(props); ++i)
		{
			var propSprite = props[i];
			
			prop_items[i] = {
				name: string_replace(sprite_get_name(propSprite), "spr_", ""),
				sprite: propSprite,
				layoutX: 0,
				layoutY: 0,
			};
		}
		
		// Sort props alphabetically and not chaotically
		array_sort(prop_items, function(a, b) {
				return CE_StringCompare(a.name, b.name);
			});
		
		InitPropLayout();
	}
	static InitPropLayout = function()
	{
		var pen = {x: kLineMargin, y: kLineMargin};
		var advance_height = 0;
		for (var i = 0; i < array_length(prop_items); ++i)
		{
			prop_items[i].layoutX = pen.x;
			prop_items[i].layoutY = pen.y;
			
			advance_height = max(advance_height, sprite_get_height(prop_items[i].sprite));
			
			// Advance the pen
			pen.x += sprite_get_width(prop_items[i].sprite) + kLineMargin;
			if (i < array_length(prop_items) - 1
				&& pen.x > m_size.x - (sprite_get_width(prop_items[i+1].sprite) + kLineMargin) - kDragWidth)
			{
				pen.x = kLineMargin;
				pen.y += advance_height + kLineLabelHeight + kLineMargin;
				advance_height = 0;
			}
		}
		
		drag_max_y = pen.y + advance_height + kLineLabelHeight + kLineMargin - m_size.y;
	}
	
	static GetCurrentProp = function()
	{
		return prop_items[item_focused].sprite;
	}
	
	static onMouseMove = function(mouseX, mouseY)
	{
		if (mouseX < m_position.x + m_size.x - kDragWidth)
		{
			drag_mouseover = false;
				
			var localMouseX = mouseX - m_position.x;
			var localMouseY = mouseY - m_position.y + drag_y;
			for (var i = 0; i < array_length(prop_items); ++i) // TODO: narrow this based on the scroll
			{
				if (point_in_rectangle(localMouseX, localMouseY,
						prop_items[i].layoutX, prop_items[i].layoutY,
						prop_items[i].layoutX + sprite_get_width(prop_items[i].sprite),
						prop_items[i].layoutY + sprite_get_height(prop_items[i].sprite) + kLineLabelHeight)
						)
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
		if (event == kEditorToolButtonStateMake && mouse_position == kWindowMousePositionContent)
		{
			// If mouse wheel, attempt scroll
			if (button == kEditorButtonWheelUp || button == kEditorButtonWheelDown)
			{
				drag_y_target += (button == kEditorButtonWheelUp) ? -kLineHeight : kLineHeight;
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
		
		for (var propIndex = 0; propIndex < array_length(prop_items); ++propIndex)
		{
			var propinfo = prop_items[propIndex];
			
			//var l_lineY = propIndex * kLineHeight + 1 - drag_y;
			var l_dx = m_position.x + propinfo.layoutX;
			var l_dy = m_position.y + propinfo.layoutY - drag_y;
			
			var l_bgColor = focused ? c_black : c_dkgray;
			
			// Highlight the selected item.
			if (item_focused == propIndex)
			{
				l_bgColor = kAccentColor;
			}
			if (item_mouseover == propIndex)
			{
				l_bgColor = merge_color(l_bgColor, kAccentColor, 0.25);
			}
			
			// draw property background
			draw_set_color(l_bgColor);
			DrawSpriteRectangle(l_dx - 1, l_dy - 1, l_dx + sprite_get_width(propinfo.sprite) + 1, l_dy + sprite_get_height(propinfo.sprite) + kLineLabelHeight + 1, false);
			
			// draw property sprite
			/*var propHeight = sprite_get_height(propinfo.sprite);
			var propXOffset = sprite_get_xoffset(propinfo.sprite);
			var propYOffset = sprite_get_yoffset(propinfo.sprite);
			var propScale = min(1.0, kLineHeight / propHeight);
			draw_sprite_ext(propinfo.sprite, 0,
							m_position.x + kLineMargin + propXOffset * propScale,
							m_position.y + l_lineY + propYOffset * propScale,
							propScale, propScale,
							0.0, c_white,
							(item_focused == propIndex || item_mouseover == propIndex) ? 1.0 : 0.75);*/
			draw_sprite_part_ext(propinfo.sprite, 0,
								 0, 0, sprite_get_width(propinfo.sprite), sprite_get_height(propinfo.sprite),
								 l_dx, l_dy,
								 1.0, 1.0, c_white, 1.0);
			
			// draw property name
			draw_set_color((item_focused == propIndex) ? c_white : (focused ? c_gray : merge_color(c_gray, c_dkgray, 0.5)));
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(f_04b03);
			draw_text(l_dx, l_dy + 1 + sprite_get_height(propinfo.sprite), propinfo.name);
		}
		
		drawShaderUnset(sh_editorDefaultScissor);
	}
}