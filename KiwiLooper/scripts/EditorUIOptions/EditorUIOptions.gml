// fuckity fuck fuck
function EditorGetUIScale()
{
	var editor = EditorGet();
	if (iexists(editor))
	{
		return editor.uiScale;
	}
	return 1.5;
}
function EditorGetUIFont()
{
	static current_scale		= 0.0;
	static last_loaded_font		= undefined;
	
	var scale = EditorGetUIScale();
	
	// If scale changes, we need to reload resources for rendering.
	if (current_scale != scale)
	{
		current_scale = scale;
		
		if (!is_undefined(last_loaded_font) && font_exists(last_loaded_font))
		{
			font_delete(last_loaded_font);
		}
		
		// Load new font.
		font_add_enable_aa(false);
		last_loaded_font = font_add("fonts/OpenSans-Regular.ttf", round(6 * scale), false, false, 32, 128);
	}
	
	if (scale <= 1.0)
	{
		return f_04b03;
	}
	else
	{
		return last_loaded_font;
	}
}

#macro kEditorSettingsFile "editor_settings.bin"
#macro kEditorSettingsVersion 0x000000

function EditorSettingsSave()
{
	var buffer = buffer_create(0, buffer_grow, 1);
	
	buffer_write(buffer, buffer_u64, kEditorSettingsVersion);
	
	// Get window settings
	var window_x = window_get_x();
	var window_y = window_get_y();
	var window_w = window_get_width();
	var window_h = window_get_height();
	buffer_write(buffer, buffer_u64, window_x);
	buffer_write(buffer, buffer_u64, window_y);
	buffer_write(buffer, buffer_u64, window_w);
	buffer_write(buffer, buffer_u64, window_h);
	
	// UI settings
	buffer_write(buffer, buffer_f64, uiScale);
	
	// Get sub-window settings
	var saved_position_count = array_length(windowSavedPositions);
	buffer_write(buffer, buffer_u64, saved_position_count);
	for (var i = 0; i < saved_position_count; ++i)
	{
		buffer_write(buffer, buffer_u64, windowSavedPositions[i][0]); // TODO: this value may not be same across versions
		buffer_write(buffer, buffer_s32, windowSavedPositions[i][1].x);
		buffer_write(buffer, buffer_s32, windowSavedPositions[i][1].y);
	}
	
	var saved_size_count = array_length(windowSavedSizes);
	buffer_write(buffer, buffer_u64, saved_size_count);
	for (var i = 0; i < saved_size_count; ++i)
	{
		buffer_write(buffer, buffer_u64, windowSavedSizes[i][0]); // TODO: this value may not be same across versions
		buffer_write(buffer, buffer_s32, windowSavedSizes[i][1].x);
		buffer_write(buffer, buffer_s32, windowSavedSizes[i][1].y);
	}
	
	// Save settings to disk in temp dir
	buffer_save(buffer, kEditorSettingsFile);
	buffer_delete(buffer);
}

function EditorSettingsLoad()
{
	var buffer = buffer_load(kEditorSettingsFile);
	if (!buffer_exists(buffer))
	{
		return;
	}
	
	// TODO: do something w/ editor version
	buffer_read(buffer, buffer_u64);
	
	// Get the window settings
	var window_x = buffer_read(buffer, buffer_u64);
	var window_y = buffer_read(buffer, buffer_u64);
	var window_w = buffer_read(buffer, buffer_u64);
	var window_h = buffer_read(buffer, buffer_u64);
	window_set_size(window_w, window_h);
	window_set_position(window_x, window_y);
	
	// UI Settings
	uiScale = buffer_read(buffer, buffer_f64);
	
	// Get the sub-window settings
	var saved_position_count = buffer_read(buffer, buffer_u64);
	for (var i = 0; i < saved_position_count; ++i)
	{
		var new_saved = array_create(2);
		new_saved[0] = buffer_read(buffer, buffer_u64);
		var new_saved_x = buffer_read(buffer, buffer_s32);
		var new_saved_y = buffer_read(buffer, buffer_s32);
		new_saved[1] = new Vector2(real(new_saved_x), real(new_saved_y));
		array_push(windowSavedPositions, new_saved);
	}
	
	var saved_size_count = buffer_read(buffer, buffer_u64);
	for (var i = 0; i < saved_size_count; ++i)
	{
		var new_saved = array_create(2);
		new_saved[0] = buffer_read(buffer, buffer_u64);
		var new_saved_x = buffer_read(buffer, buffer_s32);
		var new_saved_y = buffer_read(buffer, buffer_s32);
		new_saved[1] = new Vector2(real(new_saved_x), real(new_saved_y));
		array_push(windowSavedSizes, new_saved);
	}
	
	// And done!
	buffer_delete(buffer);
}