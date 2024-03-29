#macro EXECUTE_CONDITIONAL var _ =

/// @function AToolbar() constructor
/// @notes A toolbar for rendering a vertical selection menu.
function AToolbar() constructor
{
	static kButtonSize		= 22;
	static kButtonPadding	= 0;
	static kButtonMargin	= 0;
	static kSpacerSize		= 3;
	static kTooltipShowTime	= 0.5;
	static kTextPadding		= 0;
	static kBarDirection	= kDirDown;
	
	m_elements		= [];
	m_elementsCount	= 0;
	m_elementsHeight= 0;
	m_elementsWidth = 0;
	
	m_state_containsMouse	= false;
	
	x = 0;
	y = 0;
	
	static GetHeight = function()
	{
		return m_elementsHeight;
	}
	static GetWidth = function()
	{
		return m_elementsWidth;
	}
	
	static AddElement = function(elementToAdd)
	{
		m_elements[m_elementsCount] = elementToAdd;
		m_elementsCount = array_length(m_elements);
		
		return elementToAdd;
	};
	
	static Step = function(mouseX, mouseY, mouseAvailable)
	{
		m_state_containsMouse = false;
		
		var ui_scale = EditorGetUIScale();
		
		// Set font for checking widths
		draw_set_font(EditorGetUIFont());
		
		var topLeft = new Vector2(x, y);
		for (var elementIndex = 0; elementIndex < m_elementsCount; ++elementIndex)
		{
			var element = m_elements[elementIndex];
			topLeft.y = floor(topLeft.y);
			
			// Get element extra width that text adds
			var extra_width = 0;
			var extra_height = 0;
			var has_text = is_string(element.m_text);
			if (has_text)
			{
				extra_width = (element.m_width > 0) ? element.m_width * ui_scale : (kTextPadding * 2 + string_width(element.m_text));
			}
			
			var bIsLabel = !element.m_isButton && has_text;
			
			// Set up the layout rect
			element.layout_rect.m_min.x = topLeft.x;
			element.layout_rect.m_min.y = topLeft.y;
			element.layout_rect.m_max.x = (element.m_isButton || bIsLabel) ? topLeft.x + kButtonSize * ui_scale + extra_width : kSpacerSize;
			element.layout_rect.m_max.y = (element.m_isButton || bIsLabel) ? topLeft.y + kButtonSize * ui_scale : kSpacerSize;
			
			// Update enabled state
			element.m_state_isEnabled = (element.m_onCanClick == null) ? true : element.m_onCanClick();
			
			// Check if mouse is inside
			if ((element.m_isButton || bIsLabel) && element.m_state_isEnabled)
			{
				element.m_state_isDown = (element.m_onCheckDown == null) ? false : element.m_onCheckDown();
				
				if (mouseAvailable && element.layout_rect.containsSubEdge(mouseX, mouseY, 0, 0, 1, 1))
				{
					element.m_state_isHovered = true;
					element.m_state_hoveredTime += Time.deltaTime;
					if (element.m_state_hoveredTime > kTooltipShowTime)
					{
						element.m_state_showTooltip = true;
					}
					
					if (element.m_isButton && mouse_check_button_pressed(mb_left))
					{
						EXECUTE_CONDITIONAL element.m_richParams
							? element.m_onClick(mouseX, mouseY)
							: element.m_onClick();
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
			
			// Run step if we have one
			if (element.m_stepEnabled)
			{
				element.m_onStep(mouseX, mouseY);
			}
			
			// Advance cursor.
			if (kBarDirection == kDirRight)
			{
				topLeft.x += (element.m_isButton || bIsLabel) ? ((kButtonSize + kButtonMargin) * ui_scale + extra_width) : kSpacerSize;
			}
			else if (kBarDirection == kDirDown)
			{
				topLeft.y += (element.m_isButton || bIsLabel) ? ((kButtonSize + kButtonMargin) * ui_scale + extra_height) : kSpacerSize;
			}
		}
		m_elementsWidth = (kBarDirection == kDirRight) ? (topLeft.x - x) : (kButtonSize * ui_scale); // This is incorrect but is OK since we dont layout macro elements horizontally
		m_elementsHeight = (kBarDirection == kDirDown) ? (topLeft.y - y) : (kButtonSize * ui_scale);
	}
	
	static ContainsMouse = function()
	{
		return m_state_containsMouse;
	}
	
	static Draw = function()
	{
		draw_set_alpha(1.0);
		
		var ui_scale = EditorGetUIScale();
		
		var topLeft = new Vector2(0, 0);
		for (var elementIndex = 0; elementIndex < m_elementsCount; ++elementIndex)
		{
			var element = m_elements[elementIndex];
			
			// Pull position from the layout system.
			topLeft.copyFrom(element.layout_rect.m_min);
			topLeft.floorSelf();
			
			// Get element extra width that text adds
			var has_text = is_string(element.m_text);
			
			// Cache if have sprite
			var has_sprite = sprite_exists(element.m_sprite);
			
			// Draw custom
			if (element.m_customDraw)
			{
				element.m_onDraw(topLeft.x, topLeft.y);
			}
			// Draw button
			else if (element.m_isButton)
			{
				if (element.m_state_isDown)
				{
					draw_set_color(c_gray);
					DrawSpriteRectangle(topLeft.x, topLeft.y,
										element.layout_rect.m_max.x, element.layout_rect.m_max.y,
										false);
				}
				draw_set_color((element.m_state_isHovered && element.m_state_isEnabled) ? c_white : c_gray);
				DrawSpriteRectangle(topLeft.x, topLeft.y,
									element.layout_rect.m_max.x, element.layout_rect.m_max.y,
									true);
				
				if (has_sprite)
				{
					draw_sprite_ext(element.m_sprite, element.m_spriteIndex,
									topLeft.x + 1 + kButtonPadding * ui_scale,
									topLeft.y + 1 + kButtonPadding * ui_scale,
									ui_scale,ui_scale,0,
									element.m_state_isEnabled ? c_white : c_gray,
									1.0);
				}
				
				if (has_text)
				{
					draw_set_font(EditorGetUIFont());
					draw_set_color(element.m_state_isEnabled ? c_white : c_gray);
					draw_set_halign(fa_left);
					draw_set_valign(fa_middle);
					draw_text(topLeft.x + kButtonSize * ui_scale + kTextPadding - 1, topLeft.y + 1 + kButtonSize / 2 * ui_scale, element.m_text);
				}
				
				if (element.m_state_showTooltip)
				{
					draw_set_font(EditorGetUIFont());
					var tooltipLength = string_width(element.m_tooltip);
					var tooltipHeight = string_height(element.m_tooltip);
					
					var tooltipCorner_x;
					var tooltipCorner_y;
					if (kBarDirection == kDirDown)
					{
						tooltipCorner_x = topLeft.x + kButtonSize * ui_scale + 1;
						tooltipCorner_y = topLeft.y;
					}
					else if (kBarDirection == kDirRight)
					{
						tooltipCorner_x = topLeft.x + 1;
						tooltipCorner_y = topLeft.y + kButtonSize * ui_scale + 1;
					}
					
					draw_set_color(c_black);
					DrawSpriteRectangle(tooltipCorner_x, tooltipCorner_y,
										tooltipCorner_x + 1 + 3 + tooltipLength,
										tooltipCorner_y + 1 + 3 + tooltipHeight,
										false);
					draw_set_color(c_white);
					DrawSpriteRectangle(tooltipCorner_x, tooltipCorner_y,
										tooltipCorner_x + 1 + 3 + tooltipLength,
										tooltipCorner_y + 1 + 3 + tooltipHeight,
										true);
					
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
					draw_text(tooltipCorner_x + 2, tooltipCorner_y + 2, element.m_tooltip);
				}
			}
			// Draw label
			else if (has_text)
			{
				// TODO: This does not work with vertical layout. Needs a new setup for it.
				
				if (has_sprite)
				{
					draw_sprite(element.m_sprite, element.m_spriteIndex, topLeft.x + 1 + kButtonPadding, topLeft.y + 1 + kButtonPadding);
				}
				
				if (has_text)
				{
					draw_set_font(EditorGetUIFont());
					draw_set_color(c_white);
					draw_set_halign(fa_left);
					draw_set_valign(fa_middle);
					draw_text(topLeft.x + kTextPadding, topLeft.y + 1 + kButtonSize / 2 * ui_scale, element.m_text);
				}
				
				if (element.m_state_showTooltip)
				{
					draw_set_font(EditorGetUIFont());
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
					draw_text(topLeft.x + 3, topLeft.y + kButtonSize * ui_scale + 2, element.m_tooltip);
				}
			}
			// Draw spacer
			else
			{
				draw_set_color(c_gray);
				if (kBarDirection == kDirRight)
				{
					DrawSpriteLine(topLeft.x + floor(kSpacerSize / 2), topLeft.y + 1, topLeft.x + floor(kSpacerSize / 2), topLeft.y + kButtonSize * ui_scale - 1);
				}
				else if (kBarDirection == kDirDown)
				{
					DrawSpriteLine(topLeft.x + 1, topLeft.y + 1, topLeft.x + kButtonSize * ui_scale - 1, topLeft.y + 1);
				}
			}
		}
	};
}
/// @function AToolbarElement() constructor
/// @notes A toolbar element for the AToolbar structure
function AToolbarElement() constructor
{
	m_isButton		= false; // If false, then is a separator or label.
	m_customDraw	= false; // Does this element have a custom draw?
	m_richParams	= false; // If true, then the callbacks will also be sent mouse position.
	m_stepEnabled	= false; // If true, then onStep will be called.
	m_onClick		= function() {};
	m_onCheckDown	= function() { return false; };
	m_onCanClick	= function() { return true; };
	m_onStep		= function(mouseX, mouseY) {};
	m_onDraw		= function(x, y) {};
	m_sprite		= sui_handy;
	m_spriteIndex	= 0;
	m_tooltip		= "Handy";
	m_text			= null;
	m_width			= -1;
	
	m_state_isHovered	= false;
	m_state_hoveredTime	= 0.0;
	m_state_showTooltip	= false;
	m_state_isDown		= false;
	m_state_isEnabled	= true;
	
	layout_rect		= new Rect2(new Vector2(0, 0), new Vector2(0, 0));
	
	m_editor		= EditorGet();
}
/// @function AToolbarElementAsButtonInfo(sprite, spriteIndex, tooltip, onClick, onCheckDown)
/// @param {Sprite} UI Icon
/// @param {Real} UI Icon image_index
/// @param {String} Hover tooltip
/// @param {Function} onClick callback
/// @param {Function} onCheckDown callback
function AToolbarElementAsButtonInfo(sprite, spriteIndex, tooltip, onClick, onCheckDown)
{
	element = new AToolbarElement();
	element.m_isButton = true;
	element.m_onClick = onClick;
	element.m_onCheckDown = onCheckDown;
	element.m_sprite = sprite;
	element.m_spriteIndex = spriteIndex;
	element.m_tooltip = tooltip;
	return element;
}
/// @function AToolbarElementAsToolButtonInfo(sprite, spriteIndex, tooltip, editorState)
/// @param {Sprite} UI Icon
/// @param {Real} UI Icon image_index
/// @param {String} Hover tooltip
/// @param {kEditorTool} Tool to check against
function AToolbarElementAsToolButtonInfo(sprite, spriteIndex, tooltip, editorState)
{
	var button = AToolbarElementAsButtonInfo(sprite, spriteIndex, tooltip, null, null);
	with (button)
	{
		m_local_editorState = editorState;
		m_onClick = function()
		{
			m_editor.toolCurrentRequested = m_local_editorState;
		};
		m_onCheckDown = function()
		{
			return m_editor.toolCurrentRequested == m_local_editorState;
		};
	}
	return button;
}
/// @function AToolbarElementAsSpacer()
function AToolbarElementAsSpacer()
{
	return new AToolbarElement();
}
/// @function AToolbarElementAsLabel(sprite, spriteIndex, tooltip, text, width)
function AToolbarElementAsLabel(sprite, spriteIndex, tooltip, text, width)
{
	element = new AToolbarElement();
	element.m_isButton = false;
	element.m_sprite = sprite;
	element.m_spriteIndex = spriteIndex;
	element.m_tooltip = tooltip;
	element.m_text = text;
	element.m_width = width;
	return element;
}
