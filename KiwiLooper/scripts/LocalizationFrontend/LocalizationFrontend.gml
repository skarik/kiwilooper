/// @function loc_text(key_or_text, text=undefined)
/// @param key_or_text {String} - Key, or text to localize if autokeying
/// @param text {String} - Text to localize if Key is defined
function loc_text(key_or_text, text=undefined)
{
	gml_pragma("forceinline");
	
	var l_key = key_or_text;
	var l_text = text;
	// One-argument variant with auto-key
	if (is_undefined(l_text))
	{
		l_key = object_get_name(object_index);
		l_text = key_or_text;
	}
	
	return l_text;
}