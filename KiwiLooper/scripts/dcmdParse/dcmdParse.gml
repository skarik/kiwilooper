function dcmdParse(argument0, argument1) {
#macro kCmdlineParserModeAutocomplete	0
#macro kCmdlineParserModeSuggest		1
#macro kCmdlineParserModeWork			2

	var l_parserMode = argument0;
	var l_command = argument1;

	var l_commandSplit = string_split(l_command, " ", true);
	var l_commandSplitCount = array_length_1d(l_commandSplit);

	// Parse first command
	if (l_commandSplitCount >= 1)
	{
		if (l_commandSplit[0] == "set")
			return dcmdParseSet(l_parserMode, l_commandSplit);
		else if (l_commandSplit[0] == "hurt")
			return dcmdParseHurt(l_parserMode, l_commandSplit);
		else if (l_commandSplit[0] == "heal")
			return dcmdParseHeal(l_parserMode, l_commandSplit);
		else if (l_commandSplit[0] == "giveitem")
			return dcmdParseGiveItem(l_parserMode, l_commandSplit);
		else if (l_commandSplit[0] == "time")
			return dcmdParseTime(l_parserMode, l_commandSplit);
		else if (l_commandSplit[0] == "gender")
			return dcmdParseGender(l_parserMode, l_commandSplit);
		else if (l_commandSplit[0] == "dolive")
			return dcmdParseDoLive(l_parserMode, l_commandSplit);
	
		debugOut("Invalid command \"" + l_commandSplit[0] + "\"");
	}

	// Fallthru case:
	if (l_parserMode == kCmdlineParserModeWork)
	{
		return 0;
	}
	else if (l_parserMode == kCmdlineParserModeSuggest)
	{
		return l_command;
	}
	else if (l_parserMode == kCmdlineParserModeAutocomplete)
	{
		return [];
	}


}
