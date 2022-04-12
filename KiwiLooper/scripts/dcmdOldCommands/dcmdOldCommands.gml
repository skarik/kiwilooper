function dcmdParseGender(argument0, argument1) {
	var l_parserMode = argument0;
	var l_commandSplit = argument1;

	if (l_parserMode == kCmdlineParserModeWork)
	{	
		var cmd_count = array_length_1d(l_commandSplit);
	
		if (cmd_count == 1)
		{
			debugOut("gender value");
		}
		else if (cmd_count >= 2)
		{
			// Find the named flag with the same name
			var gender = real(l_commandSplit[1]);
		
			if (!iexists(o_PlayerStats))
			{
				inew(o_PlayerStats);
				o_PlayerStats.persistent = true;
			}
			o_PlayerStats.m_gender = gender;
			if (gender == kGenderFemale)
				o_PlayerStats.m_name = "Aurum";
			else if (gender == kGenderMale)
				o_PlayerStats.m_name = "Cortez";
			else if (gender == kGenderNonbi)
				o_PlayerStats.m_name = "Pyrite";
			
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

function dcmdParseHeal(argument0, argument1) {
	var l_parserMode = argument0;
	var l_commandSplit = argument1;

	if (l_parserMode == kCmdlineParserModeWork)
	{	
		var cmd_count = array_length_1d(l_commandSplit);
	
		if (cmd_count == 1)
		{
			debugOut("hurt value target");
			return 0;
		}
		else if (cmd_count == 2)
		{
			var pl = getPlayer();
			pl.stats.m_health += real(l_commandSplit[1]);

			debugOut("Heal player for " + string(real(l_commandSplit[1])));
			return 0;
		}
		else if (cmd_count >= 3)
		{
			var target = _cutsceneParseTarget(l_commandSplit[2]);
			target = instance_find(target, 0);
		
			target.stats.m_health += real(l_commandSplit[1]);
		
			debugOut("Heal " + object_get_name(target.object_index) + " for " + string(real(l_commandSplit[1])));
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

function dcmdParseHurt(argument0, argument1) {
	var l_parserMode = argument0;
	var l_commandSplit = argument1;

	if (l_parserMode == kCmdlineParserModeWork)
	{	
		var cmd_count = array_length_1d(l_commandSplit);
	
		if (cmd_count == 1)
		{
			debugOut("hurt value target");
			return 0;
		}
		else if (cmd_count == 2)
		{
			var pl = getPlayer();
			pl.stats.m_health -= real(l_commandSplit[1]);

			debugOut("Hurt player for " + string(real(l_commandSplit[1])));
			return 0;
		}
		else if (cmd_count >= 3)
		{
			var target = _cutsceneParseTarget(l_commandSplit[2]);
			target = instance_find(target, 0);
		
			target.stats.m_health -= real(l_commandSplit[1]);
		
			debugOut("Hurt " + object_get_name(target.object_index) + " for " + string(real(l_commandSplit[1])));
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

function dcmdParseTime(argument0, argument1) {
	var l_parserMode = argument0;
	var l_commandSplit = argument1;

	if (l_parserMode == kCmdlineParserModeWork)
	{	
		var cmd_count = array_length_1d(l_commandSplit);
	
		if (cmd_count == 1)
		{
			debugOut("time value");
		}
		else if (cmd_count >= 2)
		{
			// Find the named flag with the same name
			var hour = real(l_commandSplit[1]);
		
			if (!iexists(o_dayNightCycle))
				inew(o_dayNightCycle);
			
			if (iexists(o_dayNightCycle))
			{
				o_dayNightCycle.m_timeOfDay = hour;
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
