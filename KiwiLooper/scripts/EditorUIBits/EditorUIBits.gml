/// @function AToolbar() constructor
/// @notes A toolbar for rendering a vertical selection menu.
function AToolbar() constructor
{
	kButtonSize		= 22;
	kSpacerSize		= 3;
	kTooltipShowTime= 0.5;
	
	m_elements		= [];
	m_elementsCount	= 0;
	m_elementsHeight= 0;
	
	m_state_containsMouse	= false;
	
	x = 0;
	y = 0;
	
	static AddElement = function(elementToAdd)
	{
		m_elements[m_elementsCount] = elementToAdd;
		m_elementsCount = array_length(m_elements);
		
		return elementToAdd;
	};
	
	static Step = function(mouseX, mouseY)
	{
		m_state_containsMouse = false;
		
		var topLeft = new Vector2(x, y);
		for (var elementIndex = 0; elementIndex < m_elementsCount; ++elementIndex)
		{
			var element = m_elements[elementIndex];
			
			// Check if mouse is inside
			if (element.m_isButton)
			{
				element.m_state_isDown = element.m_onCheckDown();
				
				if (point_in_rectangle(mouseX, mouseY, topLeft.x, topLeft.y, topLeft.x + kButtonSize, topLeft.y + kButtonSize))
				{
					element.m_state_isHovered = true;
					element.m_state_hoveredTime += Time.deltaTime;
					if (element.m_state_hoveredTime > kTooltipShowTime)
					{
						element.m_state_showTooltip = true;
					}
					
					if (mouse_check_button_pressed(mb_left))
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
			
			// Advance cursor.
			topLeft.y += element.m_isButton ? kButtonSize : kSpacerSize;
		}
		m_elementsHeight = topLeft.y - y;
	}
	
	static ContainsMouse = function()
	{
		return m_state_containsMouse;
	}
	
	static Draw = function()
	{
		draw_set_alpha(1.0);
		
		var topLeft = new Vector2(x, y);
		for (var elementIndex = 0; elementIndex < m_elementsCount; ++elementIndex)
		{
			var element = m_elements[elementIndex];
			
			// Check if mouse is inside
			if (element.m_isButton)
			{
				draw_set_color(element.m_state_isHovered ? c_white : c_gray);
				DrawSpriteRectangle(topLeft.x, topLeft.y,
									topLeft.x + kButtonSize, topLeft.y + kButtonSize,
									true);
				if (element.m_state_isDown)
				{
					draw_set_color(c_gray);
					DrawSpriteRectangle(topLeft.x, topLeft.y,
										topLeft.x + kButtonSize, topLeft.y + kButtonSize,
										false);
				}
				
				draw_sprite(element.m_sprite, element.m_spriteIndex, topLeft.x + 1, topLeft.y + 1);
				
				if (element.m_state_showTooltip)
				{
					draw_set_font(f_04b03);
					var tooltipLength = string_width(element.m_tooltip);
					var tooltipHeight = string_height(element.m_tooltip);
					
					draw_set_color(c_black);
					DrawSpriteRectangle(topLeft.x + kButtonSize + 1, topLeft.y,
										topLeft.x + kButtonSize + 2 + 3 + tooltipLength,
										topLeft.y + 4 + tooltipHeight,
										false);
					draw_set_color(c_white);
					DrawSpriteRectangle(topLeft.x + kButtonSize + 1, topLeft.y,
										topLeft.x + kButtonSize + 2 + 3 + tooltipLength,
										topLeft.y + 4 + tooltipHeight,
										true);
					
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
					draw_text(topLeft.x + kButtonSize + 3, topLeft.y + 2, element.m_tooltip);
				}
			}
			else
			{
				draw_set_color(c_gray);
				DrawSpriteLine(topLeft.x + 1, topLeft.y + 1, topLeft.x + kButtonSize - 1, topLeft.y + 1);
			}
			
			// Advance cursor.
			topLeft.y += element.m_isButton ? kButtonSize : kSpacerSize;
		}
	};
}
/// @function AToolbarElement() constructor
/// @notes A toolbar element for the AToolbar structure
function AToolbarElement() constructor
{
	m_isButton		= false; // If false, then is a separator.
	m_onClick		= function() {};
	m_onCheckDown	= function() { return false; };
	m_sprite		= sui_handy;
	m_spriteIndex	= 0;
	m_tooltip		= "Handy";
	
	m_state_isHovered	= false;
	m_state_hoveredTime	= 0.0;
	m_state_showTooltip	= false;
	m_state_isDown		= false;
	
	m_editor		= instance_find(ot_EditorTest, 0);
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
			m_editor.toolCurrent = m_local_editorState;
		};
		m_onCheckDown = function()
		{
			return m_editor.toolCurrent == m_local_editorState;
		};
	}
	return button;
}