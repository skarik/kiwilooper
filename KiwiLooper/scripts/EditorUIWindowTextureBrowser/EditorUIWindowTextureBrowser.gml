/// @function AEditorWindowTextureBrowser() constructor
/// @desc Entity selection. Draws all available entities for creation.
function AEditorWindowTextureBrowser() : AEditorWindow() constructor
{
	m_title = "Textures";
	
	m_position.x = 20;
	m_position.y = 36;
	
	m_size.x = 300;
	m_size.y = 300;
	
	last_click_time = 0.0;
	
	item_focused = 0;
	item_mouseover = null;
	item_drag = false;
	item_in_use = null;
	
	
	drag_mouseover = false;
	drag_now = false;
	drag_y = 0;
	drag_y_target = 0;
	drag_max_y = 0;
	
	
	texture_needs_layout = false;
	texture_items = [];
	static ATextureItem = function() constructor
	{
		type = kTextureTypeTexture;
		filename = "";
		displayname = "";
		resource = null;
		index = 1; // Default to 1 for tile-compatibility.
		
		size = {x: 0, y: 0};
		layout = {x: 0, y: 0, visible: true, width: 0};
	};
	
	
	static ContainsMouse = function()
	{
		return contains_mouse || drag_now;
	}
	
	static sh_uScissorRect = shader_get_uniform(sh_editorDefaultScissor, "uScissorRect");
	static kItemMarginsX = 3;
	static kItemMarginsY = 3 + 8;
	static kDragWidth = 10;
	static kDoubleclickTime = 0.4;
	static kDisplayFont = f_04b03;
	
	static InitTextureListing = function()
	{
		// lets go through all the files
		var folders_to_check = [fioLocalPathFindAbsoluteFilepath("tex")];
		var textures = [];
		for (var i = 0; i < array_length(folders_to_check); ++i)
		{
			debugLog(kLogOutput, folders_to_check[i]);
			
			var filename;
			
			// Add all the folders in this folder first
			filename = file_find_first(folders_to_check[i] + "/*", fa_directory);
			while (filename != "")
			{
				array_push(folders_to_check, folders_to_check[i] + filename + "/");
				
				// Go to next item
				filename = file_find_next();
			}
			file_find_close();
			
			// Now run through all the images of the folder
			filename = file_find_first(folders_to_check[i] + "/*.png", 0);
			while (filename != "")
			{
				var found_texture_path = folders_to_check[i] + filename;
				var split_pos = string_pos("tex", found_texture_path);
				var shortened_texture_path = string_copy(found_texture_path, split_pos, string_length(found_texture_path) - split_pos + 1);
				
				debugLog(kLogOutput, "Found texture: " + found_texture_path + " => " + shortened_texture_path);
				
				array_push(textures, shortened_texture_path);
				
				// Go to next item
				filename = file_find_next();
			}
			file_find_close();
		}
		
		// Now create the texture listing using textures[]
		for (var i = 0; i < array_length(textures); ++i)
		{
			var textureItem = new ATextureItem();
			textureItem.filename = textures[i];
			textureItem.displayname = string_copy(textures[i], 5, string_length(textures[i]) - 4 - 4); // -4 for the "tex/", -4 for the ".png"
			textureItem.resource = ResourceLoadTexture(textureItem.filename); // Load the texture now. Who cares, let's fuck up our memory!
			// TODO: loading them now isn't strictly necesary - we could only load the ones that will be in-view.
			textureItem.size.x = sprite_get_width(textureItem.resource.sprite);
			textureItem.size.y = sprite_get_height(textureItem.resource.sprite);
			
			array_push(texture_items, textureItem);
		}
		
		// Add the tiles in quadrants at a time
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
						var textureItem = new ATextureItem();
						textureItem.type = kTextureTypeSpriteTileset;
						textureItem.displayname = "lab0/" + TileGetGroupName(i) + string(it);
						textureItem.resource = ResourceFindSpriteTexture(stl_lab0); 
						if (is_undefined(textureItem.resource))
						{
							// Add texture w/ hard coded UID for this texture
							textureItem.resource = ResourceAddTexture("1stl_lab00", stl_lab0);
						}
						textureItem.index = i;
						textureItem.size.x = 16;
						textureItem.size.y = 16;
						
						array_push(texture_items, textureItem);
					}
				}
			}
		}
		
		// Texture layouts are done at another time.
		texture_needs_layout = true;
	}
	static UpdateTextureLayouts = function()
	{
		// Only update layouts if we need it.
		if (!texture_needs_layout)
		{
			return;
		}
		
		texture_needs_layout = false;
		
		// Set font for string width getting
		draw_set_font(kDisplayFont);
		
		// Use virtual pens
		var pen = {x: kItemMarginsX, y: kItemMarginsX};
		var max_y = 0;
		for (var i = 0; i < array_length(texture_items); ++i)
		{
			var texinfo = texture_items[i];
			
			// Get the width of the item
			var item_width = max(texinfo.size.x, string_width(texinfo.displayname));
			
			// If item isn't visible, skip it and move on.
			if (!texinfo.layout.visible)
			{
				continue;
			}
			
			// Check if we go down a row at end of what we're doing.
			if (pen.x >= m_size.x - kItemMarginsX * 2.0 - kDragWidth - item_width)
			{
				pen.x = kItemMarginsX;
				pen.y += max_y + kItemMarginsY;
				max_y = 0;
			}
			
			// Count the size of the texture so we know how to go down a row
			max_y = max(max_y, texinfo.size.y);
			
			// Save current pen position
			texinfo.layout.x = pen.x;
			texinfo.layout.y = pen.y;
			texinfo.layout.width = item_width;
			
			// Advance the pen
			pen.x += item_width + kItemMarginsX;
			//pen.y += texinfo.size.y + kItemMarginsY; // lmao why did i do this??
		}
		
		drag_max_y = pen.y + max_y + 16 + kItemMarginsY - m_size.y;
	}
	
	static onResize = function()
	{
		// On window resize, redo layout
		texture_needs_layout = true;
	}
	
	
	/// @function GetCurrentTexture()
	static GetCurrentTexture = function()
	{
		return (item_in_use != null) ? texture_items[item_in_use] : texture_items[item_focused];
	}
	
	static _GetTextureItemIndex = function(solidTexture)
	{
		for (var i = 0; i < array_length(texture_items); ++i)
		{
			var texinfo = texture_items[i];
			if (texinfo.type == solidTexture.type
				&& texinfo.index == solidTexture.index // Only meaningful for tilesets, but easy to check
				&& (
					// Check for tilesets if the resources match
					(texinfo.type == kTextureTypeSpriteTileset && texinfo.resource.sprite == solidTexture.source)
					// Check for textures if the paths match
					|| (texinfo.type == kTextureTypeTexture && texinfo.filename == solidTexture.source)
					)
				)
			{
				return i;
			}
		}
		return null;
	}
	
	/// @function SetCurrentTexture(solidTexture)
	static SetCurrentTexture = function(solidTexture)
	{
		item_focused = _GetTextureItemIndex(solidTexture);
	}
	/// @function SetUsedTexture(solidTexture)
	static SetUsedTexture = function(solidTexture)
	{
		item_in_use = _GetTextureItemIndex(solidTexture);
	}
	
	
	static onMouseMove = function(mouseX, mouseY)
	{
		if (mouseX < m_position.x + m_size.x - kDragWidth)
		{
			drag_mouseover = false;
			item_mouseover = null;
			
			var localMouseX = mouseX - m_position.x;
			var localMouseY = mouseY - m_position.y + drag_y;
			for (var i = 0; i < array_length(texture_items); ++i) // TODO: narrow this based on the scroll
			{
				if (texture_items[i].layout.visible
					&& point_in_rectangle(localMouseX, localMouseY,
						texture_items[i].layout.x, texture_items[i].layout.y,
						texture_items[i].layout.x + texture_items[i].size.x, texture_items[i].layout.y + texture_items[i].size.y))
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
			if (button == mb_left)
			{
				if (Time.time - last_click_time < kDoubleclickTime)
				{
					onMouseDoubleclick();
				}
				last_click_time = Time.time;
			}
			
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
	static onMouseDoubleclick = function()
	{
		// Update in-use texture
		item_in_use = item_focused;
		
		// Update editor texture
		var texinfo = texture_items[item_in_use];
		if (texinfo.type == kTextureTypeTexture)
		{
			m_editor.toolTextureInfo.source = texinfo.filename;
		}
		else
		{
			m_editor.toolTextureInfo.source = texinfo.resource.sprite;
		}
		m_editor.toolTextureInfo.type = texinfo.type;
		m_editor.toolTextureInfo.index = texinfo.index;
		
		// Apply the texture
		var tool = EditorToolGetInstance(kEditorToolTextureSolids);
		if (is_struct(tool))
		{
			tool.TextureApplyToSelection();
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
		
		// Update the texture layouts!
		UpdateTextureLayouts();
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
		
		// draw textures
		for (var i = 0; i < array_length(texture_items); ++i)
		{
			var texinfo = texture_items[i];
			
			var l_bgColor = focused ? c_black : c_dkgray;
			
			var l_dx = m_position.x + texinfo.layout.x;
			var l_dy = m_position.y + texinfo.layout.y - drag_y;
			
			// Highlight the selected item.
			if (item_focused == i)
			{
				l_bgColor = kAccentColor;
			}
			if (item_mouseover == i)
			{
				l_bgColor = merge_color(l_bgColor, kAccentColor, 0.25);
			}
			
			// draw texture
			if (texinfo.type == kTextureTypeSpriteTileset)
			{
				draw_sprite_part_ext(
					texinfo.resource.sprite, 0,
					(texinfo.index % 16) * 16, int64(texinfo.index / 16) * 16,
					16, 16,
					l_dx, l_dy,
					1.0, 1.0, c_white, 1.0);
			}
			else
			{
				draw_sprite(texinfo.resource.sprite, 0, l_dx, l_dy);
			}
		}
		
		// draw texture name
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(kDisplayFont);
		for (var i = 0; i < array_length(texture_items); ++i)
		{
			var texinfo = texture_items[i];
			
			var l_dx = m_position.x + texinfo.layout.x;
			var l_dy = m_position.y + texinfo.layout.y + texinfo.size.y - drag_y;
			
			draw_set_color(focused ? c_gray : c_black);
			draw_text(l_dx, l_dy, texinfo.displayname);
		}
		
		static DrawFocusRectangle = function(item_index, main_color, sub_color, offset)
		{
			if (item_index != noone && item_index < array_length(texture_items))
			{
				var texinfo = texture_items[item_index];
				var l_dx = m_position.x + texinfo.layout.x;
				var l_dy = m_position.y + texinfo.layout.y - drag_y;
			
				draw_set_color(main_color);
				draw_set_alpha(1.0);
				DrawSpriteRectangle(l_dx - offset, l_dy - offset, l_dx + texinfo.layout.width + offset, l_dy + texinfo.size.y + 6 + offset, true);
				if (offset >= 2)
				{
					draw_set_color(c_black);
					DrawSpriteRectangle(l_dx - offset - 1, l_dy - offset - 1, l_dx + texinfo.layout.width + offset + 1, l_dy + texinfo.size.y + 6 + offset + 1, true);
				}
			}
		}
		
		// draw the selection rect
		DrawFocusRectangle(item_in_use, merge_color(kAccentColor, c_gray, 0.5), c_gray, 1);
		DrawFocusRectangle(item_focused, merge_color(kAccentColor, c_white, 1.0), kAccentColor, 2);
		
		draw_set_alpha(1.0);
		
		drawShaderUnset(sh_editorDefaultScissor);
	}
}