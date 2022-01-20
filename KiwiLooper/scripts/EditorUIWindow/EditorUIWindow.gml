/// @function AEditorWindow() constructor
/// @desc Base class for a window.
function AEditorWindow() constructor
{
	static kTitleHeight = 12;
	static kTitleMargin = 2;
	static kAccentColor = make_color_rgb(200, 40, 200);
	
	#macro kWindowMousePositionNone 0
	#macro kWindowMousePositionTitle 1
	#macro kWindowMousePositionContent 2
	
	m_title = "Window";
	m_modal = false; // Is this an interrupting dialog?
	m_canClose = false;
	
	m_editor = null;
	m_position = new Vector2(0, kTitleHeight);
	m_size = new Vector2(100, 100);
	
	request_free = false; // Has been requested to be deleted?
	
	disabled = false;
	focused = false;
	contains_mouse = false;
	mouse_position = kWindowMousePositionNone;
	dragging = false;
	has_stored_position = false;
	
	static onMouseMove = function(mouseX, mouseY) {}
	static onMouseEvent = function(mouseX, mouseY, button, event) {}
	static onMouseLeave = function(mouseX, mouseY) {}
	static Step = function() {}
	static Draw = function()
	{
		drawWindow();
	}
	
	static drawWindow = function()
	{
		var rect = [m_position.x - 1, m_position.y - kTitleHeight, m_position.x + m_size.x + 1, m_position.y + m_size.y + 1];
		
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
	
	windowDragging = false;
	windowSavedPositions = [];
	
	WindowingContainsMouse = function()
	{
		// Assume we're always taking the mouse if dragging
		if (windowDragging)
		{
			return true;
		}
		// Check all windows after
		for (var i = 0; i < array_length(windows); ++i)
		{
			if (windows[i].ContainsMouse())
			{
				return true;
			}
		}
		return false;
	}
	WindowingHasFocus = function()
	{
		// Check all windows
		for (var i = 0; i < array_length(windows); ++i)
		{
			if (windows[i].focused)
			{
				return true;
			}
		}
		return false;
	}
	
	this.EditorWindowAlloc = EditorWindowAlloc;
	this.EditorWindowFree = EditorWindowFree;
	this.EditorWindowSetFocus = EditorWindowSetFocus;
}

/// @function EditorWindowAlloc(type)
/// @desc Creates a new instance of the given window and adds it to update queue.
function EditorWindowAlloc(type)
{
	var window = new type();
	
	// Store class type for future ref
	window.classType = type;
	// Store calling editor
	window.m_editor = id;
	
	// Pull saved position by class
	for (var i = 0; i < array_length(windowSavedPositions); ++i)
	{
		if (windowSavedPositions[i][0] == window.classType)
		{
			window.m_position.copyFrom(windowSavedPositions[i][1]);
			window.has_stored_position = true;
			break;
		}
	}
	
	array_push(windows, window);
	return window;
}
/// @function EditorWindowFree(window)
/// @desc Requests a deferred deletion of the given window.
function EditorWindowFree(window)
{
	if (is_struct(window))
	{
		// Add unique entry for the window position
		var saveWindowPosition = function(window)
		{
			for (var i = 0; i < array_length(windowSavedPositions); ++i)
			{
				if (windowSavedPositions[i][0] == window.classType)
				{
					windowSavedPositions[i][1].copyFrom(window.m_position);
					return;
				}
			}
			array_push(windowSavedPositions, [window.classType, window.m_position.copy()]);
		};
		saveWindowPosition(window);
		
		// Disable window & request free
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
		
		// Ensure the window is at the end of the windowing list so it draws on top.
		if (windowCurrent != windows[array_length(windows) - 1])
		{
			ce_array_swap(windows, array_get_index(windows, windowCurrent), array_length(windows) - 1);
		}
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
				check_window.m_position.x, check_window.m_position.y - check_window.kTitleHeight,
				check_window.m_position.x + check_window.m_size.x, check_window.m_position.y + check_window.m_size.y))
		{
			check_window.contains_mouse = true;
			hovered_window = check_window;
			
			check_window.mouse_position = (mouseY < check_window.m_position.y) ? kWindowMousePositionTitle : kWindowMousePositionContent;
		}
		else
		{
			if (check_window.contains_mouse)
			{
				check_window.onMouseLeave(mouseX, mouseY);
			}
			check_window.contains_mouse = false;
			check_window.mouse_position = kWindowMousePositionNone;
		}
	}
	
	// On clicks, update the focus window
	if (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right) || mouse_check_button_pressed(mb_middle))
	{
		EditorWindowSetFocus(hovered_window);
	}
	
	// Update dragging
	if (!windowDragging)
	{
		if (is_struct(windowCurrent) && windowCurrent.mouse_position == kWindowMousePositionTitle)
		{
			if (mouse_check_button_pressed(mb_left))
			{
				windowDragging = true;
				windowCurrent.dragging = true;
			}
		}
	}
	else
	{
		if (is_struct(windowCurrent))
		{
			// Move window around
			windowCurrent.m_position.x += uPosition - uPositionPrevious;
			windowCurrent.m_position.y += vPosition - vPositionPrevious;
			
			// Check for dragging stop
			if (mouse_check_button_released(mb_left))
			{
				windowDragging = false;
				windowCurrent.dragging = false;
			}
		}
		else
		{
			windowDragging = false;
		}
	}
	
	// Poll and forward mouse states:
	var mouse_buttons = [mb_left, mb_right, mb_middle];
	for (var iButton = 0; iButton < array_length(mouse_buttons); ++iButton)
	{
		// TODO: only call on the active window?
		var currentButton = mouse_buttons[iButton];
		if (mouse_check_button_pressed(currentButton))
		{
			for (var iWindow = 0; iWindow < array_length(windows); ++iWindow)
			{
				var check_window = windows[iWindow];
				if (!check_window.disabled)
					check_window.onMouseEvent(mouseX, mouseY, currentButton, kEditorToolButtonStateMake);
			}
		}
		if (mouse_check_button_released(currentButton))
		{
			for (var iWindow = 0; iWindow < array_length(windows); ++iWindow)
			{
				var check_window = windows[iWindow];
				if (!check_window.disabled)
					check_window.onMouseEvent(mouseX, mouseY, currentButton, kEditorToolButtonStateBreak);
			}
		}
		if (mouse_check_button(currentButton))
		{
			for (var iWindow = 0; iWindow < array_length(windows); ++iWindow)
			{
				var check_window = windows[iWindow];
				if (!check_window.disabled)
					check_window.onMouseEvent(mouseX, mouseY, currentButton, kEditorToolButtonStateHeld);
			}
		}
	}
	
	// Step all windows now
	for (var iWindow = 0; iWindow < array_length(windows); ++iWindow)
	{
		var check_window = windows[iWindow];
		if (!check_window.disabled)
		{
			if (check_window.contains_mouse)
			{
				check_window.onMouseMove(mouseX, mouseY);
			}
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