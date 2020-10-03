function dcmdParseGiveItem(argument0, argument1) {
	var l_parserMode = argument0;
	var l_commandSplit = argument1;

	if (l_parserMode == kCmdlineParserModeWork)
	{	
		var cmd_count = array_length_1d(l_commandSplit);
	
		if (cmd_count == 1)
		{
			debugOut("giveitem itemname count");
		}
		else if (cmd_count >= 2)
		{
			// Get item count
			var item_count = 1;
			if (cmd_count >= 3)
			{
				var item_count_string = string_digits(l_commandSplit[2]);
				if (string_length(item_count_string) <= 0)
				{
					debugOut("Invalid item count value.");
					return 0;
				}
				item_count = real(item_count_string);
			}
		
			// Find item with matching name
			var item = null;
			var item_name = string_lower(l_commandSplit[1]);
			for (var i = 0; i < 9999; ++i)
			{
				if (object_exists(i))
				{
					var test_object_name = string_lower(object_get_name(i));
					if (string_pos("o_pickup", test_object_name) != 0)
					{
						if (string_pos(item_name, test_object_name) != 0)
						{
							item = i;
						}
					}
				}
			}
		
			if (item != null)
			{
				var pl = getPlayer();
				repeat (item_count)
				{
					instance_create_depth(pl.x, pl.y, pl.depth, item);
				}
			
				debugOut("Gave " + string(item_count) + " item \"" + item_name);
			}
			else
			{
				debugOut("No matching item \"" + item_name + "\"");
			}
		}
		return 0;
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
