/// @function AEditorWindowDialog() constructor
/// @desc A choice dialog box. Attempts to be modal.
function AEditorWindowDialog() : AEditorWindow() constructor
{
	/// @function AChoice(text, func, closeOnClick = true)
	static AChoice = function(in_text, in_func, in_closeOnClick = true) constructor
	{
		text = in_text;
		func = in_func;
		bCloseOnClick = in_closeOnClick;
	};
	
	
	m_title = "";
	m_modal = true; // TODO: check m_modal in the windowing system
	
	m_size.x = 140;
	m_size.y = 60;
	
	// Center the window
	m_position.x = round((GameCamera.width - m_size.x) / 2);
	m_position.y = round((GameCamera.height - m_size.y) / 2);
	
	// Set up items for buttons
	item_focused = null;
	item_mouseover = null;
	item_mousedown = false;
	
	// Choices that can be clicked
	choices = [];
	// Text content of the window above
	content = "";
	
	
	static sh_uScissorRect = shader_get_uniform(sh_editorDefaultScissor, "uScissorRect");
	static kButtonWidth = 40;
	static kButtonHeight = 25;
	static kContentMargin = 5;
	
	
	/// @function AddChoice(choice)
	/// @param {AChoice} choice
	static AddChoice = function(choice)
	{
		array_push(choices, choice);
	}
	
	
	static parent_Open = Open;
	static Open = function()
	{
		if (array_length(choices) == 0)
		{
			AddChoice(new AChoice("OK", null, true));
		}
		parent_Open();
		with (m_editor)
		{
			EditorWindowSignalModalStart();
		}
	};
	
	static parent_Close = Close;
	static Close = function()
	{
		with (m_editor)
		{
			EditorWindowSignalModalEnd();
		}
		parent_Close();
	}
	
	static ConsumesFocus = function()
	{
		return item_mousedown;
	}
	
	static onMouseMove = function(mouseX, mouseY)
	{
		if (mouse_position == kWindowMousePositionContent)
		{
			item_mouseover = null;
			
			// Check buttons
			var button_count = array_length(choices);
			var button_total_w = kButtonWidth * button_count + kContentMargin * (button_count - 1);
			var start_x = m_position.x + (m_size.x - button_total_w) / 2;
			var start_y = m_position.y + m_size.y - kContentMargin - kButtonHeight;
			for (var i = 0; i < button_count; ++i)
			{
				var current_x = start_x + (kButtonWidth + kContentMargin) * i;
				
				if (point_in_rectangle(mouseX, mouseY, current_x, start_y, current_x + kButtonWidth, start_y + kButtonHeight))
				{
					item_mouseover = i;
				}
			}
		}
		else
		{
			item_mouseover = null;
		}
	}
	static onMouseLeave = function(mouseX, mouseY)
	{
		item_mouseover = null;
	}
	static onMouseEvent = function(mouseX, mouseY, button, event)
	{
		if ((event & kEditorToolButtonStateMake) && mouse_position == kWindowMousePositionContent)
		{
			if (item_mouseover != null)
			{
				// Begin clicking
				item_focused = item_mouseover;
				item_mousedown = true;
			}
			else
			{
				// Nothing to click on
				item_focused = null;
			}
		}
		else if ((event & kEditorToolButtonStateBreak))
		{
			if (item_mousedown)
			{
				item_mousedown = false;
				
				// Perform the action on the given button
				if (item_mouseover != null)
				{
					// Work on the callback
					var choice = choices[item_mouseover];
					if (choice.func != null)
					{
						choice.func();
					}
					if (choice.bCloseOnClick)
					{
						Close();
						request_free = true; // Request free as well, we want this DELETED
					}
				}
			}
		}
	}
	
	static Draw = function()
	{
		drawWindow();
		
		// Draw content
		draw_set_color(focused ? c_white : c_gray);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(f_04b03);
		draw_text_ext(m_position.x + kContentMargin, m_position.y + kContentMargin, content, -1, m_size.x - kContentMargin * 2);
		
		// Draw buttons
		var button_count = array_length(choices);
		var button_total_w = kButtonWidth * button_count + kContentMargin * (button_count - 1);
		var start_x = m_position.x + (m_size.x - button_total_w) / 2;
		var start_y = m_position.y + m_size.y - kContentMargin - kButtonHeight;
		for (var i = 0; i < button_count; ++i)
		{
			var current_x = start_x + (kButtonWidth + kContentMargin) * i;
			
			// draw background
			draw_set_color((item_mouseover == i) ? kAccentColor : kFocusedBGColor);
			draw_rectangle(current_x, start_y, current_x + kButtonWidth, start_y + kButtonHeight, false);
			
			// draw focus outline
			draw_set_color((item_focused == i) ? (item_mousedown ? c_white : kAccentColor) : kFocusedBGColor);
			draw_rectangle(current_x, start_y, current_x + kButtonWidth, start_y + kButtonHeight, true);
			
			// draw the text
			draw_set_color(focused ? c_white : c_gray);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_font(f_04b03);
			draw_text(current_x + kButtonWidth * 0.5, start_y + kButtonHeight * 0.5, choices[i].text);
		}
	}
}
