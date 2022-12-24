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