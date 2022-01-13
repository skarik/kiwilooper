/// @function AEditorWindow() constructor
/// @desc Base class for a window.
function AEditorWindow() constructor
{
	static kTitleHeight = 12;
	static kTitleMargin = 2;
	static kAccentColor = make_color_rgb(200, 40, 200);
	
	m_title = "Window";
	m_modal = false; // Is this an interrupting dialog?
	m_canClose = false;
	
	m_position = new Vector2(0, kTitleHeight);
	m_size = new Vector2(100, 100);
	
	request_free = false; // Has been requested to be deleted?
	
	disabled = false;
	focused = false;
	contains_mouse = false;
	
	static Step = function() {}
	static Draw = function()
	{
		drawWindow();
	}
	
	static drawWindow = function()
	{
		var rect = [m_position.x, m_position.y - kTitleHeight, m_position.x + m_size.x, m_position.y + m_size.y];
		
		// Draw the background for the window
		draw_set_color(focused ? c_black : c_dkgray);
		DrawSpriteRectangle(rect[0], rect[1], rect[2], rect[3], false);
		
		// Draw the title bar
		{
			draw_set_color(focused ? kAccentColor : c_white);
			DrawSpriteRectangle(rect[0], rect[1], rect[2], rect[1] + kTitleHeight, false);
		
			// Draw the title on the far left
			draw_set_color(focused ? c_white : c_gray);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(f_04b03);
			draw_text(rect[0] + kTitleMargin, rect[1] + kTitleMargin, m_title);
			
			// Draw the exit button on the far right
			draw_set_color(focused ? c_white : c_gray);
			DrawSpriteRectangle(rect[2] - kTitleHeight, rect[1], rect[2], rect[1] + kTitleHeight, true);
			draw_text(rect[2] - kTitleHeight + kTitleMargin, rect[1] + kTitleMargin, "X");
		}
		
		// Draw the outline around the window.
		draw_set_color(focused ? c_white : c_gray);
		DrawSpriteRectangle(rect[0], rect[1], rect[2], rect[3], true);
	}
	
	static ContainsMouse = function()
	{
		return contains_mouse;
	}
}

function EditorWindowingSetup()
{
	windowCurrent = null;
	windows = [];
	
	WindowingContainsMouse = function()
	{
		for (var i = 0; i < array_length(windows); ++i)
		{
			if (windows[i].ContainsMouse())
			{
				return true;
			}
		}
		return false;
	}
}

/// @function EditorWindowAlloc(type)
/// @desc Creates a new instance of the given window and adds it to update queue.
function EditorWindowAlloc(type)
{
	var window = new type();
	array_push(windows, window);
	return window;
}
/// @function EditorWindowFree(window)
/// @desc Requests a deferred deletion of the given window.
function EditorWindowFree(window)
{
	if (is_struct(window))
	{
		window.request_free = true;
		window.disabled = true;
	}
}
/// @function EditorWindowSetFocus(window)
/// @desc Sets the window as the main focused one
function EditorWindowSetFocus(window)
{
	// Update which windows have focus or not
	if (is_struct(windowCurrent) && windowCurrent != window)
	{
		windowCurrent.focused = false;
	}
	// Update the current hovered window now
	if (is_struct(window))
	{
		windowCurrent = window;
		windowCurrent.focused = true;
	}
}

function EditorWindowingUpdate(mouseX, mouseY)
{
	var hovered_window = null;
	
	// Start with request free
	for (var iWindow = 0; iWindow < array_length(windows); ++iWindow)
	{
		var check_window = windows[iWindow];
		if (check_window.request_free)
		{
			array_delete(windows, iWindow, 1);
			delete check_window;
			
			iWindow -= 1;
			continue;
		}
	}
	
	// Find the window that the mouse hovers over & update mouseover checks.
	for (var iWindow = 0; iWindow < array_length(windows); ++iWindow)
	{
		var check_window = windows[iWindow];
		if (point_in_rectangle(mouseX, mouseY,
				check_window.m_position.x, check_window.m_position.y,
				check_window.m_position.x + check_window.m_size.x, check_window.m_position.y + check_window.m_size.y))
		{
			check_window.contains_mouse = true;
			hovered_window = check_window;
		}
		else
		{
			check_window.contains_mouse = false;
		}
	}
	
	// On clicks, update the focus window
	if (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right) || mouse_check_button_pressed(mb_middle))
	{
		EditorWindowSetFocus(hovered_window);
	}
	
	// Step all windows now
	for (var iWindow = 0; iWindow < array_length(windows); ++iWindow)
	{
		var check_window = windows[iWindow];
		if (!check_window.disabled)
		{
			check_window.Step();
		}
		// If disabled, we want to kill certain states
		else
		{
			check_window.focused = false;
			check_window.contains_mouse = false;
		}
	}
}

function EditorWindowingDraw()
{
	for (var iWindow = 0; iWindow < array_length(windows); ++iWindow)
	{
		var check_window = windows[iWindow];
		check_window.Draw();
	}
}