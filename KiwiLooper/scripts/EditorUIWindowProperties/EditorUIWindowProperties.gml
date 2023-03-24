/// @function AEditorWindowProperties() constructor
/// @desc Entity properties window. Allows for editing properties.
function AEditorWindowProperties() : AEditorWindow() constructor
{
	m_title = "Properties";
	
	entity_instance = null;
	entity_info = null;
	entity_canSimulate = false;
	
	prop_instance = null;
	
	editing_target = kEditorSelection_None;
	
	property_values = [];
	property_names = [];
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
	
	m_size.x = 200 * EditorGetUIScale();
	m_size.y = 180 * EditorGetUIScale();
	m_size.roundSelf();
	
	static sh_uScissorRect = shader_get_uniform(sh_editorDefaultScissor, "uScissorRect");
	static kPropertyHeight = 12;
	static kPropertyColumn = 75;
	static kPropertyMargin = 2;
	static kDragWidth = 10;
	
	#macro kPropertyMouseOverId_Simulate 1023
	
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
	
	static MoveForPosition = function(in_x, in_y, in_z, in_size)
	{
		// Get the positions in 3D space to get sizes
		var ent_screenpos = o_Camera3D.positionToView(in_x, in_y, in_z);
		var ent_screenpos_corner = o_Camera3D.positionToView(in_x + o_Camera3D.m_viewUp[0] * in_size * 0.5, in_y + o_Camera3D.m_viewUp[1] * in_size * 0.5, in_z + o_Camera3D.m_viewUp[2] * in_size * 0.5);
		
		// Define the padding for the properties box.
		var kPadding = 10; // Padding around the end position.
		var kMaxHullOffset = 60; // This needs DPI scale.
		var positionOffset = min(kMaxHullOffset, kPadding + point_distance(ent_screenpos[0], ent_screenpos[1], ent_screenpos_corner[0], ent_screenpos_corner[1]));
		
		// We also want to get the XYZ position of the ent, and put the window somewhere nearby there
		if (!has_stored_position)
		{
			m_position.x = ent_screenpos[0] + positionOffset;
			m_position.y = ent_screenpos[1] + positionOffset;
		}
		// Begin clamping check:
		{
			var clampPosition = function(bNewPlacement=false)
			{
				// Clamp the window position
				if (!bNewPlacement)
				{
					var kEdgePadding = 48;
					m_position.x = round(max(kEdgePadding - m_size.x, min(m_position.x, GameCamera.width - kEdgePadding)));
					m_position.y = round(max(kEdgePadding + 16 - m_size.y, min(m_position.y, GameCamera.height - kEdgePadding)));
				}
				else
				{
					var kEdgePadding = 5;
					m_position.x = round(max(kEdgePadding, min(m_position.x, GameCamera.width - kEdgePadding - m_size.x)));
					m_position.y = round(max(kEdgePadding + 16, min(m_position.y, GameCamera.height - kEdgePadding - m_size.y)));
				}
			}
			clampPosition();
			
			// If we're covering the ent position, move to other corners and clamp
			var positionOffsetEdge = positionOffset - 1;
			if (Rect2FromMinSize(m_position, m_size).expand1Self(positionOffsetEdge).contains(ent_screenpos[0], ent_screenpos[1]))
			{
				m_position.x = ent_screenpos[0] - m_size.x - positionOffset;
				m_position.y = ent_screenpos[1] + positionOffset;
				clampPosition(true);
				
				if (Rect2FromMinSize(m_position, m_size).expand1Self(positionOffsetEdge).contains(ent_screenpos[0], ent_screenpos[1]))
				{
					m_position.x = ent_screenpos[0] - m_size.x - positionOffset;
					m_position.y = ent_screenpos[1] - m_size.y - positionOffset;
					clampPosition(true);
					
					if (Rect2FromMinSize(m_position, m_size).expand1Self(positionOffsetEdge).contains(ent_screenpos[0], ent_screenpos[1]))
					{
						m_position.x = ent_screenpos[0] + positionOffset;
						m_position.y = ent_screenpos[1] - m_size.y - positionOffset;
						clampPosition(true);
						
						// Go back to the starting position at the end
						if (Rect2FromMinSize(m_position, m_size).expand1Self(positionOffsetEdge).contains(ent_screenpos[0], ent_screenpos[1]))
						{
							m_position.x = ent_screenpos[0] + positionOffset;
							m_position.y = ent_screenpos[1] + positionOffset;
							clampPosition(true);
						}
					}
				}
			}
		} // End best corner search
	}
	
	static InitPropertyNames = function()
	{
		// Since editing everything is based around key-values, we need to generate string values for each entry now.
		for (var iProperty = 0; iProperty < array_length(entity_info.properties); ++iProperty)
		{
			var property = entity_info.properties[iProperty];
			
			// Update property names for rendering
			var l_bSpecialPosition = (property[0] == "") && (property[1] == kValueTypePosition);
			var l_bSpecialRotation = (property[0] == "") && (property[1] == kValueTypeRotation);
			var l_bSpecialScale = (property[0] == "") && (property[1] == kValueTypeScale);
			if (l_bSpecialPosition) property_names[iProperty] = "(position)";
			else if (l_bSpecialRotation) property_names[iProperty] = "(rotation)";
			else if (l_bSpecialScale) property_names[iProperty] = "(scale)";
			else
			{
				var name = property[0];
				
				// if we have a _ or *_, remove that
				{
					var prefix_position = string_pos("_", name);
					if (prefix_position == 1 || prefix_position == 2)
					{
						name = string_copy(name, prefix_position + 1, string_length(name) - prefix_position);
					}
				}
				// separate out camel case
				{
					var old_name = name;
					var old_name_len = string_length(old_name);
					// start with first character
					var old_letter = string_char_at(old_name, 1);
					name = string_upper(old_letter);
					// loop thru it all
					for (var iLetter = 2; iLetter <= old_name_len; ++iLetter)
					{
						var letter = string_char_at(old_name, iLetter);
						
						if (string_upper(letter) == letter && string_lower(old_letter) == old_letter)
							name += " " + letter;
						else
							name += letter;
						
						old_letter = letter; // continue on
					}
				}
				
				property_names[iProperty] = name;
			}
		}
	} // End InitPropertyNames()
	
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
		
		MoveForPosition(entity_instance.x, entity_instance.y, entity_instance.z, entityInfo.hullsize);
		
		// Since editing everything is based around key-values, we need to generate string values for each entry now.
		for (var iProperty = 0; iProperty < array_length(entity_info.properties); ++iProperty)
		{
			var property = entity_info.properties[iProperty];
			property_values[iProperty] = entpropToString(entity_instance, property);
		}
		
		// Update the title now
		m_title = entityInfo.name + " Properties";
		// Update property names for display
		InitPropertyNames();
		
		// Check if can simulate
		if (entityInfo.proxyCanQueryEditor)
		{
			var temp = inew(entityInfo.objectIndex);
			entity_canSimulate = variable_instance_exists(temp, "onEditorPreviewBegin");
			idelete(temp);
		}
		else
		{
			entity_canSimulate	= false;
		}
	} // End InitWithEntityInfo()
	
	static InitUpdateEntityInfoTransform = function(incoming_entity)
	{
		if (entity_instance != incoming_entity
			&& prop_instance != incoming_entity)
		{
			return; // Skip if there's no matching entity
		}
		
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
		entity_canSimulate	= false;
		prop_instance	= prop;
		editing_target	= kEditorSelection_Prop;
		
		MoveForPosition(prop_instance.x, prop_instance.y, prop_instance.z,
			max(sprite_get_width(prop_instance.sprite), sprite_get_height(prop_instance.sprite)) * max(prop_instance.xscale, prop_instance.yscale, prop_instance.zscale)
			);
		
		entity_info		= {
			properties: [
				["", kValueTypePosition],
				["", kValueTypeRotation],
				["", kValueTypeScale],
				["index", kValueTypeInteger],
			],
		};
		
		InitUpdateEntityInfoTransform(prop);
		property_values[3] = entpropToString(prop, entity_info.properties[3]);
		
		// Update the title now
		m_title = string_replace(sprite_get_name(prop.sprite), "spr_", "") + " Prop-erties";
		// Update property names for display
		InitPropertyNames();
	}
	
	static onResize = function()
	{
		drag_mouseover = false;
	}
	static onMouseMove = function(mouseX, mouseY)
	{
		var ui_scale = EditorGetUIScale();
		
		if (mouse_position == kWindowMousePositionContent && mouseX < m_position.x + m_size.x - kDragWidth)
		{
			drag_mouseover = false;
			property_mouseover = floor((mouseY - m_position.y - 1 + drag_y) / (kPropertyHeight * ui_scale) - (entity_canSimulate ? 1 : 0));
			
			if (entity_canSimulate && property_mouseover == -1)
				property_mouseover = kPropertyMouseOverId_Simulate;
			else if (property_mouseover < 0 || property_mouseover >= array_length(entity_info.properties))
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
		var ui_scale = EditorGetUIScale();
		
		if ((event & kEditorToolButtonStateMake) && mouse_position == kWindowMousePositionContent)
		{
			// If mouse wheel, attempt scroll
			if (button == kEditorButtonWheelUp || button == kEditorButtonWheelDown)
			{
				var kDragMaxY = max(0.0, array_length(entity_info.properties) * kPropertyHeight * ui_scale - m_size.y);
				drag_y_target += ((button == kEditorButtonWheelUp) ? -kPropertyHeight : kPropertyHeight) * ui_scale;
				drag_y_target = clamp(drag_y_target, 0.0, kDragMaxY);
			}
			// If click simulate, then we have to sim
			else if (property_mouseover == kPropertyMouseOverId_Simulate && entity_canSimulate)
			{
				// With our current ent, instantiate using our proxy and then simulate.
				var simulatedEnt = inew(entity_info.objectIndex);
				
				// Since editing everything is based around key-values, we need to generate string values for each entry now.
				for (var iProperty = 0; iProperty < array_length(entity_info.properties); ++iProperty)
				{
					var property = entity_info.properties[iProperty];
					if (entpropIsSpecialTransform(property))
					{
						if (property[1] == kValueTypePosition)
						{
							simulatedEnt.x = entity_instance.x;
							simulatedEnt.y = entity_instance.y;
							simulatedEnt.z = entity_instance.z;
						}
						else if (property[1] == kValueTypeRotation)
						{
							simulatedEnt.xrotation = entity_instance.xrotation;
							simulatedEnt.yrotation = entity_instance.yrotation;
							simulatedEnt.zrotation = entity_instance.zrotation;
						}
						else if (property[1] == kValueTypeScale)
						{
							simulatedEnt.xscale = entity_instance.xscale;
							simulatedEnt.yscale = entity_instance.yscale;
							simulatedEnt.zscale = entity_instance.zscale;
						}
					}
					else
					{
						variable_instance_set(simulatedEnt, property[0], variable_instance_get(entity_instance, property[0]));
					}
				}
				
				// Begin sim
				simulatedEnt.onEditorPreviewBegin();
				
				// We're done with the ent after simulating!
				idelete(simulatedEnt);
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
				if (mouseX > m_position.x + kPropertyColumn * ui_scale)
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
						draw_set_font(EditorGetUIFont());
						var deltaX = mouseX - (m_position.x + kPropertyColumn * ui_scale + kPropertyMargin - string_width("W") * 0.5);
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
		else if ((event & kEditorToolButtonStateBreak))
		{
			// Stop all drags
			drag_now = false;
			property_drag = false;
		}
	}
	
	static Step = function()
	{
		var ui_scale = EditorGetUIScale();
		
		if (drag_now)
		{
			var kDragMaxY = max(0.0, (array_length(entity_info.properties) + entity_canSimulate) * kPropertyHeight * ui_scale - m_size.y);
			
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
				
				// Use the "dropdown" editor
				if (property[1] == kValueTypeEnum)
				{
					var enum_value = variable_instance_get(entity_instance, property[0]);
					var enum_index = null;
					
					// Find the current index of the property
					for (var propertySubIndex = 0; propertySubIndex < array_length(property[3]); ++propertySubIndex)
					{
						if (is_equal(property[3][propertySubIndex][1], enum_value))
						{
							enum_index = propertySubIndex;
							break;
						}
					}
					
					// Select next index if we receive input
					var next_value = property[3][0][1]; // Default to first value
					if (enum_index != null && enum_index < array_length(property[3]) - 1)
					{
						next_value = property[3][enum_index + 1][1];
					}
					
					var prev_value = property[3][array_length(property[3]) - 1][1]; // Default to last value
					if (enum_index != null && enum_index > 0)
					{
						prev_value = property[3][enum_index - 1][1];
					}
					
					// Roll forward if left click
					if (property_mouseover == property_focused)
					{
						if (mouse_check_button_pressed(mb_left))
						{
							variable_instance_set(entity_instance, property[0], next_value);
						}
						else if (mouse_check_button_pressed(mb_right))
						{
							variable_instance_set(entity_instance, property[0], prev_value);
						}
						// Update the focused value
						property_values[property_focused] = string(variable_instance_get(entity_instance, property[0]));
					}
				}
				// Use the string editor
				else
				{
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
						EditorGlobalSignalTransformChange(instance, instance_type, property[1]);
					}
					else if (property_change_ok)
					{
						EditorGlobalSignalPropertyChange(instance, instance_type, property, value);
					}
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
		
		var ui_scale = EditorGetUIScale();
		
		if (editing_target == kEditorSelection_Prop)
		{
			draw_set_color(focused ? c_white : c_ltgray);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(EditorGetUIFont());
			
			draw_text(m_position.x + 2, m_position.y + 2, "Prop Keyvalues not yet set.");
			//return;
		}
		else if (!iexists(entity_instance))
		{
			draw_set_color(focused ? c_white : c_ltgray);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(EditorGetUIFont());
			
			draw_text(m_position.x + 2, m_position.y + 2, "No selection.");
			return;
		}
		
		// Draw the scroll bar:
		draw_set_color(focused ? c_dkgray : c_gray);
		DrawSpriteRectangle(m_position.x + m_size.x - kDragWidth, m_position.y, m_position.x + m_size.x, m_position.y + m_size.y, true);
		{
			var kDragMaxY = max(0.0, (array_length(entity_info.properties) + entity_canSimulate) * kPropertyHeight * ui_scale - m_size.y);
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
		
		// Start with the simulate button at the top
		if (entity_canSimulate)
		{
			draw_set_color((property_mouseover == kPropertyMouseOverId_Simulate) ? kAccentColor : c_black);
			//DrawSpriteRectangle(m_position.x + 2, m_position.y + 2, m_position.x + kPropertyColumn * ui_scale, m_position.y + kPropertyHeight * ui_scale - 1, false);
			DrawSpriteRectangle(m_position.x + 2, m_position.y + 2, m_position.x + m_size.x - 2, m_position.y + kPropertyHeight * ui_scale - 1, false);
			draw_set_color((property_mouseover == kPropertyMouseOverId_Simulate) ? c_white : kAccentColor);
			//DrawSpriteRectangle(m_position.x + 2, m_position.y + 2, m_position.x + kPropertyColumn * ui_scale, m_position.y + kPropertyHeight * ui_scale - 1, true);
			DrawSpriteRectangle(m_position.x + 2, m_position.y + 2, m_position.x + m_size.x - 2, m_position.y + kPropertyHeight * ui_scale - 1, true);
			draw_set_color((property_mouseover == kPropertyMouseOverId_Simulate) ? c_white : kAccentColor);
			draw_set_halign(fa_left);
			draw_set_valign(fa_bottom);
			draw_set_font(EditorGetUIFont());
			draw_text(m_position.x + 3,
					  m_position.y + kPropertyHeight * ui_scale - 1,
					  "Click to Simulate Trigger");
		}
		
		// Run through all the properties and draw them
		for (var iProperty = 0; iProperty < array_length(entity_info.properties); ++iProperty)
		{
			var property = entity_info.properties[iProperty];
			
			var l_propY = (iProperty + entity_canSimulate) * kPropertyHeight * ui_scale + 1 - drag_y;
			var l_bgColor = focused ? ((iProperty % 2 == 0) ? c_black : c_dkgray) : c_dkgray;
			
			if (iProperty == property_mouseover)
			{
				l_bgColor = merge_color(l_bgColor, kAccentColor, 0.25);
			}
			
			// draw property background
			draw_set_color(l_bgColor);
			DrawSpriteRectangle(m_position.x, m_position.y + l_propY, m_position.x + m_size.x, m_position.y + l_propY + kPropertyHeight * ui_scale, false);
			// draw property focus outline
			if (iProperty == property_focused)
			{
				// If we're editing, also draw a brighter background
				draw_set_color(focused ? kAccentColor : c_gray);
				DrawSpriteRectangle(m_position.x + kPropertyColumn * ui_scale, m_position.y + l_propY, m_position.x + m_size.x, m_position.y + l_propY + kPropertyHeight * ui_scale, false);
				
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
						draw_vertex_texture_color(m_position.x + kPropertyColumn * ui_scale, m_position.y + l_propY,
							UvBiasX(uvs, (Time.time * -8 % 8) + 0), UvBiasY(uvs, 0),
							color, alpha);
						draw_vertex_texture_color(m_position.x + kPropertyColumn * ui_scale, m_position.y + l_propY + kPropertyHeight * ui_scale,
							UvBiasX(uvs, (Time.time * -8 % 8) + 0), UvBiasY(uvs, kPropertyHeight * ui_scale),
							color, alpha);
						draw_vertex_texture_color(m_position.x + m_size.x, m_position.y + l_propY,
							UvBiasX(uvs, (Time.time * -8 % 8) + m_size.x - kPropertyColumn * ui_scale), UvBiasY(uvs, 0),
							color, alpha);
						draw_vertex_texture_color(m_position.x + m_size.x, m_position.y + l_propY + kPropertyHeight * ui_scale,
							UvBiasX(uvs, (Time.time * -8 % 8) + m_size.x - kPropertyColumn * ui_scale), UvBiasY(uvs, kPropertyHeight * ui_scale),
							color, alpha);
					draw_primitive_end();
					
					gpu_set_tex_repeat(prev_repeat);
				}
			}
			
			// set up name text
			draw_set_color(focused ? c_white : c_ltgray);
			draw_set_halign(fa_left);
			draw_set_valign(fa_bottom);
			draw_set_font(EditorGetUIFont());
			
			// draw the property name:
			var l_textX = m_position.x + kPropertyMargin;
			var l_textY = m_position.y + l_propY + kPropertyHeight * ui_scale - kPropertyMargin;
			
			/*var l_bSpecialPosition = (property[0] == "") && (property[1] == kValueTypePosition);
			var l_bSpecialRotation = (property[0] == "") && (property[1] == kValueTypeRotation);
			var l_bSpecialScale = (property[0] == "") && (property[1] == kValueTypeScale);*/
			
			draw_text(l_textX, l_textY, property_names[iProperty]);
			/*if (l_bSpecialPosition) draw_text(l_textX, l_textY, "(position)");
			else if (l_bSpecialRotation) draw_text(l_textX, l_textY, "(rotation)");
			else if (l_bSpecialScale) draw_text(l_textX, l_textY, "(scale)");
			else
			{
				draw_text(l_textX, l_textY, property[0]);
			}*/
			
			// draw the property value:
			l_textX = m_position.x + kPropertyColumn * ui_scale + kPropertyMargin;
			
			var property_value = property_values[iProperty];
			
			if (property[1] == kValueTypeColor)
			{
				var color = variable_instance_get(entity_instance, property[0]);
				// Draw the color as background
				draw_set_color(color);
				DrawSpriteRectangle(m_position.x + kPropertyColumn * ui_scale, m_position.y + l_propY, m_position.x + m_size.x, m_position.y + l_propY + kPropertyHeight * ui_scale, false);
				
				// Draw the text for the color values behind
				draw_set_color(color_get_value(color) > 128 ? c_black : c_white);
				draw_text(l_textX, l_textY, property_value);
			}
			else if (property[1] == kValueTypeEnum)
			{
				var enum_value = variable_instance_get(entity_instance, property[0]);
				var enum_index = null;
				
				// Find the matching value in the property
				for (var propertySubIndex = 0; propertySubIndex < array_length(property[3]); ++propertySubIndex)
				{
					if (is_equal(property[3][propertySubIndex][1], enum_value))
					{
						enum_index = propertySubIndex;
						break;
					}
				}
				draw_text(l_textX, l_textY, (enum_index == null) ? "N/A" : property[3][enum_index][0]);
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
					DrawSpriteLine(l_textX + l_strW - 1, m_position.y + l_propY + 2, l_textX + l_strW - 1, m_position.y + l_propY + kPropertyHeight * ui_scale - 2);
				}
			}
			
		} // end "for iProperty"
		
		// draw the focused property
		if (property_focused != null)
		{
			var l_propY = property_focused * kPropertyHeight * ui_scale + 1 - drag_y;
			
			draw_set_color(focused ? (property_change_ok ? kAccentColor : c_red) : c_gray);
			DrawSpriteRectangle(m_position.x, m_position.y + l_propY - 2, m_position.x + m_size.x - kDragWidth, m_position.y + l_propY + kPropertyHeight * ui_scale + 2, true);
		}
		
		drawShaderUnset(sh_editorDefaultScissor);
	}
}