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
