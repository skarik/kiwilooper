function dcmdParseSet(argument0, argument1) {
	var l_parserMode = argument0;
	var l_commandSplit = argument1;

	if (l_parserMode == kCmdlineParserModeWork)
	{	
		var cmd_count = array_length_1d(l_commandSplit);
	
		if (cmd_count == 1)
		{
			debugOut("set flagId value");
		}
		else if (cmd_count == 2)
		{
			// Find the named flag with the same name
			var flag_id = ds_map_find_value(global.ctsBackend_QuestIds, l_commandSplit[1]);
			var flag_value = questGetValue(flag_id);
		
			debugOut("Current flag \"" + string(flag_id) + "\" is \"" + string(flag_value) + "\"");
		}
		else if (cmd_count >= 3)
		{
			// Find the named flag with the same name
			var flag_id = ds_map_find_value(global.ctsBackend_QuestIds, l_commandSplit[1]);
			var flag_value_string = string_digits(l_commandSplit[2]);
			if (string_length(flag_value_string) <= 0)
			{
				debugOut("Invalid set value.");
				return 0;
			}
			var flag_value = real(flag_value_string);
	
			if (!is_undefined(flag_id))
			{
				questSetValue(flag_id, flag_value);
				debugOut("Setting flag \"" + string(flag_id) + "\" to value \"" + string(flag_value) + "\"");
			}
			return 0;
		}
	}
	else if (l_parserMode == kCmdlineParserModeSuggest)
	{
		return [];
	}
	else if (l_parserMode == kCmdlineParserModeAutocomplete)
	{
		return [];
	}


}
