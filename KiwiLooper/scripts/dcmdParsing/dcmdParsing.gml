#macro kCmdlineParserModeAutocomplete	0
#macro kCmdlineParserModeSuggest		1
#macro kCmdlineParserModeWork			2

gml_pragma("global", "g_dcmdInitialize();");
function g_dcmdInitialize()
{
	static kDefaultFunc = function(args){ return 0; };
	static kDefaultAutoComplete = function(args){ return []; };
	
	global.dcmd_Commands = [
		{
			command:	"editor",
			func:		function(args){ room_goto(rm_EditorTest); _Loader.bRoomIsSet = true; return 0; },
			autocomp:	kDefaultAutoComplete,
		},
	];
}

function dcmdParse(argument0, argument1)
{
	var l_parserMode = argument0;
	var l_command = argument1;

	var l_commandSplit = string_split(l_command, " ", true);
	var l_commandSplitCount = array_length_1d(l_commandSplit);

	// Parse first command
	if (l_commandSplitCount >= 1)
	{
		// Trim the command before parsing
		l_commandSplit[0] = string_ltrim(string_rtrim(l_commandSplit[0]));
		
		for (var i = 0; i < array_length(global.dcmd_Commands); ++i)
		{
			var cmd = global.dcmd_Commands[i];
			if (l_commandSplit[0] == cmd.command)
			{
				return cmd.func();
			}
		}
		/*if (l_commandSplit[0] == "set")
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
			return dcmdParseDoLive(l_parserMode, l_commandSplit);*/
	
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

function dcmdParseDoLive(argument0, argument1)
{
	var l_parserMode = argument0;
	var l_commandSplit = argument1;

	if (l_parserMode == kCmdlineParserModeWork)
	{	
		var cmd_count = array_length_1d(l_commandSplit);
	
		if (cmd_count == 1)
		{
			room_set_live(room, true);
			with (obj_gmlive)
			{
				//live_room_updated = debugLiveOnRoomUpdate;
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

///@function dcmdRunString(argument0)
function dcmdRunString(argument0)
{
	var cmds = string_split(argument0, ";", true);
	var cmds_count = array_length_1d(cmds);

	for (var i = 0; i < cmds_count; ++i)
	{
		dcmdParse(kCmdlineParserModeWork, cmds[i]);
	}
}
