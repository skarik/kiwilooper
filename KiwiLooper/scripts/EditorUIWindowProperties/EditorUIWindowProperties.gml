/// @function AEditorWindowProperties() constructor
/// @desc Entity properties window. Allows for editing properties.
function AEditorWindowProperties() : AEditorWindow() constructor
{
	m_title = "Properties";
	
	entity_instance = null;
	entity_info = null;
	
	prop_instance = null;
	
	editing_target = kEditorSelection_None;
	
	property_values = [];
	property_focused = null;
	property_mouseover = null;
	property_drag = false;
	property_editing = false;
	property_old_value = undefined;
	property_change_ok = false;
	property_edit_cursor = null;
	
	drag_mouseover = false;
	drag_now = false;
	drag_y = 0;
	drag_y_target = 0;
	
	m_size.x = 150;
	m_size.y = 180;
	
	static sh_uScissorRect = shader_get_uniform(sh_editorDefaultScissor, "uScissorRect");
	static kPropertyHeight = 12;
	static kPropertyColumn = 75;
	static kPropertyMargin = 2;
	static kDragWidth = 10;
	
	static ContainsMouse = function()
	{
		return contains_mouse || drag_now;
	}
	static ConsumesFocus = function()
	{
		return focused && property_editing;
	}
	
	static GetCurrentEntity = function()
	{
		return entity_instance;
	}
	
	static InitWithEntityInfo = function(entityInstance, entityInfo)
	{
		// Stop editing:
		if (GetCurrentEntity() != entityInstance || editing_target != kEditorSelection_None)
		{
			if (property_editing)
			{
				PropertyChangeEnd();
			}
			// TODO: Reset the focused/mouseover if the keyvalue doesnt match
		}
		
		entity_instance	= entityInstance;
		entity_info		= entityInfo;
		editing_target	= kEditorSelection_None;
		
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
		
		// Update the title now
		m_title = entityInfo.name + " Properties";
	} // End InitWithEntityInfo()
	
	static InitUpdateEntityInfoTransform = function()
	{
		var instance = entity_instance;
		if (editing_target == kEditorSelection_Prop)
			instance = prop_instance;
		
		// Update the key-values for the special props
		for (var iProperty = 0; iProperty < array_length(entity_info.properties); ++iProperty)
		{
			var property = entity_info.properties[iProperty];
			
			// Skip properties currently being edited
			if (iProperty == property_focused && property_editing && focused)
				continue;
			
			if (entpropIsSpecialTransform(property))
			{
				property_values[iProperty] = entpropToString(instance, property);
			}
		}
	}
	
	static InitWithProp = function(prop)
	{
		// Stop editing:
		if (GetCurrentEntity() != prop.Id() || editing_target != kEditorSelection_Prop)
		{
			if (property_editing)
			{
				PropertyChangeEnd();
			}
			// TODO: Reset the focused/mouseover if the keyvalue doesnt match
		}
		
		entity_instance	= prop.Id();
		entity_info		= null;
		prop_instance	= prop;
		editing_target	= kEditorSelection_Prop;
		
		entity_info		= {
			properties: [
				["", kValueTypePosition],
				["", kValueTypeRotation],
				["", kValueTypeScale],
				["index", kValueTypeInteger],
			],
		};
		
		InitUpdateEntityInfoTransform();
		property_values[3] = entpropToString(prop, entity_info.properties[3]);
		
		// Update the title now
		m_title = string_replace(sprite_get_name(prop.sprite), "spr_", "") + " Prop-erties";
	}
	
	static onMouseMove = function(mouseX, mouseY)
	{
		if (mouse_position == kWindowMousePositionContent && mouseX < m_position.x + m_size.x - kDragWidth)
		{
			drag_mouseover = false;
			property_mouseover = floor((mouseY - m_position.y - 1 + drag_y) / kPropertyHeight);
			if (property_mouseover < 0 || property_mouseover >= array_length(entity_info.properties))
				property_mouseover = null;
		}
		else
		{
			property_mouseover = null;
			drag_mouseover = true;
		}
	}
	static onMouseLeave = function(mouseX, mouseY)
	{
		property_mouseover = null;
		drag_mouseover = false;
	}
	static onMouseEvent = function(mouseX, mouseY, button, event)
	{
		if (event == kEditorToolButtonStateMake && mouse_position == kWindowMousePositionContent)
		{
			// If mouse wheel, attempt scroll
			if (button == kEditorButtonWheelUp || button == kEditorButtonWheelDown)
			{
				var kDragMaxY = max(0.0, array_length(entity_info.properties) * kPropertyHeight - m_size.y);
				drag_y_target += (button == kEditorButtonWheelUp) ? -kPropertyHeight : kPropertyHeight;
				drag_y_target = clamp(drag_y_target, 0.0, kDragMaxY);
			}
			// If click the list, then we just change highlight
			else if (property_mouseover != null)
			{
				// Commit change selection if we're busy
				if (property_editing && property_focused != property_mouseover)
				{
					PropertyChangeEnd();
				}
				
				property_focused = property_mouseover;
				property_drag = true;
				
				// Commit or update if changing editing otherwise
				if (mouseX > m_position.x + kPropertyColumn)
				{
					if (!property_editing)
					{
						PropertyChangeBegin();
					}
					
					if (property_editing && property_focused != null)
					{
						// Start with cursor at the end
						property_edit_cursor =  string_length(property_values[property_focused]);
						
						// Update the mouse click position
						draw_set_font(f_04b03);
						var deltaX = mouseX - (m_position.x + kPropertyColumn + kPropertyMargin - string_width("W") * 0.5);
						for (var iLength = 1; iLength <= string_length(property_values[property_focused]); ++iLength)
						{
							if (string_width(string_copy(property_values[property_focused], 1, iLength)) > deltaX)
							{
								property_edit_cursor = iLength - 1;
								break;
							}
						}
						
						// Clamp to length
						property_edit_cursor = clamp(property_edit_cursor, 0, string_length(property_values[property_focused]));
					}
				}
				else
				{
					if (property_editing)
					{
						PropertyChangeEnd();
					}
				}
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
			property_drag = false;
		}
	}
	
	static Step = function()
	{
		if (drag_now)
		{
			var kDragMaxY = max(0.0, array_length(entity_info.properties) * kPropertyHeight - m_size.y);
			
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
		
		// Tab through all the editable values
		if (focused && keyboard_check_pressed(vk_tab))
		{
			if (property_focused == null)
			{
				property_focused = 0;
				PropertyChangeBegin();
			}
			else
			{
				if (property_editing)
				{
					PropertyChangeEnd();
				}
				property_focused = (property_focused + 1) % array_length(entity_info.properties);
				PropertyChangeBegin();
			}
		}
		
		// If editing the property, pull input
		if (property_editing)
		{
			// If press enter, or out of focus, commit the change and finish
			if (keyboard_check_pressed(vk_enter) || !focused)
			{
				PropertyChangeEnd();
			}
			// If press escape, cancel the change and finish
			else if (keyboard_check_pressed(vk_escape))
			{
				PropertyChangeCancelEnd();
			}
			else
			{
				var instance = entity_instance;
				var instance_type = kEditorSelection_None;
				if (editing_target == kEditorSelection_Prop)
				{
					instance = prop_instance;
					instance_type = kEditorSelection_Prop;
				}
				
				var property = entity_info.properties[property_focused];
				var value = property_values[property_focused];
				
				// Move the edit cursor
				if (property_edit_cursor == null)
				{
					property_edit_cursor = string_length(value);
				}
				if (keyboard_check_pressed(vk_left))
				{
					property_edit_cursor = max(0, property_edit_cursor - 1);
				}
				else if (keyboard_check_pressed(vk_right))
				{
					property_edit_cursor = min(string_length(value), property_edit_cursor + 1);
				}
				
				// Perform typing controls
				var l_valueCursor = inputPollTyping(value, property_edit_cursor);
				value = l_valueCursor.value;
				property_edit_cursor = l_valueCursor.cursor;
				
				// Check the result of typing:
				property_values[property_focused] = value;
				property_change_ok = entpropSetFromString(instance, property, property_values[property_focused]);
				
				// Update the transform for other objects.
				if (entpropIsSpecialTransform(property))
				{
					EditorGlobalSignalTransformChange(instance, instance_type);
				}
			}
		}
	}
	
	static PropertyChangeBegin = function()
	{
		assert(property_editing == false);
		if (property_focused != null)
		{
			property_old_value = property_values[property_focused];
			property_editing = true;
		}
	}
	static PropertyChangeEnd = function()
	{
		if (property_focused != null)
		{
			var instance = entity_instance;
			if (editing_target == kEditorSelection_Prop)
				instance = prop_instance;
			
			// Attempt to set input
			var property = entity_info.properties[property_focused];
			var valid = entpropSetFromString(instance, property, property_values[property_focused]);
			
			// Reset if invalid input
			if (!valid)
			{
				entpropSetFromString(instance, property, property_old_value);
				property_values[property_focused] = property_old_value;
			}
			else
			{
				property_values[property_focused] = entpropToString(instance, property);
			}
		}
		property_editing = false;
		property_edit_cursor = null;
	}
	static PropertyChangeCancelEnd = function()
	{
		if (property_focused != null)
		{
			var instance = entity_instance;
			if (editing_target == kEditorSelection_Prop)
				instance = prop_instance;
			
			// Set the old property value
			var property = entity_info.properties[property_focused];
			entpropSetFromString(instance, property, property_old_value);
			property_values[property_focused] = property_old_value;
		}
		property_editing = false;
	}
	
	static Draw = function()
	{
		drawWindow();
		
		if (editing_target == kEditorSelection_Prop)
		{
			draw_set_color(focused ? c_white : c_ltgray);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(f_04b03);
			
			draw_text(m_position.x + 2, m_position.y + 2, "Prop Keyvalues not yet set.");
			//return;
		}
		else if (!iexists(entity_instance))
		{
			draw_set_color(focused ? c_white : c_ltgray);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(f_04b03);
			
			draw_text(m_position.x + 2, m_position.y + 2, "No selection.");
			return;
		}
		
		// Draw the scroll bar:
		draw_set_color(focused ? c_dkgray : c_gray);
		DrawSpriteRectangle(m_position.x + m_size.x - kDragWidth, m_position.y, m_position.x + m_size.x, m_position.y + m_size.y, true);
		{
			var kDragMaxY = max(0.0, array_length(entity_info.properties) * kPropertyHeight - m_size.y);
			var l_barH = 10;
			var l_barY = (m_size.y - 4 - l_barH) * (drag_y / kDragMaxY);
			
			DrawSpriteRectangle(
				m_position.x + m_size.x - kDragWidth + 2,
				m_position.y + 2 + l_barY,
				m_position.x + m_size.x - 2,
				m_position.y + 2 + l_barY + l_barH,
				drag_mouseover ? false : true);
		}
		
		// Draw the properties:
		drawShaderSet(sh_editorDefaultScissor);
		shader_set_uniform_f(sh_uScissorRect, m_position.x, m_position.y + 1, m_position.x + m_size.x - kDragWidth, m_position.y + m_size.y);
		
		// Run through all the properties and draw them
		for (var iProperty = 0; iProperty < array_length(entity_info.properties); ++iProperty)
		{
			var property = entity_info.properties[iProperty];
			
			var l_propY = iProperty * kPropertyHeight + 1 - drag_y;
			var l_bgColor = focused ? ((iProperty % 2 == 0) ? c_black : c_dkgray) : c_dkgray;
			
			if (iProperty == property_mouseover)
			{
				l_bgColor = merge_color(l_bgColor, kAccentColor, 0.25);
			}
			
			// draw property background
			draw_set_color(l_bgColor);
			DrawSpriteRectangle(m_position.x, m_position.y + l_propY, m_position.x + m_size.x, m_position.y + l_propY + kPropertyHeight, false);
			// draw property focus outline
			if (iProperty == property_focused)
			{
				// If we're editing, also draw a brighter background
				draw_set_color(focused ? kAccentColor : c_gray);
				DrawSpriteRectangle(m_position.x + kPropertyColumn, m_position.y + l_propY, m_position.x + m_size.x, m_position.y + l_propY + kPropertyHeight, false);
				
				if (!property_change_ok)
				{
					var prev_repeat = gpu_get_tex_repeat();
					
					// Draw scrolling background for "in progress"
					var uvs = sprite_get_uvs(suie_textures16, 0);
					static UvBiasX = function(uvs, in_x) { return in_x / 16; }
					static UvBiasY = function(uvs, in_y) { return in_y / 16; }
					
					var color = c_black;
					var alpha = 1.0;
					
					gpu_set_tex_repeat(true);
					draw_primitive_begin_texture(pr_trianglestrip, sprite_get_texture(suie_textures16, 0));
						draw_vertex_texture_color(m_position.x + kPropertyColumn, m_position.y + l_propY,
							UvBiasX(uvs, (Time.time * -8 % 8) + 0), UvBiasY(uvs, 0),
							color, alpha);
						draw_vertex_texture_color(m_position.x + kPropertyColumn, m_position.y + l_propY + kPropertyHeight,
							UvBiasX(uvs, (Time.time * -8 % 8) + 0), UvBiasY(uvs, kPropertyHeight),
							color, alpha);
						draw_vertex_texture_color(m_position.x + m_size.x, m_position.y + l_propY,
							UvBiasX(uvs, (Time.time * -8 % 8) + m_size.x - kPropertyColumn), UvBiasY(uvs, 0),
							color, alpha);
						draw_vertex_texture_color(m_position.x + m_size.x, m_position.y + l_propY + kPropertyHeight,
							UvBiasX(uvs, (Time.time * -8 % 8) + m_size.x - kPropertyColumn), UvBiasY(uvs, kPropertyHeight),
							color, alpha);
					draw_primitive_end();
					
					gpu_set_tex_repeat(prev_repeat);
				}
			}
			
			// set up name text
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
			
			var property_value = property_values[iProperty];
			
			if (property[1] == kValueTypeColor)
			{
				var color = variable_instance_get(entity_instance, property[0]);
				// Draw the color as background
				draw_set_color(color);
				DrawSpriteRectangle(m_position.x + kPropertyColumn, m_position.y + l_propY, m_position.x + m_size.x, m_position.y + l_propY + kPropertyHeight, false);
				
				// Draw the text for the color values behind
				draw_set_color(color_get_value(color) > 128 ? c_black : c_white);
				draw_text(l_textX, l_textY, property_value);
			}
			else
			{
				// Draw property as normal
				draw_text(l_textX, l_textY, property_value);
			}
			
			if (focused && property_editing && iProperty == property_focused)
			{
				if (Time.time % 1.0 > 0.5)
				{
					// Draw the text edit cursor
					var l_strForCursor = string_copy(property_value, 1, property_edit_cursor);
					var l_strW = string_width(l_strForCursor);
					DrawSpriteLine(l_textX + l_strW - 1, m_position.y + l_propY + 2, l_textX + l_strW - 1, m_position.y + l_propY + kPropertyHeight - 2);
				}
			}
			
		} // end "for iProperty"
		
		// draw the focused property
		if (property_focused != null)
		{
			var l_propY = property_focused * kPropertyHeight + 1 - drag_y;
			
			draw_set_color(focused ? (property_change_ok ? kAccentColor : c_red) : c_gray);
			DrawSpriteRectangle(m_position.x, m_position.y + l_propY - 2, m_position.x + m_size.x - kDragWidth, m_position.y + l_propY + kPropertyHeight + 2, true);
		}
		
		drawShaderUnset(sh_editorDefaultScissor);
	}
}