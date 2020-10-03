function dcmdRunString(argument0) {
	var cmds = string_split(argument0, ";", true);
	var cmds_count = array_length_1d(cmds);

	for (var i = 0; i < cmds_count; ++i)
	{
		dcmdParse(kCmdlineParserModeWork, cmds[i]);
	}


}
