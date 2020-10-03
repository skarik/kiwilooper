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
