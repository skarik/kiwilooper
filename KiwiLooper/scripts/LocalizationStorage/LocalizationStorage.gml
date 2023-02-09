/// @function localizationInit(language_code)
function localizationInit(language_code)
{
	// For now we don't really do anything
	
	// BUT we do have the language file loading done!
	// (OSF, Valve KV format rules)
	
	
	global._localization_total_table = ds_map_create();
	
	// Read in all the lines in the translation file
	var loc_file = buffer_load("lang/" + language_code + ".txt");
	if (buffer_exists(loc_file))
	{
		var l_currentGroup = "";
		var l_currentGroupMap = undefined;
		
		var l_eof = false;
		while (!l_eof)
		{
			// Read line-by-line
			var line = buffer_read_string_line(loc_file);
			
			// Trim the starting space (OSF format, Valve Key-Value rules)
			var trimmed_line = string_ltrim(string_rtrim(line));
			
			// Are we looking for a group to start?
			if (l_currentGroup == "" || is_undefined(l_currentGroupMap))
			{
				// Read in line from " to "
				var value_start = string_pos(trimmed_line, "\"");
				var value_end = string_last_pos(trimmed_line, "\"");
				if (value_start != 0 && value_end > value_start + 1)
				{
					l_currentGroup = string_copy(trimmed_line, value_start, value_end - value_start);
					l_currentGroupMap = global._localization_total_table[?l_currentGroup];
					if (is_undefined(l_currentGroupMap))
					{
						l_currentGroupMap = ds_map_create();
						global._localization_total_table[?l_currentGroup] = l_currentGroupMap;
					}
				}
				
				// Now read in character-by-character looking for the {
				while (!l_eof && ansi_char(buffer_read(loc_file, buffer_u8)) != "{")
				{
					// Check for end of buffer
					l_eof = buffer_tell(loc_file) >= buffer_get_size(loc_file);
				}
			}
			// Inside group, load key-values
			else
			{
				var key_start	= string_pos(trimmed_line, "\"");
				var key_end		= string_pos_ext(trimmed_line, "\"", key_start + 1);
				var value_start	= string_pos_ext(trimmed_line, "\"", key_end + 1);
				var value_end	= string_pos_ext(trimmed_line, "\"", value_start + 1);
				
				if (key_start != 0 && key_end != 0 && value_start != 0 && value_end != 0)
				{
					var l_key = string_copy(trimmed_line, key_start, key_end - key_start);
					var l_value = string_copy(trimmed_line, value_start, value_end - value_start);
					
					l_currentGroupMap[?l_key] = l_value;
				}
				
				// If there was a } in the string, then we exit
				var end_brace = string_pos_ext(trimmed_line, "}", value_end + 1);
				if (end_brace != 0)
				{
					l_currentGroup = "";
					l_currentGroupMap = undefined;
				}
			}
			
			// Check for end of buffer
			l_eof = buffer_tell(loc_file) >= buffer_get_size(loc_file);
		}
		
		buffer_delete(loc_file);
	}
}