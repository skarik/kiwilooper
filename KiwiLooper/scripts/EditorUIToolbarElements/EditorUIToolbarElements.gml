function AToolbarElementSpinner(tooltip, label, onChange, initialValue) : AToolbarElement() constructor
{
	static kButtonsWidth = 7;
	static kTextMargin = 2;
		
	m_isButton = true;
	m_richParams = true;
	m_customDraw = true;
	m_stepEnabled = true;
	
	m_onChange = onChange;
	
	m_text = label; // Text grabbed. Not drawn, but used to size.
	
	valueIncrements = 1;
	valueType = kValueTypeInteger; // can also be kValueTypeFloat.
	
	propertyValue = initialValue;
	propertyOldValue = initialValue;
	propertyEditCursor = null;
	propertyEditing = false;
	propertyDisplayString = "";
	propertyChangeOk = true;
	
	state_upButton_Hovered = false;
	state_dnButton_Hovered = false;
	
	layout_rect_up = new Rect2(new Vector2(0, 0), new Vector2(0, 0));
	layout_rect_dn = new Rect2(new Vector2(0, 0), new Vector2(0, 0));
	
	m_onClick = function(mouseX, mouseY)
	{
		// todo
		if (m_state_isHovered)
		{
			// If mouse X is smaller than layout_rect_up.m_min.x, then we clicked on the value
			if (mouseX < layout_rect_up.m_min.x)
			{
				// TODO: begin editing here.
				if (!propertyEditing)
				{
					PropertyChangeBegin();
				}
					
				if (propertyEditing)
				{
					// Start with cursor at the end
					propertyEditCursor =  string_length(propertyDisplayString);
						
					// Update the mouse click position
					draw_set_font(EditorGetUIFont());
					var deltaX = mouseX - (layout_rect.m_min.x + kTextMargin - string_width("W") * 0.5);
					for (var iLength = 1; iLength <= string_length(propertyDisplayString); ++iLength)
					{
						if (string_width(string_copy(propertyDisplayString, 1, iLength)) > deltaX)
						{
							propertyEditCursor = iLength - 1;
							break;
						}
					}
						
					// Clamp to length
					propertyEditCursor = clamp(propertyEditCursor, 0, string_length(propertyDisplayString));
				}
			}
			else
			{
				if (propertyEditing)
				{
					PropertyChangeEnd();
				}
				
				// Increment button clicked
				if (layout_rect_up.contains(mouseX, mouseY))
				{
					PropertyUpdateValue(propertyValue + valueIncrements);
					PropertyUpdateDisplayString();
				}
				// Decrement button clicked
				else if (layout_rect_dn.contains(mouseX, mouseY))
				{
					PropertyUpdateValue(propertyValue - valueIncrements);
					PropertyUpdateDisplayString();
				}
			}
		}
	};
	m_onStep = function(mouseX, mouseY)
	{
		var ui_scale = EditorGetUIScale();
			
		// Set up the bounding box for the side rect boxes
		var l_boxLeftSide = layout_rect.m_max.x - kButtonsWidth * ui_scale;
				
		// Set up left & right sides
		layout_rect_up.m_min.x = l_boxLeftSide;
		layout_rect_dn.m_min.x = l_boxLeftSide;
		layout_rect_up.m_max.x = layout_rect.m_max.x;
		layout_rect_dn.m_max.x = layout_rect.m_max.x;
		// Set up & down stuff
		layout_rect_up.m_min.y = layout_rect.m_min.y;
		layout_rect_up.m_max.y = ceil((layout_rect.m_min.y + layout_rect.m_max.y) * 0.5) - 1;
		layout_rect_dn.m_min.y = layout_rect_up.m_max.y + 1;
		layout_rect_dn.m_max.y = layout_rect.m_max.y;
			
		// Check hover states
		state_upButton_Hovered = layout_rect_up.contains(mouseX, mouseY);
		state_dnButton_Hovered = layout_rect_dn.contains(mouseX, mouseY);
			
		//inputPollTyping
		//
			
		// Fix invalid string setup
		if (!propertyEditing && propertyDisplayString == "")
		{
			PropertyUpdateDisplayString();
		}
			
		if (propertyEditing)
		{
			// If press enter, or out of focus, commit the change and finish
			if (keyboard_check_pressed(vk_enter))
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
				// Perform typing controls
				var l_valueCursor = inputPollTyping(propertyDisplayString, propertyEditCursor);
				propertyDisplayString = l_valueCursor.value;
				propertyEditCursor = l_valueCursor.cursor;
				
				// Check the result of typing:
				propertyChangeOk = PropertyUpdateValueFromString();
			}
		}
		
		// Hack: Check if click outside
		if (mouse_check_button(mb_left) && !m_state_isHovered)
		{
			if (propertyEditing)
			{
				PropertyChangeEnd();
			}
		}
	};
		
	static PropertyUpdateDisplayString = function()
	{
		var decimal_count	= max(0, ceil(-log10(valueIncrements)));
		var top_count		= max(0, floor(log10(valueIncrements)));
		propertyDisplayString = string_format(propertyValue, top_count + decimal_count, decimal_count);
	}
	static PropertyChangeBegin = function()
	{
		assert(propertyEditing == false);
		propertyOldValue = propertyValue;
		propertyEditing = true;
		propertyChangeOk = true;
	}
	static PropertyChangeEnd = function()
	{
		// Attempt to convert the value
		var valid = PropertyUpdateValueFromString();
			
		// Reset if invalid input
		if (!valid)
		{
			PropertyUpdateValue(propertyOldValue);
		}
		propertyEditing = false;
		propertyEditCursor = null;
			
		// Update the string now that we're done editing.
		PropertyUpdateDisplayString();
	}
	static PropertyUpdateValueFromString = function()
	{
		// Convert the value type
		var valid = false;
		var new_value = undefined;
		try
		{
			new_value = real(propertyDisplayString);
			valid = true;
		}
		catch (_exception)
		{
			valid = false;
		}
			
		// Apply changes
		if (valid)
		{
			PropertyUpdateValue(new_value);
		}
			
		// Return if we could apply anything.
		return valid;
	}
	/// @function PropertyUpdateValue(new_value, doCallback=true)
	/// @desc Sets new value and calls callback if needed
	static PropertyUpdateValue = function(new_value, doCallback=true)
	{
		var old_value = propertyValue;
		if (!is_undefined(new_value) && new_value != old_value)
		{
			propertyValue = new_value;
			if (doCallback && m_onChange != null)
			{
				m_onChange(new_value);
			}
			return true;
		}
		return false;
	}
	
	static IsEditing = function()
	{
		return propertyEditing;
	}
	
	static PropertySetIfNotEditing = function(new_value)
	{
		if (!IsEditing())
		{
			if (PropertyUpdateValue(new_value, false))
			{
				PropertyUpdateDisplayString();
			}
		}
	}
	
	static PropertyEndEditAndGet = function()
	{
		if (IsEditing())
		{
			PropertyChangeEnd();
		}
		return propertyValue;
	}
	
	m_onDraw = function(x, y)
	{
		var ui_scale = EditorGetUIScale();
		
		// Draw the value's background (show bad values)
		if (!propertyChangeOk)
		{
			draw_set_color(c_maroon);
			DrawSpriteRectangle(layout_rect.m_min.x, layout_rect.m_min.y, 
								layout_rect_up.m_min.x - 1, layout_rect.m_max.y,
								false);
		}
			
		// Draw the value's box 
		draw_set_color((m_state_isHovered || propertyEditing) ? c_white : c_gray);
		DrawSpriteRectangle(layout_rect.m_min.x, layout_rect.m_min.y, 
							layout_rect_up.m_min.x - 1, layout_rect.m_max.y,
							true);

		// Draw current value (with decimal points based on valueIncrements decimal count)
		var l_textX = layout_rect.m_min.x + kTextMargin;
		draw_set_color(c_white);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(EditorGetUIFont());
		draw_text(l_textX, layout_rect.m_min.y + 2, propertyDisplayString);
			
		if (Time.time % 1.0 > 0.5)
		{
			if (propertyEditing)
			{
				// Draw the text edit cursor
				var l_strForCursor = string_copy(propertyDisplayString, 1, propertyEditCursor);
				var l_strW = string_width(l_strForCursor);
				DrawSpriteLine(l_textX + l_strW - 1, layout_rect.m_min.y + 2, l_textX + l_strW - 1, layout_rect.m_min.y + 2 + 8 * EditorGetUIScale());
			}
		}
			
		// Draw the up & down buttons
		{
			// Up
			draw_set_color(state_upButton_Hovered ? c_white : c_gray);
			DrawSpriteRectangle(layout_rect_up.m_min.x, layout_rect_up.m_min.y,
								layout_rect_up.m_max.x, layout_rect_up.m_max.y,
								true);
			draw_sprite_ext(suie_annoteEdit, 8,
							floor((layout_rect_up.m_min.x + layout_rect_up.m_max.x) * 0.5),
							floor((layout_rect_up.m_min.y + layout_rect_up.m_max.y) * 0.5),
							ui_scale,ui_scale, 90,
							state_upButton_Hovered ? c_white : c_gray, 1.0);

			// Down
			draw_set_color(state_dnButton_Hovered ? c_white : c_gray);
			DrawSpriteRectangle(layout_rect_dn.m_min.x, layout_rect_dn.m_min.y,
								layout_rect_dn.m_max.x, layout_rect_dn.m_max.y,
								true);
			draw_sprite_ext(suie_annoteEdit, 8,
							floor((layout_rect_dn.m_min.x + layout_rect_dn.m_max.x) * 0.5),
							floor((layout_rect_dn.m_min.y + layout_rect_dn.m_max.y) * 0.5),
							-ui_scale,ui_scale, 90,
							state_dnButton_Hovered ? c_white : c_gray, 1.0);
		}
	};
}

function AToolbarElementAsSpinner(tooltip, label, onChange, initialValue)
{
	element = new AToolbarElementSpinner(tooltip, label, onChange, initialValue);
	return element;
}