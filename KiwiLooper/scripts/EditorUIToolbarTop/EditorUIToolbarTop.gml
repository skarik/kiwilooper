/// @function AToolbarTop() constructor
/// @notes A toolbar for rendering a horizontal general menu.
function AToolbarTop() : AToolbar() constructor
{
	static kButtonSize		= 18;
	static kButtonPadding	= 3;
	static kSpacerSize		= 7;
	static kTooltipShowTime	= 0.25;
	static kTextPadding		= 1;
	
	static Step = function(mouseX, mouseY, mouseAvailable)
	{
		m_state_containsMouse = false;
		
		// Set font for checking widths
		draw_set_font(f_04b03);
		
		var topLeft = new Vector2(x, y);
		for (var elementIndex = 0; elementIndex < m_elementsCount; ++elementIndex)
		{
			var element = m_elements[elementIndex];
			
			// Get element extra width that text adds
			var extra_width = 0;
			var has_text = is_string(element.m_text);
			if (has_text)
			{
				extra_width = (element.m_width > 0) ? element.m_width : (kTextPadding * 2 + string_width(element.m_text));
			}
			
			var bIsLabel = !element.m_isButton && has_text;
			
			// Update enabled state
			element.m_state_isEnabled = (element.m_onCanClick == null) ? true : element.m_onCanClick();
			
			// Check if mouse is inside
			if ((element.m_isButton || bIsLabel) && element.m_state_isEnabled)
			{
				element.m_state_isDown = (element.m_onCheckDown == null) ? false : element.m_onCheckDown();
				
				if (mouseAvailable && point_in_rectangle(mouseX, mouseY, topLeft.x, topLeft.y, topLeft.x + kButtonSize + extra_width - 1, topLeft.y + kButtonSize - 1))
				{
					element.m_state_isHovered = true;
					element.m_state_hoveredTime += Time.deltaTime;
					if (element.m_state_hoveredTime > kTooltipShowTime)
					{
						element.m_state_showTooltip = true;
					}
					
					if (element.m_isButton && mouse_check_button_pressed(mb_left))
					{
						element.m_onClick();
						element.m_state_isDown = true;
					}
					
					m_state_containsMouse = true;
				}
				else if (element.m_state_isHovered)
				{
					// Mouse not inside, reset all the hover states.
					element.m_state_isHovered = false;
					element.m_state_hoveredTime = 0.0;
					element.m_state_showTooltip = false;
				}
			}
			// If not enabled, emulate mouse not inside
			if (!element.m_state_isEnabled)
			{
				element.m_state_isDown = false;
				element.m_state_isHovered = false;
				element.m_state_hoveredTime = 0.0;
				element.m_state_showTooltip = false;
			}
			
			// Advance cursor.
			topLeft.x += (element.m_isButton || bIsLabel) ? (kButtonSize + extra_width) : kSpacerSize;
		}
		m_elementsWidth = topLeft.x - x;
	};
	
	static Draw = function()
	{
		draw_set_alpha(1.0);
		
		var topLeft = new Vector2(x, y);
		for (var elementIndex = 0; elementIndex < m_elementsCount; ++elementIndex)
		{
			var element = m_elements[elementIndex];
			
			// Get element extra width that text adds
			var extra_width = 0;
			var has_text = false;
			if (is_string(element.m_text))
			{
				draw_set_font(f_04b03);
				extra_width = (element.m_width > 0) ? element.m_width : (kTextPadding * 2 + string_width(element.m_text));
				has_text = true;
			}
			
			// Cache if have sprite
			var has_sprite = sprite_exists(element.m_sprite);
			
			// Draw button
			if (element.m_isButton)
			{
				if (element.m_state_isDown)
				{
					draw_set_color(c_gray);
					DrawSpriteRectangle(topLeft.x, topLeft.y,
										topLeft.x + kButtonSize + extra_width, topLeft.y + kButtonSize,
										false);
				}
				draw_set_color((element.m_state_isHovered && element.m_state_isEnabled) ? c_white : c_gray);
				DrawSpriteRectangle(topLeft.x, topLeft.y,
									topLeft.x + kButtonSize + extra_width, topLeft.y + kButtonSize,
									true);
				
				if (element.m_state_isEnabled)
				{
					draw_sprite(element.m_sprite, element.m_spriteIndex, topLeft.x + 1 + kButtonPadding, topLeft.y + 1 + kButtonPadding);
				}
				else
				{
					draw_sprite_ext(element.m_sprite, element.m_spriteIndex, topLeft.x + 1 + kButtonPadding, topLeft.y + 1 + kButtonPadding, 1,1,0, c_gray, 1.0);
				}
				
				if (has_text)
				{
					draw_set_font(f_04b03);
					draw_set_color(element.m_state_isEnabled ? c_white : c_gray);
					draw_set_halign(fa_left);
					draw_set_valign(fa_middle);
					draw_text(topLeft.x + kButtonSize + kTextPadding - 1, topLeft.y + 1 + kButtonSize / 2, element.m_text);
				}
				
				if (element.m_state_showTooltip)
				{
					draw_set_font(f_04b03);
					var tooltipLength = string_width(element.m_tooltip);
					var tooltipHeight = string_height(element.m_tooltip);
					
					draw_set_color(c_black);
					DrawSpriteRectangle(topLeft.x + 1, topLeft.y + kButtonSize,
										topLeft.x + 2 + 3 + tooltipLength,
										topLeft.y + kButtonSize + 4 + tooltipHeight,
										false);
					draw_set_color(c_white);
					DrawSpriteRectangle(topLeft.x + 1, topLeft.y + kButtonSize,
										topLeft.x + 2 + 3 + tooltipLength,
										topLeft.y + kButtonSize + 4 + tooltipHeight,
										true);
					
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
					draw_text(topLeft.x + 3, topLeft.y + kButtonSize + 2, element.m_tooltip);
				}
			}
			// Draw label
			else if (has_text)
			{
				if (has_sprite)
				{
					draw_sprite(element.m_sprite, element.m_spriteIndex, topLeft.x + 1 + kButtonPadding, topLeft.y + 1 + kButtonPadding);
				}
				
				if (has_text)
				{
					draw_set_font(f_04b03);
					draw_set_color(c_white);
					draw_set_halign(fa_left);
					draw_set_valign(fa_middle);
					draw_text(topLeft.x + kTextPadding, topLeft.y + 1 + kButtonSize / 2, element.m_text);
				}
				
				if (element.m_state_showTooltip)
				{
					draw_set_font(f_04b03);
					var tooltipLength = string_width(element.m_tooltip);
					var tooltipHeight = string_height(element.m_tooltip);
					
					draw_set_color(c_black);
					DrawSpriteRectangle(topLeft.x + 1, topLeft.y + kButtonSize,
										topLeft.x + 2 + 3 + tooltipLength,
										topLeft.y + kButtonSize + 4 + tooltipHeight,
										false);
					draw_set_color(c_white);
					DrawSpriteRectangle(topLeft.x + 1, topLeft.y + kButtonSize,
										topLeft.x + 2 + 3 + tooltipLength,
										topLeft.y + kButtonSize + 4 + tooltipHeight,
										true);
					
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
					draw_text(topLeft.x + 3, topLeft.y + kButtonSize + 2, element.m_tooltip);
				}
			}
			// Draw spacer
			else
			{
				draw_set_color(c_gray);
				DrawSpriteLine(topLeft.x + floor(kSpacerSize / 2), topLeft.y + 1, topLeft.x + floor(kSpacerSize / 2), topLeft.y + kButtonSize - 1);
			}
			
			// Advance cursor.
			topLeft.x += (element.m_isButton || has_text) ? (kButtonSize + extra_width) : kSpacerSize;
		}
	};
}

/// @function AToolbarElementAsButtonInfo2(sprite, spriteIndex, tooltip, text, onClick, onCheckDown, onCanClick)
/// @param {Sprite} UI Icon
/// @param {Real} UI Icon image_index
/// @param {String} Hover tooltip
/// @param {String} Text to add
/// @param {Function} onClick callback
/// @param {Function} onCheckDown callback
function AToolbarElementAsButtonInfo2(sprite, spriteIndex, tooltip, text, onClick, onCheckDown, onCanClick=null)
{
	element = new AToolbarElement();
	element.m_isButton = true;
	element.m_onClick = onClick;
	element.m_onCheckDown = onCheckDown;
	element.m_onCanClick = onCanClick;
	element.m_sprite = sprite;
	element.m_spriteIndex = spriteIndex;
	element.m_tooltip = tooltip;
	element.m_text = text;
	return element;
}